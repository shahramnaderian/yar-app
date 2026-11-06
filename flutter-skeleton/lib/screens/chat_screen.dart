import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _api = ApiService();
  final List<_Msg> _messages = [
    _Msg(fromUser: false, text: 'سلام! من یار هستم. چطور می‌تونم امروز کمکت کنم؟'),
  ];
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add(_Msg(fromUser: true, text: text));
      _controller.clear();
      _busy = true;
    });
    _scrollToEnd();

    try {
      final reply = await _api.chat(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(fromUser: false, text: reply));
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          fromUser: false,
          text:
              'اتصال به سرور برقرار نشد.\nبک‌اند را روی پورت ۳۰۰۰ اجرا کن و آدرس را در lib/config.dart بررسی کن.\n\n($e)',
        ));
        _busy = false;
      });
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _reset() async {
    try {
      await _api.resetChat();
    } catch (_) {}
    setState(() {
      _messages
        ..clear()
        ..add(_Msg(fromUser: false, text: 'گفتگو پاک شد. دوباره شروع کنیم؟'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('یار'),
        actions: [
          IconButton(
            tooltip: 'پاک کردن گفتگو',
            icon: const Icon(Icons.refresh),
            onPressed: _busy ? null : _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_busy ? 1 : 0),
              itemBuilder: (context, index) {
                if (_busy && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.fromUser ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: msg.fromUser ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.fromUser ? Colors.white : Colors.black87,
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
                _chip('برنامه‌ریزی سفر شیراز'),
                _chip('یک برنامه روزانه بده'),
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
                      enabled: !_busy,
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
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _busy ? null : () => _send(),
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
        onPressed: _busy ? null : () => _send(label),
      ),
    );
  }
}

class _Msg {
  _Msg({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}
