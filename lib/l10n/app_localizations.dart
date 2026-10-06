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
  String get aiEmpty;
  String get sliceLabel;
  String get grantLabel;
  String get grantAction;
  String get previewEmpty;
  String get previewUnsupported;
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
  String get browseEmpty => 'No tab open. Slice 4 adds the web view.';
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
      'Ingen fane er åpen. Snitt 4 legger til nettvisning.';
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
