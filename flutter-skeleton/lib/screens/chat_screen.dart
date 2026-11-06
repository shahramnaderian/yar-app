import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'from': 'yar',
      'text': 'سلام! من یار هستم. چطور می‌تونم امروز کمکت کنم؟',
      'time': '۱۰:۳۰',
    },
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'from': 'user',
        'text': text,
        'time': _now(),
      });
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _messages.add({
          'from': 'yar',
          'text': _generateReply(text),
          'time': _now(),
        });
      });
    });
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _generateReply(String input) {
    if (input.contains('قبض') || input.contains('برق')) {
      return 'قبوضت رو چک کردم. قبض برق این ماه حدود ۲۸۰ هزار تومانه. می‌خوای برات پرداختش کنم؟';
    }
    if (input.contains('سفر') || input.contains('بلیط')) {
      return 'عالی! برای کجا و چه تاریخی می‌خوای برنامه‌ریزی کنم؟';
    }
    return 'متوجه شدم. می‌تونم برات انجامش بدم یا اطلاعات بیشتری جمع کنم. جزئیات بیشتری بگو.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('یار'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['from'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _chip('قبض برق رو چک کن'),
                _chip('برنامه‌ریزی سفر'),
                _chip('خلاصه گزارش'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'پیامت رو بنویس...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          _controller.text = label;
          _sendMessage();
        },
      ),
    );
  }
}
