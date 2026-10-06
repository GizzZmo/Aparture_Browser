import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../l10n/app_localizations.dart';
import '../ai/ai_panel.dart';
import '../browse/browse_page.dart';
import '../files/files_page.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          TextButton(
            onPressed: () {
              final current = ref.read(localeProvider);
              ref.read(localeProvider.notifier).state =
                  current.languageCode == 'nb'
                      ? const Locale('en')
                      : const Locale('nb');
            },
            child: Text(ref.watch(localeProvider).languageCode.toUpperCase()),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: navigationShell.goBranch,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.folder_outlined),
                      label: Text(l10n.files),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.public),
                      label: Text(l10n.browse),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.auto_awesome_outlined),
                      label: Text(l10n.ai),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.folder_outlined),
                  label: l10n.files,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.public),
                  label: l10n.browse,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: l10n.ai,
                ),
              ],
            ),
    );
  }
}

class FilesSurface extends StatelessWidget {
  const FilesSurface({super.key});

  @override
  Widget build(BuildContext context) => const FilesPage();
}

class BrowseSurface extends StatelessWidget {
  const BrowseSurface({super.key});

  @override
  Widget build(BuildContext context) => const BrowsePage();
}

class AiSurface extends StatelessWidget {
  const AiSurface({super.key});

  @override
  Widget build(BuildContext context) => const AiPanel();
}
