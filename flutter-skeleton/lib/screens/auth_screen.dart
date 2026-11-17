import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(), _password = TextEditingController();
  final _api = ApiService();
  bool _register = false, _busy = false, _hidePassword = true;
  String? _error;
  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      if (_register) {
        await _api.register(name: _name.text.trim(), email: _email.text.trim(), password: _password.text);
      } else {
        await _api.login(email: _email.text.trim(), password: _password.text);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          CircleAvatar(radius: 38, backgroundColor: primary, child: const Icon(Icons.auto_awesome, color: Colors.white, size: 38)),
          const SizedBox(height: 18),
          const Text('یار', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_register ? 'حساب کاربری بساز و شروع کن' : 'خوش برگشتی! وارد حساب یارت شو', textAlign: TextAlign.center),
          const SizedBox(height: 30),
          if (_register) ...[
            TextFormField(controller: _name, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'نام', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().length < 2) ? 'نام را وارد کن' : null),
            const SizedBox(height: 14),
          ],
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'ایمیل', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()), validator: (v) => (v == null || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) ? 'ایمیل معتبر وارد کن' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _password, obscureText: _hidePassword, decoration: InputDecoration(labelText: 'رمز عبور', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _hidePassword = !_hidePassword)), border: const OutlineInputBorder()), validator: (v) => (v == null || v.length < 8) ? 'رمز عبور باید حداقل ۸ کاراکتر باشد' : null),
          if (_error != null) ...[const SizedBox(height: 14), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red))],
          const SizedBox(height: 22),
          FilledButton(onPressed: _busy ? null : _submit, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)), child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_register ? 'ایجاد حساب' : 'ورود')),
          TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }), child: Text(_register ? 'حساب داری؟ وارد شو' : 'حساب نداری؟ ثبت‌نام کن')),
          const SizedBox(height: 12),
          const Text('اطلاعات وظایف و اهداف به حساب شخصی تو متصل می‌شود.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ])),
      ),
    ))));
  }
}