import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../shell/empty_surface.dart';

class AiPanel extends StatelessWidget {
  const AiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptySurface(
      icon: Icons.auto_awesome_outlined,
      title: l10n.ai,
      body: l10n.aiEmpty,
      footnote: l10n.sliceLabel,
    );
  }
}
