import 'dart:convert';
import 'dart:io';

import 'package:aperture/features/ai/ai_client.dart';
import 'package:aperture/features/ai/ai_settings.dart';
import 'package:test/test.dart';

void main() {
  test('HTTP client posts to chat completions with the bearer key', () async {
    String? auth;
    String? path;
    String? model;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    server.listen((request) async {
      auth = request.headers.value(HttpHeaders.authorizationHeader);
      path = request.uri.path;
      final body = jsonDecode(await utf8.decoder.bind(request).join());
      model = body['model'] as String?;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'choices': [
          {
            'message': {
              'content': 'from-server',
              'tool_calls': [
                {
                  'function': {'name': 'page_text', 'arguments': '{}'},
                },
              ],
            },
          },
        ],
      }));
      await request.response.close();
    });

    final reply = await openAiTransport(
      AiSettings(
        baseUrl: 'http://${server.address.host}:${server.port}/v1/',
        model: 'local-model',
        apiKey: 'secret-key',
      ),
      'hello',
    );
    expect(path, '/v1/chat/completions');
    expect(auth, 'Bearer secret-key');
    expect(model, 'local-model');
    expect(reply.text, 'from-server');
    expect(reply.tools.single.name, 'page_text');
  });
}
