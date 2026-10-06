use std::fs;
use std::io;
use std::path::{Path, PathBuf};

#[derive(Debug)]
pub enum SandboxError {
    NotFound,
    OutsideRoot,
    Io(io::Error),
}

pub fn resolve_within(root: &Path, candidate: &Path) -> Result<PathBuf, SandboxError> {
    let root = fs::canonicalize(root).map_err(map_io)?;
    let candidate = fs::canonicalize(candidate).map_err(map_io)?;
    if !is_within(&root, &candidate) {
        return Err(SandboxError::OutsideRoot);
    }
    Ok(candidate)
}

pub fn is_within(root: &Path, candidate: &Path) -> bool {
    if candidate == root {
        return true;
    }
    let mut root = root.to_path_buf();
    if !root.ends_with("") {
        root.push("");
    }
    candidate.starts_with(&root)
}

fn map_io(err: io::Error) -> SandboxError {
    if err.kind() == io::ErrorKind::NotFound {
        SandboxError::NotFound
    } else {
        SandboxError::Io(err)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn temp() -> PathBuf {
        let path = std::env::temp_dir().join(format!(
            "aperture-sandbox-{}",
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        fs::create_dir_all(&path).unwrap();
        path
    }

    #[test]
    fn allows_file_inside_root() {
        let root = temp();
        fs::write(root.join("note.txt"), "hi").unwrap();
        let resolved = resolve_within(&root, &root.join("note.txt")).unwrap();
        assert!(resolved.ends_with("note.txt"));
        let _ = fs::remove_dir_all(root);
    }

    #[test]
    fn rejects_parent_escape() {
        let root = temp();
        fs::create_dir_all(root.join("inner")).unwrap();
        let err = resolve_within(&root.join("inner"), &root).unwrap_err();
        assert!(matches!(err, SandboxError::OutsideRoot));
        let _ = fs::remove_dir_all(root);
    }

    #[test]
    fn rejects_symlink_escape() {
        let root = temp();
        let outside = temp();
        fs::write(outside.join("secret.txt"), "no").unwrap();
        std::os::unix::fs::symlink(outside.join("secret.txt"), root.join("leak")).unwrap();
        let err = resolve_within(&root, &root.join("leak")).unwrap_err();
        assert!(matches!(err, SandboxError::OutsideRoot));
        let _ = fs::remove_dir_all(root);
        let _ = fs::remove_dir_all(outside);
    }
}
