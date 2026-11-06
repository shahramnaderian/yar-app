import 'package:flutter/material.dart';

import '../config.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _status = 'در حال بررسی...';
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final h = await ApiService().health();
      final ai = h['ai'] as Map<String, dynamic>?;
      final configured = ai?['configured'] == true;
      setState(() {
        _ok = true;
        _status = configured
            ? 'AI فعال — مدل: ${ai?['model'] ?? '-'}'
            : 'سرور وصل است (حالت mock — کلید API نیست)';
      });
    } catch (_) {
      setState(() {
        _ok = false;
        _status = 'سرور در دسترس نیست\n${YarConfig.apiBaseUrl}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFF2563EB),
            child: Icon(Icons.person, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'کاربر نمونه',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ok ? Colors.green[700] : Colors.red[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('بررسی مجدد اتصال'),
              onTap: _check,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link),
              title: const Text('آدرس API'),
              subtitle: Text(YarConfig.apiBaseUrl),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'برای گوشی واقعی، آی‌پی کامپیوتر را در lib/config.dart بگذار.\nAndroid Emulator معمولاً http://10.0.2.2:3000 است.',
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
