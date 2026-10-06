# Aperture

Offline-first fil- og nettleser med et KI-panel. Én Flutter-kodebase, siktet mot iOS, Android, macOS, Windows og Linux.

Repo-navnet `Aparture_Browser` er en historisk skrivefeil. Produktet og pakken heter `aperture`.

## Status

| Snitt | Innhold | Tilstand |
| --- | --- | --- |
| 1 | Skall, tre flater, språk | Merged |
| 2 | Mappesti, listing, brødsmuler, forhåndsvisning, stisandkasse | PR #2 |
| 3 | Bakgrunnsindeks og søk, avbrytbart | PR #3 |
| 4 | Én nettfane, navigasjon, lesbar tekst, nedlasting | Denne branchen |
| 5 | KI-panel og verktøy | Ikke startet |

Plattformmapper (linux, android, ios, macos, windows) er ikke committet. Generer dem lokalt før `flutter run`.

## Slik bruker du filer

1. Åpne Filer.
2. Lim inn en absolutt mappesti og trykk Gi tilgang. Appen lister bare denne roten.
3. Trykk Indekser. Tekstfiler (txt, md, json, csv, log) leses inn. Avbryt dropper resultatet.
4. Søk i navn og innhold. `ext:txt` begrenser filtype. Treff åpnes i forhåndsvisning.

## Slik bruker du nett

1. Åpne Nett.
2. Skriv en adresse og trykk enter. Appen henter HTML og viser lesbar tekst, uten script og stil.
3. Tilbake, frem og last på nytt bruker historikken i fanen.
4. Last ned skriver teksten inn i den åpne mappen i filflaten. Gi tilgang til en mappe først.

Dette er ikke en plattform-webview. WKWebView, Android WebView, WebView2 og WebKitGTK kommer når plattformmappene er generert.

iOS og Android har ikke fri disk. En systemfildialog kommer når plattformmappene finnes. Inntil da er stien manuell, og det er i praksis et desktop-steg.

## Dataflyt

```text
FilesPage
  grant path -> sandbox.resolveWithin
  list / preview -> FilesBrowser, avviser symlink ut av rot
  Indekser -> FileIndex i Dart, søk med ext:
  Last ned -> saveText i granted mappe
BrowsePage
  adresse, tilbake, frem, reload
  HTTP-henting + readableText
  plattform-webview er ikke koblet inn ennå
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

- Ingen fildialog, gi nytt navn, flytt, slett eller KI.
- Nettflaten henter HTML selv. Den er ikke WKWebView/WebView2 ennå.
- Dart-indeksen er minnet, ikke SQLite. FTS5 ligger i Rust og er ikke koblet til UI.
- Avbryt i UI markerer jobben som droppet. Selve gåingen er synkron og fullfører før resultatet kastes.
- Agent-instruksen ligger i `SPEC.md`.
