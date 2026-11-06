import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'title': 'بررسی قبض برق',
        'status': 'pending',
        'desc': 'منتظر تأیید پرداخت ۲۸۰ هزار تومان',
        'color': Colors.orange,
      },
      {
        'title': 'خلاصه گزارش هفتگی',
        'status': 'progress',
        'desc': 'در حال پردازش...',
        'color': Colors.blue,
      },
      {
        'title': 'رزرو بلیط تهران-شیراز',
        'status': 'done',
        'desc': 'انجام شد • دیروز',
        'color': Colors.green,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('وظایف'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: (task['color'] as Color).withOpacity(0.15),
                child: Icon(
                  task['status'] == 'done'
                      ? Icons.check
                      : task['status'] == 'progress'
                          ? Icons.hourglass_top
                          : Icons.pending_actions,
                  color: task['color'] as Color,
                ),
              ),
              title: Text(
                task['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(task['desc'] as String),
              ),
              trailing: task['status'] == 'pending'
                  ? TextButton(
                      onPressed: () {},
                      child: const Text('تأیید'),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
