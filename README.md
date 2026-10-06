# Aperture

Offline-first fil- og nettleser med et KI-panel. Én Flutter-kodebase for iOS, Android, macOS, Windows og Linux.

Repo-navnet er `Aparture_Browser` (historisk skrivefeil). Pakken og produktnavnet er `aperture`.

## Status

Snitt 2, filer. Gi tilgang til en mappe med sti, bla med brødsmuler, forhåndsvis tekst og bilder. Stier utenfor roten, inkludert symlink, avvises. Ingen nettvisning eller KI-kall.

Gi tilgang: lim inn en absolutt mappesti og trykk Gi tilgang. iOS og Android har ikke fri disk. Fildialog kommer når plattformmappene er generert.

## Dataflyt

```text
ShellPage
  ├─ /files   FilesPage     granted mappe, listing, forhåndsvisning
  ├─ /browse  BrowsePage    tom til snitt 4 webview
  └─ /ai      AiPanel       tom til snitt 5 endepunkt
        │
        ▼
   rust/core  stisandkasse (testet). Ikke koblet via flutter_rust_bridge ennå.
        │
        ▼
   OpenAI-kompatibelt endepunkt, bare hvis brukeren satte base-URL
```

Dart eier UI. Samme stisjekk ligger i `rust/core` og kjøres med `cargo test`. Broen er ikke generert i dette snittet. Nettside- og filinnhold behandles som data, ikke instruksjoner.

## Bygg

Krever Flutter stable 3.24 eller nyere.

```bash
flutter pub get
flutter test
flutter run -d linux    # eller macos, windows, chrome
```

Mobilmål (Android/iOS) kommer når plattformmappene er generert med `flutter create . --platforms=android,ios,linux,macos,windows`. Denne leveransen har app-koden, ikke de genererte plattformskallene.

Agent-instruksen ligger i `SPEC.md`. Snitt 3 er ikke startet.
