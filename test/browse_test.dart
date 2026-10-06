import 'dart:io';

import 'package:aperture/features/browse/browse_controller.dart';
import 'package:aperture/features/browse/readable.dart';
import 'package:aperture/features/files/files_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readable text drops scripts and tags', () {
    const html = '<style>body{}</style><script>alert(1)</script><p>Hello&bye</p>';
    expect(readableText(html), 'Hello&bye');
  });

  test('back, forward and download land in the granted folder', () async {
    final root = Directory.systemTemp.createTempSync('aperture-dl');
    final pages = {
      'https://example.test/one': '<p>One</p>',
      'https://example.test/two': '<p>Two</p>',
    };
    final container = ProviderContainer(
      overrides: [
        pageFetcherProvider.overrideWith((ref) {
          return (uri) async => pages[uri.toString()]!;
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(() => root.deleteSync(recursive: true));

    container.read(filesControllerProvider.notifier).grant(root.path);
    final browse = container.read(browseControllerProvider.notifier);
    await browse.open('example.test/one');
    await browse.open('https://example.test/two');
    browse.back();
    expect(browse.pageText, 'One');
    browse.forward();
    expect(browse.pageText, 'Two');

    final saved = await browse.downloadReadable();
    expect(saved, isNotNull);
    expect(File(saved!).readAsStringSync(), 'Two');
    expect(
      container.read(filesControllerProvider).entries.map((e) => e.name),
      contains('two.txt'),
    );
  });
}
