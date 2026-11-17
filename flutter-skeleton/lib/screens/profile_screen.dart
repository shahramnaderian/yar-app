import 'package:flutter/material.dart';
import '../config.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  String _status = 'در حال بررسی...', _name = 'کاربر یار', _email = '';
  bool _ok = false, _loading = false;
  @override void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    if (mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([_api.health(), _api.me()]);
      if (!mounted) return;
      final ai = values[0]['ai'] as Map<String, dynamic>?, me = values[1];
      setState(() {
        _ok = true; _name = me['name']?.toString() ?? 'کاربر یار'; _email = me['email']?.toString() ?? '';
        _status = ai?['configured'] == true ? 'هوش مصنوعی فعال — مدل: ' + (ai?['model']?.toString() ?? '-') : 'سرور وصل است؛ هوش مصنوعی در حالت آزمایشی است.';
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _ok = false; _status = 'سرور در دسترس نیست\n' + YarConfig.apiBaseUrl; _loading = false; });
    }
  }
  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('پروفایل')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const SizedBox(height: 12),
      const CircleAvatar(radius: 48, backgroundColor: Color(0xFF2563EB), child: Icon(Icons.person, size: 48, color: Colors.white)),
      const SizedBox(height: 16),
      Text(_name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      if (_email.isNotEmpty) ...[const SizedBox(height: 4), Text(_email, textAlign: TextAlign.center)],
      const SizedBox(height: 8),
      Text(_status, textAlign: TextAlign.center, style: TextStyle(color: _ok ? Colors.green[700] : Colors.red[700], height: 1.4)),
      const SizedBox(height: 24),
      Card(child: ListTile(leading: const Icon(Icons.refresh), title: const Text('بررسی مجدد اتصال'), onTap: _loading ? null : _check)),
      Card(child: ListTile(leading: const Icon(Icons.link), title: const Text('آدرس API'), subtitle: Text(YarConfig.apiBaseUrl))),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: _logout, icon: const Icon(Icons.logout), label: const Text('خروج از حساب')),
    ]),
  );
}