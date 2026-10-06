import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'files_browser.dart';
import 'sandbox.dart';

class FilesState {
  const FilesState({
    this.root,
    this.current,
    this.entries = const [],
    this.previewPath,
    this.previewText,
    this.error,
  });

  final String? root;
  final String? current;
  final List<FileEntry> entries;
  final String? previewPath;
  final String? previewText;
  final String? error;

  FilesState copyWith({
    String? root,
    String? current,
    List<FileEntry>? entries,
    String? previewPath,
    String? previewText,
    String? error,
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
    );
  }
}

class FilesController extends StateNotifier<FilesState> {
  FilesController(this._browser) : super(const FilesState());

  final FilesBrowser _browser;

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
