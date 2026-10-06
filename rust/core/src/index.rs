use rusqlite::{params, Connection};
use std::fs;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Instant;

use crate::sandbox::resolve_within;

pub struct Index {
    conn: Connection,
}

impl Index {
    pub fn open(path: &Path) -> rusqlite::Result<Self> {
        let conn = Connection::open(path)?;
        conn.execute_batch(
            "CREATE TABLE IF NOT EXISTS files (
                path TEXT PRIMARY KEY,
                parent TEXT NOT NULL,
                name TEXT NOT NULL,
                is_dir INTEGER NOT NULL
            );
            CREATE VIRTUAL TABLE IF NOT EXISTS files_fts USING fts5(path, body, tokenize='unicode61');",
        )?;
        Ok(Self { conn })
    }

    pub fn reindex(&self, root: &Path, cancel: &AtomicBool) -> Result<usize, String> {
        let root = resolve_within(root, root).map_err(|err| format!("{err:?}"))?;
        self.conn
            .execute_batch("DELETE FROM files; DELETE FROM files_fts;")
            .map_err(|err| err.to_string())?;
        let mut count = 0;
        self.walk(&root, &root, cancel, &mut count)?;
        Ok(count)
    }

    fn walk(
        &self,
        root: &Path,
        dir: &Path,
        cancel: &AtomicBool,
        count: &mut usize,
    ) -> Result<(), String> {
        if cancel.load(Ordering::Relaxed) {
            return Err("cancelled".into());
        }
        let dir = resolve_within(root, dir).map_err(|err| format!("{err:?}"))?;
        let parent = dir.to_string_lossy().to_string();
        let name = dir
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_default();
        self.conn
            .execute(
                "INSERT OR REPLACE INTO files (path, parent, name, is_dir) VALUES (?1, ?2, ?3, 1)",
                params![parent, parent, name],
            )
            .map_err(|err| err.to_string())?;
        for entry in fs::read_dir(&dir).map_err(|err| err.to_string())? {
            if cancel.load(Ordering::Relaxed) {
                return Err("cancelled".into());
            }
            let entry = entry.map_err(|err| err.to_string())?;
            let path = entry.path();
            if resolve_within(root, &path).is_err() {
                continue;
            }
            let is_dir = entry.file_type().map(|t| t.is_dir()).unwrap_or(false);
            let name = entry.file_name().to_string_lossy().to_string();
            let path_s = path.to_string_lossy().to_string();
            self.conn
                .execute(
                    "INSERT OR REPLACE INTO files (path, parent, name, is_dir) VALUES (?1, ?2, ?3, ?4)",
                    params![path_s, parent, name, is_dir as i64],
                )
                .map_err(|err| err.to_string())?;
            if is_dir {
                self.walk(root, &path, cancel, count)?;
            } else if is_text(&path) {
                let body = fs::read_to_string(&path).unwrap_or_default();
                self.conn
                    .execute(
                        "INSERT INTO files_fts (path, body) VALUES (?1, ?2)",
                        params![path_s, body],
                    )
                    .map_err(|err| err.to_string())?;
                *count += 1;
            }
        }
        Ok(())
    }

    pub fn list_dir(&self, parent: &Path) -> rusqlite::Result<Vec<String>> {
        let mut stmt = self.conn.prepare(
            "SELECT name FROM files WHERE parent = ?1 AND path != parent ORDER BY is_dir DESC, name",
        )?;
        let rows = stmt.query_map([parent.to_string_lossy().to_string()], |row| row.get(0))?;
        rows.collect()
    }

    pub fn search(&self, query: &str) -> rusqlite::Result<Vec<String>> {
        let mut stmt = self
            .conn
            .prepare("SELECT path FROM files_fts WHERE files_fts MATCH ?1 LIMIT 50")?;
        let rows = stmt.query_map([query], |row| row.get(0))?;
        rows.collect()
    }
}

fn is_text(path: &Path) -> bool {
    matches!(
        path.extension().and_then(|e| e.to_str()),
        Some("txt" | "md" | "json" | "csv" | "log")
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn lists_two_thousand_files_from_index_within_one_second() {
        let root = std::env::temp_dir().join(format!(
            "aperture-idx-{}",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir_all(&root).unwrap();
        for i in 0..2000 {
            fs::write(root.join(format!("f{i}.txt")), format!("alpha {i}")).unwrap();
        }
        let db = temp_db();
        assert!(list_indexed_under_ms(&root, &db, 1000));
        let index = Index::open(&db).unwrap();
        let hits = index.search("alpha").unwrap();
        assert_eq!(hits.len(), 50);
        let cancel = AtomicBool::new(true);
        let err = index.reindex(&root, &cancel).unwrap_err();
        assert_eq!(err, "cancelled");
        let _ = fs::remove_dir_all(root);
        let _ = fs::remove_file(db);
    }
}

pub fn list_indexed_under_ms(root: &Path, db: &Path, budget_ms: u128) -> bool {
    let index = Index::open(db).unwrap();
    let cancel = AtomicBool::new(false);
    index.reindex(root, &cancel).unwrap();
    let started = Instant::now();
    let _ = index.list_dir(root).unwrap();
    started.elapsed().as_millis() < budget_ms
}

pub fn temp_db() -> PathBuf {
    std::env::temp_dir().join(format!(
        "aperture-index-{}.db",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_nanos()
    ))
}
