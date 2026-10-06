import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../l10n/app_localizations.dart';
import 'files_browser.dart';
import 'files_controller.dart';

class FilesPage extends ConsumerStatefulWidget {
  const FilesPage({super.key});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final _path = TextEditingController();

  @override
  void dispose() {
    _path.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(filesControllerProvider);
    final controller = ref.read(filesControllerProvider.notifier);
    if (state.root == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filesEmpty),
            const SizedBox(height: 16),
            TextField(
              controller: _path,
              decoration: InputDecoration(
                labelText: l10n.grantLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => controller.grant(_path.text.trim()),
              child: Text(l10n.grantAction),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Crumbs(
                root: state.root!,
                current: state.current!,
                onOpen: controller.open,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: l10n.searchLabel,
                          isDense: true,
                        ),
                        onChanged: controller.search,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.indexing)
                      TextButton(
                        onPressed: controller.cancelIndex,
                        child: Text(l10n.cancelIndex),
                      )
                    else
                      TextButton(
                        onPressed: controller.startIndex,
                        child: Text(l10n.buildIndex),
                      ),
                  ],
                ),
              ),
              if (state.hits.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView(
                    children: [
                      for (final hit in state.hits)
                        ListTile(
                          dense: true,
                          title: Text(hit.name),
                          subtitle: Text(hit.path),
                          onTap: () => controller.preview(hit.path),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  children: [
                    for (final entry in state.entries)
                      ListTile(
                        leading: Icon(
                          entry.isDirectory ? Icons.folder : Icons.insert_drive_file,
                        ),
                        title: Text(entry.name),
                        onTap: () => entry.isDirectory
                            ? controller.open(entry.path)
                            : controller.preview(entry.path),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _Preview(state: state, browser: ref.watch(filesBrowserProvider))),
      ],
    );
  }
}

class _Crumbs extends StatelessWidget {
  const _Crumbs({
    required this.root,
    required this.current,
    required this.onOpen,
  });

  final String root;
  final String current;
  final void Function(String path) onOpen;

  @override
  Widget build(BuildContext context) {
    final relative = p.relative(current, from: root);
    final parts = relative == '.' ? <String>[] : p.split(relative);
    final crumbs = <Widget>[
      TextButton(onPressed: () => onOpen(root), child: Text(p.basename(root))),
    ];
    var walked = root;
    for (final part in parts) {
      walked = p.join(walked, part);
      final target = walked;
      crumbs.add(TextButton(onPressed: () => onOpen(target), child: Text(part)));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: crumbs),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.state, required this.browser});

  final FilesState state;
  final FilesBrowser browser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final path = state.previewPath;
    if (path == null) {
      return Center(child: Text(l10n.previewEmpty));
    }
    if (browser.isImage(path)) {
      return InteractiveViewer(child: Image.file(File(path)));
    }
    if (state.previewText != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(state.previewText!),
      );
    }
    return Center(child: Text(l10n.previewUnsupported));
  }
}
