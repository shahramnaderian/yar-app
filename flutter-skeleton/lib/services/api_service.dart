import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  ApiService({String? baseUrl, String? sessionId})
      : baseUrl = baseUrl ?? YarConfig.apiBaseUrl,
        sessionId = sessionId ?? 'flutter_session';

  final String baseUrl;
  final String sessionId;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> health() async {
    final res = await http
        .get(_uri('/api/health'))
        .timeout(YarConfig.requestTimeout);
    if (res.statusCode != 200) {
      throw Exception('health ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<String> chat(String message) async {
    final res = await http
        .post(
          _uri('/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'sessionId': sessionId,
          }),
        )
        .timeout(YarConfig.requestTimeout);

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(body['error']?.toString() ?? 'خطای سرور');
    }
    return body['reply']?.toString() ?? 'پاسخی دریافت نشد.';
  }

  Future<void> resetChat() async {
    await http
        .post(
          _uri('/api/chat/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'sessionId': sessionId}),
        )
        .timeout(YarConfig.requestTimeout);
  }

  Future<List<Map<String, dynamic>>> tasks() async {
    final res =
        await http.get(_uri('/api/tasks')).timeout(YarConfig.requestTimeout);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['tasks'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> goals() async {
    final res =
        await http.get(_uri('/api/goals')).timeout(YarConfig.requestTimeout);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['goals'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
