# Aperture

Offline-first fil- og nettleser med et KI-panel. Én Flutter-kodebase for iOS, Android, macOS, Windows og Linux.

Repo-navnet er `Aparture_Browser` (historisk skrivefeil). Pakken og produktnavnet er `aperture`.

## Status

Snitt 1, skall. Tre tomme flater og språkvelger. Ingen filtilgang, nettvisning eller KI-kall.

## Dataflyt

```text
ShellPage
  ├─ /files   FilesPage     tom til snitt 2 granted mappe
  ├─ /browse  BrowsePage    tom til snitt 4 webview
  └─ /ai      AiPanel       tom til snitt 5 endepunkt
        │
        ▼
   (senere) rust/core  SQLite + FTS5 + stisandkasse
        │
        ▼
   OpenAI-kompatibelt endepunkt, bare hvis brukeren satte base-URL
```

Dart eier UI og plattformkanaler. Rust skal eie indeksering og stisjekk fra snitt 2. Nettside- og filinnhold behandles som data, ikke instruksjoner.

## Bygg

Krever Flutter stable 3.24 eller nyere.

```bash
flutter pub get
flutter test
flutter run -d linux    # eller macos, windows, chrome
```

Mobilmål (Android/iOS) kommer når plattformmappene er generert med `flutter create . --platforms=android,ios,linux,macos,windows`. Denne leveransen har app-koden, ikke de genererte plattformskallene.

Agent-instruksen ligger i `SPEC.md`. Ikke start snitt 2 før det er bedt om.
