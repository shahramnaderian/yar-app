import 'package:flutter/material.dart';

import '../services/api_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _api.tasks();
      if (!mounted) return;
      setState(() {
        _tasks = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'اتصال به سرور برقرار نشد';
        _loading = false;
      });
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _api.approveTask(id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وظیفه تأیید و تکمیل شد')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _api.deleteTask(id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در حذف: $e')),
      );
    }
  }

  Future<void> _showAddDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('وظیفه جدید'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'عنوان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'توضیحات (اختیاری)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('افزودن'),
          ),
        ],
      ),
    );

    if (ok != true || titleCtrl.text.trim().isEmpty) return;

    try {
      await _api.createTask(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('وظیفه اضافه شد')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا: $e')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'done':
        return Colors.green;
      case 'in_progress':
      case 'progress':
        return Colors.blue;
      case 'pending_approval':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
      case 'done':
        return Icons.check;
      case 'in_progress':
      case 'progress':
        return Icons.hourglass_top;
      case 'pending_approval':
        return Icons.pending_actions;
      default:
        return Icons.circle_outlined;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
      case 'done':
        return 'انجام‌شده';
      case 'in_progress':
      case 'progress':
        return 'در حال انجام';
      case 'pending_approval':
        return 'منتظر تأیید';
      default:
        return 'در انتظار';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وظایف'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'بروزرسانی',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('وظیفه جدید'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('تلاش مجدد')),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('هنوز وظیفه‌ای ندارید'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final status = (task['status'] as String?) ?? 'pending';
          final color = _statusColor(status);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(_statusIcon(status), color: color),
              ),
              title: Text(
                task['title'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((task['description'] as String?)?.isNotEmpty == true)
                      Text(task['description'] as String),
                    const SizedBox(height: 4),
                    Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 'pending_approval' || status == 'pending')
                    TextButton(
                      onPressed: () => _approve(task['id'] as String),
                      child: const Text('تأیید'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: 'حذف',
                    onPressed: () => _delete(task['id'] as String),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
