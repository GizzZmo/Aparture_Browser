import 'dart:io';

import 'package:aperture/features/files/file_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('indexes 2000 files and lists a directory in under a second', () {
    final root = Directory.systemTemp.createTempSync('aperture-dart-idx');
    for (var i = 0; i < 2000; i++) {
      File('${root.path}/f$i.txt').writeAsStringSync('alpha $i');
    }
    final index = FileIndex();
    final startedBuild = DateTime.now();
    expect(index.build(root.path), 2000);
    expect(DateTime.now().difference(startedBuild).inMilliseconds, lessThan(15000));

    final startedList = DateTime.now();
    final names = index.namesIn(root.path);
    expect(DateTime.now().difference(startedList).inMilliseconds, lessThan(1000));
    expect(names.length, 2000);

    expect(index.search('alpha ext:txt').length, 50);
    expect(index.search('missing-token'), isEmpty);

    var seen = 0;
    final cancelled = FileIndex();
    expect(cancelled.build(root.path, isCancelled: () => ++seen > 3), 0);
    expect(cancelled.files, isEmpty);
    root.deleteSync(recursive: true);
  });
}
