import 'dart:io';

import 'package:path/path.dart' as p;

class SandboxDenied implements Exception {
  const SandboxDenied(this.path);
  final String path;

  @override
  String toString() => 'Path is outside the granted root: $path';
}

/// Canonical path must be the root or a descendant. Symlinks are followed.
String resolveWithin(String root, String candidate) {
  final rootCanon = Directory(root).resolveSymbolicLinksSync();
  final type = FileSystemEntity.typeSync(candidate, followLinks: false);
  if (type == FileSystemEntityType.notFound) {
    throw SandboxDenied(candidate);
  }
  final candidateCanon = FileSystemEntity.typeSync(candidate) ==
          FileSystemEntityType.notFound
      ? candidate
      : Link(candidate).resolveSymbolicLinksSync();
  if (!_isWithin(rootCanon, candidateCanon)) {
    throw SandboxDenied(candidate);
  }
  return candidateCanon;
}

bool isWithin(String root, String candidate) {
  try {
    resolveWithin(root, candidate);
    return true;
  } on SandboxDenied {
    return false;
  } on FileSystemException {
    return false;
  }
}

bool _isWithin(String root, String candidate) {
  final r = p.normalize(root);
  final c = p.normalize(candidate);
  if (p.equals(r, c)) return true;
  return p.isWithin(r, c);
}
