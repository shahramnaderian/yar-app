/// تنظیمات اتصال به بک‌اند یار
///
/// Android Emulator → http://10.0.2.2:3000
/// iOS Simulator / Desktop → http://localhost:3000
/// گوشی واقعی → آی‌پی کامپیوتر، مثلاً http://192.168.1.10:3000
library;

class YarConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const Duration requestTimeout = Duration(seconds: 60);
}
