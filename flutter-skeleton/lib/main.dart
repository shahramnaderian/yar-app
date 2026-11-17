import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const YarApp()); }
class YarApp extends StatelessWidget {
  const YarApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'یار', debugShowCheckedModeBanner: false, locale: const Locale('fa', 'IR'),
    supportedLocales: const [Locale('fa', 'IR'), Locale('en', 'US')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)), scaffoldBackgroundColor: const Color(0xFFF8FAFC)),
    darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), brightness: Brightness.dark)),
    home: const _AuthGate(),
  );
}
class _AuthGate extends StatefulWidget { const _AuthGate(); @override State<_AuthGate> createState() => _AuthGateState(); }
class _AuthGateState extends State<_AuthGate> {
  late Future<bool> _signedIn;
  @override void initState() { super.initState(); _signedIn = ApiService.hasToken(); }
  @override Widget build(BuildContext context) => FutureBuilder<bool>(future: _signedIn, builder: (context, s) {
    if (!s.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return s.data! ? const HomeScreen() : const AuthScreen();
  });
}