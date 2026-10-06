import 'dart:io';

import 'package:path/path.dart' as p;

import 'sandbox.dart';

class FileEntry {
  const FileEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
  });

  final String name;
  final String path;
  final bool isDirectory;
}

class FilesBrowser {
  const FilesBrowser();

  List<FileEntry> list(String root, String directory) {
    final resolved = resolveWithin(root, directory);
    final dir = Directory(resolved);
    final entries = dir.listSync(followLinks: false).map((entity) {
      final name = p.basename(entity.path);
      final isDir = entity is Directory;
      return FileEntry(name: name, path: entity.path, isDirectory: isDir);
    }).toList()
      ..sort((a, b) {
        if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return entries;
  }

  String readText(String root, String file, {int maxBytes = 200000}) {
    final resolved = resolveWithin(root, file);
    final bytes = File(resolved).readAsBytesSync();
    final slice = bytes.length > maxBytes ? bytes.sublist(0, maxBytes) : bytes;
    return String.fromCharCodes(slice);
  }

  bool isImage(String file) {
    final ext = p.extension(file).toLowerCase();
    return const {'.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp'}.contains(ext);
  }

  bool isText(String file) {
    final ext = p.extension(file).toLowerCase();
    return const {
      '.txt',
      '.md',
      '.json',
      '.csv',
      '.log',
      '.yaml',
      '.yml',
      '.dart',
    }.contains(ext);
  }
}
