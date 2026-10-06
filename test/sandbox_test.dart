import 'dart:io';

import 'package:aperture/features/files/files_browser.dart';
import 'package:aperture/features/files/sandbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory outside;

  setUp(() {
    root = Directory.systemTemp.createTempSync('aperture-root');
    outside = Directory.systemTemp.createTempSync('aperture-out');
    File('${root.path}/note.txt').writeAsStringSync('hello');
    Directory('${root.path}/nested').createSync();
    File('${root.path}/nested/inner.md').writeAsStringSync('# hi');
    File('${outside.path}/secret.txt').writeAsStringSync('nope');
    Link('${root.path}/leak').createSync('${outside.path}/secret.txt');
  });

  tearDown(() {
    root.deleteSync(recursive: true);
    outside.deleteSync(recursive: true);
  });

  test('allows a file inside the granted root', () {
    expect(isWithin(root.path, '${root.path}/note.txt'), isTrue);
  });

  test('rejects parent escape', () {
    expect(isWithin('${root.path}/nested', root.path), isFalse);
  });

  test('rejects a symlink that leaves the root', () {
    expect(isWithin(root.path, '${root.path}/leak'), isFalse);
  });

  test('lists and reads text inside the root', () {
    const browser = FilesBrowser();
    final entries = browser.list(root.path, root.path);
    expect(entries.map((e) => e.name), containsAll(['nested', 'note.txt']));
    expect(browser.readText(root.path, '${root.path}/note.txt'), 'hello');
  });

  test('read of an escaped symlink throws', () {
    const browser = FilesBrowser();
    expect(
      () => browser.readText(root.path, '${root.path}/leak'),
      throwsA(isA<SandboxDenied>()),
    );
  });
}
