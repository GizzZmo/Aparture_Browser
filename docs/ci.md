# CI

Tre workflow-runs. Badge i README peker på status for default branch.

| Workflow | Hva den lager | Hvor resultatet ligger |
| --- | --- | --- |
| `artifacts.yml` | Flutter- og Rust-testlogger | Actions-artifact `test-logs` |
| `screenshots.yml` | PNG av Filer, Nett og KI | Actions-artifact `screenshots` |
| `assets.yml` | `aperture-assets.tar.gz` med README, SPEC og skjermbilder | Actions-artifact `aperture-assets`. På en tag legges den også som release-asset |

Kjør på nytt fra Actions, eller lokalt:

```bash
gh workflow run artifacts.yml
gh workflow run screenshots.yml
gh workflow run assets.yml
```

Skjermbildene genereres med `flutter test --update-goldens test/screenshot_test.dart`. De er ikke plattform-webview-bilder. De viser de tre flatene i widget-testen.
