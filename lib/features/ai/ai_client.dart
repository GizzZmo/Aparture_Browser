import 'dart:convert';
import 'dart:io';

import 'ai_settings.dart';

class AiReply {
  const AiReply({this.text = '', this.tools = const []});

  final String text;
  final List<ToolCall> tools;
}

typedef AiTransport = Future<AiReply> Function(AiSettings settings, String prompt);

AiReply parseChatCompletion(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) return const AiReply();
  final choices = decoded['choices'];
  if (choices is! List || choices.isEmpty) return const AiReply();
  final message = choices.first['message'];
  if (message is! Map<String, dynamic>) return const AiReply();
  final tools = <ToolCall>[];
  final rawTools = message['tool_calls'];
  if (rawTools is List) {
    for (final raw in rawTools) {
      if (raw is! Map<String, dynamic>) continue;
      final fn = raw['function'];
      if (fn is! Map<String, dynamic>) continue;
      final name = fn['name'];
      if (name is! String) continue;
      final args = fn['arguments'];
      final parsed = args is String ? jsonDecode(args) : args;
      tools.add(ToolCall(name, parsed is Map<String, dynamic> ? parsed : {}));
    }
  }
  return AiReply(text: message['content'] as String? ?? '', tools: tools);
}

Map<String, Object> chatCompletionBody(AiSettings settings, String prompt) {
  return {
    'model': settings.model,
    'messages': [
      {'role': 'system', 'content': aiSystemPrompt},
      {'role': 'user', 'content': prompt},
    ],
  };
}

Future<AiReply> openAiTransport(AiSettings settings, String prompt) async {
  final base = settings.baseUrl.endsWith('/')
      ? settings.baseUrl.substring(0, settings.baseUrl.length - 1)
      : settings.baseUrl;
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('$base/chat/completions'));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (settings.apiKey.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${settings.apiKey}');
    }
    request.write(jsonEncode(chatCompletionBody(settings, prompt)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return parseChatCompletion(body);
  } finally {
    client.close();
  }
}
