import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'browse_controller.dart';

class BrowsePage extends ConsumerStatefulWidget {
  const BrowsePage({super.key});

  @override
  ConsumerState<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends ConsumerState<BrowsePage> {
  final _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(browseControllerProvider);
    final controller = ref.read(browseControllerProvider.notifier);
    final current = state.current;
    if (current != null && _address.text != current.url.toString()) {
      _address.text = current.url.toString();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: state.canBack ? controller.back : null,
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.back,
              ),
              IconButton(
                onPressed: state.canForward ? controller.forward : null,
                icon: const Icon(Icons.arrow_forward),
                tooltip: l10n.forward,
              ),
              IconButton(
                onPressed: current == null ? null : controller.reload,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.reload,
              ),
              Expanded(
                child: TextField(
                  controller: _address,
                  decoration: InputDecoration(
                    hintText: l10n.addressHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: controller.open,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: current == null ? null : controller.downloadReadable,
                child: Text(l10n.download),
              ),
            ],
          ),
        ),
        if (state.loading) const LinearProgressIndicator(),
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(state.error!),
          ),
        Expanded(
          child: current == null
              ? Center(child: Text(l10n.browseEmpty))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(controller.pageText ?? ''),
                ),
        ),
      ],
    );
  }
}
