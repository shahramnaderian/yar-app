import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? YarConfig.apiBaseUrl;
  final String baseUrl;
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'yar_auth_token';
  Uri _uri(String path) => Uri.parse(baseUrl + path);
  Future<Map<String, String>> _headers({bool json = false}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer ' + token;
    return h;
  }
  Future<void> _saveToken(String token) async { await _storage.write(key: _tokenKey, value: token); }
  static Future<bool> hasToken() async { return (await _storage.read(key: _tokenKey) ?? '').isNotEmpty; }
  static Future<void> clearToken() async { await _storage.delete(key: _tokenKey); }
  Future<Map<String, dynamic>> _decode(http.Response r) async {
    final b = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode < 200 || r.statusCode >= 300) throw Exception(b['error']?.toString() ?? 'خطای سرور');
    return b;
  }
  Future<Map<String, dynamic>> register({required String name, required String email, required String password}) async {
    final r = await http.post(_uri('/api/auth/register'), headers: await _headers(json: true), body: jsonEncode({'name': name, 'email': email, 'password': password})).timeout(YarConfig.requestTimeout);
    final b = await _decode(r); await _saveToken(b['token'] as String); return b['user'] as Map<String, dynamic>;
  }
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final r = await http.post(_uri('/api/auth/login'), headers: await _headers(json: true), body: jsonEncode({'email': email, 'password': password})).timeout(YarConfig.requestTimeout);
    final b = await _decode(r); await _saveToken(b['token'] as String); return b['user'] as Map<String, dynamic>;
  }
  Future<void> logout() async {
    try { await http.post(_uri('/api/auth/logout'), headers: await _headers()).timeout(YarConfig.requestTimeout); } finally { await clearToken(); }
  }
  Future<Map<String, dynamic>> me() async { final r = await http.get(_uri('/api/me'), headers: await _headers()).timeout(YarConfig.requestTimeout); return _decode(r); }
  Future<Map<String, dynamic>> health() async { final r = await http.get(_uri('/api/health')).timeout(YarConfig.requestTimeout); return _decode(r); }
  Future<String> chat(String message) async {
    final r = await http.post(_uri('/api/chat'), headers: await _headers(json: true), body: jsonEncode({'message': message})).timeout(YarConfig.requestTimeout);
    final b = await _decode(r); return b['reply']?.toString() ?? 'پاسخی دریافت نشد.';
  }
  Future<void> resetChat() async { final r = await http.post(_uri('/api/chat/reset'), headers: await _headers()).timeout(YarConfig.requestTimeout); await _decode(r); }
  Future<List<Map<String, dynamic>>> tasks() async {
    final r = await http.get(_uri('/api/tasks'), headers: await _headers()).timeout(YarConfig.requestTimeout);
    return ((await _decode(r))['tasks'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }
  Future<Map<String, dynamic>> createTask({required String title, String? description}) async {
    final r = await http.post(_uri('/api/tasks'), headers: await _headers(json: true), body: jsonEncode({'title': title, 'description': description ?? ''})).timeout(YarConfig.requestTimeout);
    return (await _decode(r))['task'] as Map<String, dynamic>;
  }
  Future<void> approveTask(String id) async { final r = await http.post(_uri('/api/tasks/' + id + '/approve'), headers: await _headers()).timeout(YarConfig.requestTimeout); await _decode(r); }
  Future<void> deleteTask(String id) async { final r = await http.delete(_uri('/api/tasks/' + id), headers: await _headers()).timeout(YarConfig.requestTimeout); await _decode(r); }
  Future<List<Map<String, dynamic>>> goals() async {
    final r = await http.get(_uri('/api/goals'), headers: await _headers()).timeout(YarConfig.requestTimeout);
    return ((await _decode(r))['goals'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }
  Future<Map<String, dynamic>> createGoal({required String title, String? target}) async {
    final r = await http.post(_uri('/api/goals'), headers: await _headers(json: true), body: jsonEncode({'title': title, 'target': target ?? ''})).timeout(YarConfig.requestTimeout);
    return (await _decode(r))['goal'] as Map<String, dynamic>;
  }
}