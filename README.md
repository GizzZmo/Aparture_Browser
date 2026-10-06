# Aperture

Offline-first fil- og nettleser med et KI-panel. Én Flutter-kodebase, siktet mot iOS, Android, macOS, Windows og Linux.

Repo-navnet `Aparture_Browser` er en historisk skrivefeil. Produktet og pakken heter `aperture`.

[![artifacts](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/artifacts.yml/badge.svg)](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/artifacts.yml)
[![screenshots](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/screenshots.yml/badge.svg)](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/screenshots.yml)
[![assets](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/assets.yml/badge.svg)](https://github.com/GizzZmo/Aparture_Browser/actions/workflows/assets.yml)

## Status

Snitt 1–5 er merget til `main`. Plattformmapper er ikke committet, så `flutter run` krever `flutter create` lokalt.

| Snitt | Innhold | Tester |
| --- | --- | --- |
| 1 | Skall, tre flater, norsk/engelsk | `widget_test.dart` |
| 2 | Mappesti, listing, forhåndsvisning, stisandkasse | `sandbox_test.dart`, `cargo test` |
| 3 | Indeks og søk, avbrytbart | `index_test.dart`, Rust FTS5 |
| 4 | Én nettfane, lesbar tekst, nedlasting til filflaten | `browse_test.dart` |
| 5 | KI-endepunkt, leseverktøy, forslag med bekreftelse | `ai_test.dart`, `ai_http_test.dart` |

## Filer

1. Lim inn en absolutt mappesti og trykk Gi tilgang. Appen lister bare denne roten.
2. Trykk Indekser. Tekstfiler (txt, md, json, csv, log) leses inn. Avbryt dropper resultatet etter at gåingen er ferdig.
3. Søk i navn og innhold. `ext:txt` begrenser filtype.

iOS og Android har ikke fri disk. Fildialog kommer når plattformmappene finnes.

## Nett

1. Skriv en adresse og trykk enter. Appen henter HTML og viser lesbar tekst, uten script og stil.
2. Tilbake, frem og last på nytt bruker historikken i fanen.
3. Last ned skriver teksten inn i den åpne mappen. Gi tilgang først.

Dette er ikke WKWebView, Android WebView, WebView2 eller WebKitGTK.

## KI

1. Tom base-URL betyr at KI er av.
2. Sett base-URL, modell og nøkkel. Nøkkelen ligger bare i minnet.
3. Fest side sender lesbar tekst som data, ikke som instruksjon.
4. Leseverktøy: `list_dir`, `read_file`, `search_files`, `page_text`.
5. `propose_rename` og `propose_move` venter på Bruk. Ukjente verktøy, inkludert slett, avvises. Flytt ut av roten avvises.

## Dataflyt

```text
FilesPage -> sandbox.resolveWithin -> listing / preview / index
BrowsePage -> HTTP + readableText -> download into granted folder
AiPanel -> OpenAI-compatible /chat/completions
        -> read tools run, write tools wait for Apply
rust/core -> path sandbox + SQLite FTS5, not linked to Flutter yet
```

## Bygg

Krever Flutter stable 3.24 eller nyere, og Rust for kjernen.

```bash
flutter pub get
flutter test
dart test test/ai_http_test.dart
cargo test --manifest-path rust/core/Cargo.toml
flutter create . --platforms=linux,android,ios,macos,windows
flutter run -d linux
```

## CI-artifacts

Workflows og badges er forklart i [docs/ci.md](docs/ci.md).

- `artifacts` laster opp testlogger.
- `screenshots` laster opp PNG av de tre flatene.
- `assets` pakker README, SPEC og skjermbilder. På en tag blir pakken også et release-asset.

## Kjente hull

- Ingen fildialog eller OS-nøkkelring.
- Nettflaten er HTTP pluss lesbar tekst, ikke en plattform-webview.
- Dart-indeksen ligger i minnet. FTS5 ligger i Rust og er ikke koblet til UI.
- Agent-instruksen ligger i `SPEC.md`.
