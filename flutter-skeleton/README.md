# یار — اپ Flutter کامل

کد اپ + راهنمای اجرا. پوشه‌های `android/` و `ios/` با دستور زیر یک‌بار ساخته می‌شوند (یا از فایل zip کامل استفاده کن).

## روش ۱ — با zip کامل (پیشنهادی)

اگر فایل `yar-flutter-complete.zip` را داری، از حالت فشرده خارج کن و:

```bash
cd yar-flutter   # نام پوشه بعد از extract
flutter pub get
flutter run
```

## روش ۲ — از همین ریپو

```bash
cd flutter-skeleton
flutter create . --project-name yar --org com.yar.app
# اگر lib را overwrite کرد:
git checkout -- lib pubspec.yaml
flutter pub get
flutter run
```

## بک‌اند (الزامی برای AI)

```bash
cd backend
npm install
export AI_API_KEY="sk-..."
npm start
```

## آدرس سرور

فایل `lib/config.dart`:

| محیط | مقدار |
|------|--------|
| Android Emulator | `http://10.0.2.2:3000` |
| iOS Simulator | `http://localhost:3000` |
| گوشی واقعی | `http://IP-کامپیوتر:3000` |

```bash
flutter run --dart-define=API_BASE=http://192.168.1.5:3000
```

## اندروید

- `INTERNET` permission
- `usesCleartextTraffic=true` برای HTTP

## ساختار lib

```
lib/
  main.dart
  config.dart
  services/api_service.dart
  screens/
    home_screen.dart
    chat_screen.dart   ← وصل به AI
    tasks_screen.dart
    goals_screen.dart
    profile_screen.dart
```
