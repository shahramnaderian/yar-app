import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 4),
          Text(
            'پلن رایگان',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _sectionTitle('اشتراک'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber),
              title: const Text('ارتقاء به پلن حرفه‌ای'),
              subtitle: const Text('دسترسی کامل + یکپارچه‌سازی‌ها'),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('تنظیمات'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('اعلان‌ها'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('حریم خصوصی و امنیت'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('زبان'),
                  trailing: const Text('فارسی'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('درباره'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('درباره یار'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('راهنما و پشتیبانی'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }
}
