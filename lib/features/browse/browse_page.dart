import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../shell/empty_surface.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptySurface(
      icon: Icons.language,
      title: l10n.browse,
      body: l10n.browseEmpty,
      footnote: l10n.sliceLabel,
    );
  }
}
