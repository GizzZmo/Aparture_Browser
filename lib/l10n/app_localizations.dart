import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Hand-written until `flutter gen-l10n` replaces this file.
/// Strings mirror lib/l10n/app_en.arb and app_nb.arb.
abstract class AppLocalizations {
  AppLocalizations(this.localeName);

  final String localeName;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appTitle;
  String get files;
  String get browse;
  String get ai;
  String get filesEmpty;
  String get browseEmpty;
  String get addressHint;
  String get back;
  String get forward;
  String get reload;
  String get download;
  String get aiEmpty;
  String get sliceLabel;
  String get grantLabel;
  String get grantAction;
  String get previewEmpty;
  String get previewUnsupported;
  String get searchLabel;
  String get buildIndex;
  String get cancelIndex;
  String get aiOn;
  String get baseUrl;
  String get model;
  String get apiKey;
  String get saveSettings;
  String get attachPage;
  String get clearLog;
  String get discard;
  String get apply;
  String get prompt;
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Aperture';
  @override
  String get files => 'Files';
  @override
  String get browse => 'Browse';
  @override
  String get ai => 'AI';
  @override
  String get filesEmpty => 'No folder granted yet. Slice 2 adds folder access.';
  @override
  String get browseEmpty => 'No tab open. Enter an address.';
  @override
  String get addressHint => 'Address';
  @override
  String get back => 'Back';
  @override
  String get forward => 'Forward';
  @override
  String get reload => 'Reload';
  @override
  String get download => 'Download';
  @override
  String get aiEmpty => 'AI is off until an endpoint is set. Slice 5.';
  @override
  String get sliceLabel => 'Slice 2 — files';
  @override
  String get grantLabel => 'Folder path';
  @override
  String get grantAction => 'Grant folder';
  @override
  String get previewEmpty => 'Select a file to preview.';
  @override
  String get previewUnsupported => 'No preview for this file type.';
  @override
  String get searchLabel => 'Search name and text. ext:txt';
  @override
  String get buildIndex => 'Index';
  @override
  String get cancelIndex => 'Cancel';
  @override
  String get aiOn => 'AI endpoint is set.';
  @override
  String get baseUrl => 'Base URL';
  @override
  String get model => 'Model';
  @override
  String get apiKey => 'API key';
  @override
  String get saveSettings => 'Save';
  @override
  String get attachPage => 'Attach page';
  @override
  String get clearLog => 'Clear log';
  @override
  String get discard => 'Discard';
  @override
  String get apply => 'Apply';
  @override
  String get prompt => 'Ask';
}

class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb() : super('nb');

  @override
  String get appTitle => 'Aperture';
  @override
  String get files => 'Filer';
  @override
  String get browse => 'Nett';
  @override
  String get ai => 'KI';
  @override
  String get filesEmpty =>
      'Ingen mappe er gitt tilgang ennå. Snitt 2 legger til mappetilgang.';
  @override
  String get browseEmpty =>
      'Ingen fane er åpen. Skriv inn en adresse.';
  @override
  String get addressHint => 'Adresse';
  @override
  String get back => 'Tilbake';
  @override
  String get forward => 'Frem';
  @override
  String get reload => 'Last på nytt';
  @override
  String get download => 'Last ned';
  @override
  String get aiEmpty => 'KI er av til et endepunkt er satt. Snitt 5.';
  @override
  String get sliceLabel => 'Snitt 2 — filer';
  @override
  String get grantLabel => 'Mappesti';
  @override
  String get grantAction => 'Gi tilgang';
  @override
  String get previewEmpty => 'Velg en fil for forhåndsvisning.';
  @override
  String get previewUnsupported => 'Ingen forhåndsvisning for denne filtypen.';
  @override
  String get searchLabel => 'Søk i navn og tekst. ext:txt';
  @override
  String get buildIndex => 'Indekser';
  @override
  String get cancelIndex => 'Avbryt';
  @override
  String get aiOn => 'KI-endepunkt er satt.';
  @override
  String get baseUrl => 'Base-URL';
  @override
  String get model => 'Modell';
  @override
  String get apiKey => 'Nøkkel';
  @override
  String get saveSettings => 'Lagre';
  @override
  String get attachPage => 'Fest side';
  @override
  String get clearLog => 'Tøm logg';
  @override
  String get discard => 'Forkast';
  @override
  String get apply => 'Bruk';
  @override
  String get prompt => 'Spør';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'nb';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'en') return AppLocalizationsEn();
    return AppLocalizationsNb();
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
