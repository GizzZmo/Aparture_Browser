# Aperture

Offline-first fil- og nettleser med et KI-panel. Én Flutter-kodebase, siktet mot iOS, Android, macOS, Windows og Linux.

Repo-navnet `Aparture_Browser` er en historisk skrivefeil. Produktet og pakken heter `aperture`.

## Status

| Snitt | Innhold | Tilstand |
| --- | --- | --- |
| 1 | Skall, tre flater, språk | Merged |
| 2 | Mappesti, listing, brødsmuler, forhåndsvisning, stisandkasse | PR #2 |
| 3 | Bakgrunnsindeks og søk, avbrytbart | Denne branchen |
| 4 | Nettfane | Ikke startet |
| 5 | KI-panel og verktøy | Ikke startet |

Plattformmapper (linux, android, ios, macos, windows) er ikke committet. Generer dem lokalt før `flutter run`.

## Slik bruker du filer

1. Åpne Filer.
2. Lim inn en absolutt mappesti og trykk Gi tilgang. Appen lister bare denne roten.
3. Trykk Indekser. Tekstfiler (txt, md, json, csv, log) leses inn. Avbryt dropper resultatet.
4. Søk i navn og innhold. `ext:txt` begrenser filtype. Treff åpnes i forhåndsvisning.

iOS og Android har ikke fri disk. En systemfildialog kommer når plattformmappene finnes. Inntil da er stien manuell, og det er i praksis et desktop-steg.

## Dataflyt

```text
FilesPage
  grant path -> sandbox.resolveWithin
  list / preview -> FilesBrowser, avviser symlink ut av rot
  Indekser -> FileIndex i Dart, søk med ext:
rust/core
  samme stisandkasse
  SQLite FTS5-indeks (rusqlite, bundled)
  ikke koblet til Flutter ennå (ingen flutter_rust_bridge)
```

Nettside- og filinnhold er data, ikke instruksjoner. Ingen KI-kall i dette snittet.

## Bygg og test

Krever Flutter stable 3.24 eller nyere, og Rust hvis du tester kjernen.

```bash
flutter pub get
flutter test
cargo test --manifest-path rust/core/Cargo.toml
flutter create . --platforms=linux,android,ios,macos,windows
flutter run -d linux
```

`flutter test` dekker skall, stisandkasse og at 2000 indekserte filer kan listes på under ett sekund. `cargo test` dekker sandkasse og FTS5.

## Kjente hull

- Ingen fildialog, gi nytt navn, flytt, slett, nettvisning eller KI.
- Dart-indeksen er minnet, ikke SQLite. FTS5 ligger i Rust og er ikke koblet til UI.
- Avbryt i UI markerer jobben som droppet. Selve gåingen er synkron og fullfører før resultatet kastes.
- Agent-instruksen ligger i `SPEC.md`.
