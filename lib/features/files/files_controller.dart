import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'files_browser.dart';
import 'file_index.dart';
import 'sandbox.dart';

class FilesState {
  const FilesState({
    this.root,
    this.current,
    this.entries = const [],
    this.previewPath,
    this.previewText,
    this.error,
    this.indexing = false,
    this.indexedCount = 0,
    this.hits = const [],
  });

  final String? root;
  final String? current;
  final List<FileEntry> entries;
  final String? previewPath;
  final String? previewText;
  final String? error;
  final bool indexing;
  final int indexedCount;
  final List<IndexedFile> hits;

  FilesState copyWith({
    String? root,
    String? current,
    List<FileEntry>? entries,
    String? previewPath,
    String? previewText,
    String? error,
    bool? indexing,
    int? indexedCount,
    List<IndexedFile>? hits,
    bool clearPreview = false,
    bool clearError = false,
  }) {
    return FilesState(
      root: root ?? this.root,
      current: current ?? this.current,
      entries: entries ?? this.entries,
      previewPath: clearPreview ? null : previewPath ?? this.previewPath,
      previewText: clearPreview ? null : previewText ?? this.previewText,
      error: clearError ? null : error ?? this.error,
      indexing: indexing ?? this.indexing,
      indexedCount: indexedCount ?? this.indexedCount,
      hits: hits ?? this.hits,
    );
  }
}

class FilesController extends StateNotifier<FilesState> {
  FilesController(this._browser) : super(const FilesState());

  final FilesBrowser _browser;
  final FileIndex index = FileIndex();
  int _generation = 0;

  Future<void> startIndex() async {
    final root = state.root;
    if (root == null) return;
    final generation = ++_generation;
    state = state.copyWith(indexing: true, clearError: true);
    await Future<void>.delayed(Duration.zero);
    final built = FileIndex();
    built.build(root, isCancelled: () => generation != _generation);
    if (generation != _generation) {
      state = state.copyWith(indexing: false);
      return;
    }
    index.files = built.files;
    state = state.copyWith(indexing: false, indexedCount: built.files.length);
  }

  void cancelIndex() {
    _generation++;
    index.cancel();
    state = state.copyWith(indexing: false);
  }

  void search(String query) {
    state = state.copyWith(hits: index.search(query));
  }

  String? saveText(String name, String contents) {
    final root = state.root;
    final current = state.current;
    if (root == null || current == null) return null;
    final target = p.join(current, name);
    resolveWithin(root, current);
    File(target).writeAsStringSync(contents);
    open(current);
    return target;
  }

  void grant(String path) {
    try {
      final canonical = resolveWithin(path, path);
      final resolved = _browser.list(canonical, canonical);
      state = FilesState(root: canonical, current: canonical, entries: resolved);
    } on Object catch (err) {
      state = state.copyWith(error: err.toString());
    }
  }

  void open(String path) {
    final root = state.root;
    if (root == null) return;
    try {
      final entries = _browser.list(root, path);
      state = state.copyWith(
        current: path,
        entries: entries,
        clearPreview: true,
        clearError: true,
      );
    } on Object catch (err) {
      state = state.copyWith(error: err.toString());
    }
  }

  void preview(String path) {
    final root = state.root;
    if (root == null) return;
    if (_browser.isImage(path)) {
      state = state.copyWith(
        previewPath: path,
        previewText: null,
        clearError: true,
      );
      return;
    }
    if (_browser.isText(path)) {
      try {
        final text = _browser.readText(root, path);
        state = state.copyWith(
          previewPath: path,
          previewText: text,
          clearError: true,
        );
      } on Object catch (err) {
        state = state.copyWith(error: err.toString());
      }
      return;
    }
    state = state.copyWith(
      previewPath: path,
      previewText: null,
      error: 'unsupported',
    );
  }
}

final filesBrowserProvider = Provider<FilesBrowser>((ref) => const FilesBrowser());

final filesControllerProvider =
    StateNotifierProvider<FilesController, FilesState>((ref) {
  return FilesController(ref.watch(filesBrowserProvider));
});
