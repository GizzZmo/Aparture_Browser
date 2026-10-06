import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../shell/empty_surface.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptySurface(
      icon: Icons.folder_open,
      title: l10n.files,
      body: l10n.filesEmpty,
      footnote: l10n.sliceLabel,
    );
  }
}
