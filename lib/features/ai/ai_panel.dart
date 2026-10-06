import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'ai_controller.dart';
import 'ai_settings.dart';

class AiPanel extends ConsumerStatefulWidget {
  const AiPanel({super.key});

  @override
  ConsumerState<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends ConsumerState<AiPanel> {
  final _base = TextEditingController();
  final _model = TextEditingController();
  final _key = TextEditingController();
  final _prompt = TextEditingController();

  @override
  void dispose() {
    _base.dispose();
    _model.dispose();
    _key.dispose();
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(aiControllerProvider);
    final controller = ref.read(aiControllerProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(state.settings.enabled ? l10n.aiOn : l10n.aiEmpty),
        TextField(controller: _base, decoration: InputDecoration(labelText: l10n.baseUrl)),
        TextField(controller: _model, decoration: InputDecoration(labelText: l10n.model)),
        TextField(
          controller: _key,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.apiKey),
        ),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: () => controller.saveSettings(
                AiSettings(baseUrl: _base.text, model: _model.text, apiKey: _key.text),
              ),
              child: Text(l10n.saveSettings),
            ),
            TextButton(onPressed: controller.attachPage, child: Text(l10n.attachPage)),
            TextButton(onPressed: controller.clearLog, child: Text(l10n.clearLog)),
          ],
        ),
        if (state.attached.isNotEmpty)
          Text(state.attached, maxLines: 4, overflow: TextOverflow.ellipsis),
        for (final message in state.messages) Text(message),
        if (state.pending != null)
          Card(
            child: ListTile(
              title: Text(state.pending!.name),
              subtitle: Text(state.pending!.args.toString()),
              trailing: Wrap(
                children: [
                  TextButton(onPressed: controller.discard, child: Text(l10n.discard)),
                  FilledButton(onPressed: controller.apply, child: Text(l10n.apply)),
                ],
              ),
            ),
          ),
        TextField(
          controller: _prompt,
          decoration: InputDecoration(labelText: l10n.prompt),
          onSubmitted: (value) {
            controller.send(value);
            _prompt.clear();
          },
        ),
        if (state.error != null) Text(state.error!),
      ],
    );
  }
}
