import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../files/files_controller.dart';
import 'readable.dart';

typedef PageFetcher = Future<String> Function(Uri uri);

class HistoryEntry {
  const HistoryEntry({required this.url, required this.html});

  final Uri url;
  final String html;
}

class BrowseState {
  const BrowseState({
    this.entries = const [],
    this.index = 0,
    this.loading = false,
    this.error,
    this.lastDownload,
  });

  final List<HistoryEntry> entries;
  final int index;
  final bool loading;
  final String? error;
  final String? lastDownload;

  HistoryEntry? get current =>
      entries.isEmpty ? null : entries[index.clamp(0, entries.length - 1)];

  bool get canBack => index > 0;
  bool get canForward => index < entries.length - 1;

  BrowseState copyWith({
    List<HistoryEntry>? entries,
    int? index,
    bool? loading,
    String? error,
    String? lastDownload,
    bool clearError = false,
  }) {
    return BrowseState(
      entries: entries ?? this.entries,
      index: index ?? this.index,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      lastDownload: lastDownload ?? this.lastDownload,
    );
  }
}

class BrowseController extends StateNotifier<BrowseState> {
  BrowseController(this._ref, {PageFetcher? fetch})
      : _fetch = fetch ?? _unsupportedFetch,
        super(const BrowseState());

  final Ref _ref;
  final PageFetcher _fetch;

  static Future<String> _unsupportedFetch(Uri uri) async {
    throw StateError('No page fetcher configured for ${uri.toString()}');
  }

  Future<void> open(String raw) async {
    final uri = _normalize(raw);
    if (uri == null) {
      state = state.copyWith(error: 'bad-url');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final html = await _fetch(uri);
      final kept = state.entries.take(state.index + 1).toList()
        ..add(HistoryEntry(url: uri, html: html));
      state = state.copyWith(
        entries: kept,
        index: kept.length - 1,
        loading: false,
      );
    } on Object catch (err) {
      state = state.copyWith(loading: false, error: err.toString());
    }
  }

  void back() {
    if (!state.canBack) return;
    state = state.copyWith(index: state.index - 1, clearError: true);
  }

  void forward() {
    if (!state.canForward) return;
    state = state.copyWith(index: state.index + 1, clearError: true);
  }

  Future<void> reload() async {
    final current = state.current;
    if (current == null) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final html = await _fetch(current.url);
      final entries = [...state.entries];
      entries[state.index] = HistoryEntry(url: current.url, html: html);
      state = state.copyWith(entries: entries, loading: false);
    } on Object catch (err) {
      state = state.copyWith(loading: false, error: err.toString());
    }
  }

  String? get pageText {
    final html = state.current?.html;
    if (html == null) return null;
    return readableText(html);
  }

  Future<String?> downloadReadable() async {
    final text = pageText;
    final url = state.current?.url;
    if (text == null || url == null) return null;
    final name = _fileName(url);
    final saved = _ref.read(filesControllerProvider.notifier).saveText(name, text);
    state = state.copyWith(lastDownload: saved, clearError: saved == null);
    if (saved == null) {
      state = state.copyWith(error: 'no-folder');
    }
    return saved;
  }

  Uri? _normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final withScheme = trimmed.contains('://') ? trimmed : 'https://$trimmed';
    return Uri.tryParse(withScheme);
  }

  String _fileName(Uri url) {
    final parts = url.pathSegments.where((part) => part.isNotEmpty).toList();
    final base = parts.isEmpty ? url.host : parts.last;
    final safe = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return safe.endsWith('.txt') ? safe : '$safe.txt';
  }
}

Future<String> httpFetch(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

final pageFetcherProvider = Provider<PageFetcher>((ref) => httpFetch);

final browseControllerProvider =
    StateNotifierProvider<BrowseController, BrowseState>((ref) {
  return BrowseController(ref, fetch: ref.watch(pageFetcherProvider));
});
