import 'dart:io';

import 'package:path/path.dart' as p;

import 'sandbox.dart';

class IndexedFile {
  const IndexedFile({
    required this.path,
    required this.name,
    required this.extension,
    required this.body,
  });

  final String path;
  final String name;
  final String extension;
  final String body;
}

class FileIndex {
  FileIndex({List<IndexedFile>? files}) : files = files ?? [];

  List<IndexedFile> files;
  bool cancelled = false;

  static const textExtensions = {'.txt', '.md', '.json', '.csv', '.log'};

  void cancel() {
    cancelled = true;
  }

  int build(String root, {bool Function()? isCancelled}) {
    cancelled = false;
    final found = <IndexedFile>[];
    _walk(root, Directory(root), found, isCancelled);
    if (cancelled || isCancelled?.call() == true) return 0;
    files = found;
    return files.length;
  }

  void _walk(
    String root,
    Directory dir,
    List<IndexedFile> found,
    bool Function()? isCancelled,
  ) {
    if (cancelled || isCancelled?.call() == true) {
      cancelled = true;
      return;
    }
    final resolved = resolveWithin(root, dir.path);
    for (final entity in Directory(resolved).listSync(followLinks: false)) {
      if (cancelled || isCancelled?.call() == true) {
        cancelled = true;
        return;
      }
      if (!isWithin(root, entity.path)) continue;
      if (entity is Directory) {
        _walk(root, entity, found, isCancelled);
        continue;
      }
      if (entity is! File) continue;
      final ext = p.extension(entity.path).toLowerCase();
      if (!textExtensions.contains(ext)) continue;
      final bytes = entity.readAsBytesSync();
      final slice = bytes.length > 100000 ? bytes.sublist(0, 100000) : bytes;
      found.add(
        IndexedFile(
          path: entity.path,
          name: p.basename(entity.path),
          extension: ext,
          body: String.fromCharCodes(slice),
        ),
      );
    }
  }

  List<IndexedFile> search(String raw) {
    final query = raw.trim();
    if (query.isEmpty) return const [];
    String? ext;
    final terms = <String>[];
    for (final part in query.split(RegExp(r'\s+'))) {
      if (part.startsWith('ext:')) {
        final value = part.substring(4).toLowerCase();
        ext = value.startsWith('.') ? value : '.$value';
      } else if (part.isNotEmpty) {
        terms.add(part.toLowerCase());
      }
    }
    return files.where((file) {
      if (ext != null && file.extension != ext) return false;
      final haystack = '${file.name}\n${file.body}'.toLowerCase();
      return terms.every(haystack.contains);
    }).take(50).toList();
  }

  List<String> namesIn(String directory) {
    final prefix = directory.endsWith(p.separator) ? directory : directory + p.separator;
    return files
        .where((file) => p.dirname(file.path) == directory || file.path.startsWith(prefix))
        .map((file) => file.name)
        .toList();
  }
}
