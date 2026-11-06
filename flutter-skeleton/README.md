# یار — اجرای Flutter روی گوشی / شبیه‌ساز

## پیش‌نیاز

1. نصب [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. بک‌اند یار در حال اجرا باشد (`cd backend && npm start`)
3. کلید AI در بک‌اند ست شده باشد (اختیاری ولی توصیه‌شده)

## ساخت پروژه قابل اجرا (یک‌بار)

پوشه فعلی فقط `lib` و `pubspec` دارد. پلتفرم‌ها را با Flutter بساز:

```bash
cd flutter-skeleton

# ساخت پوشه‌های android / ios / web
flutter create . --project-name yar --org com.yar.app

# اگر از شما پرسید فایل‌ها را overwrite کند، برای pubspec و lib بگو No
# یا قبلش از lib و pubspec.yaml بکاپ بگیر و بعد از create برگردان

flutter pub get
```

اگر `flutter create` روی `lib` نوشت، فایل‌های این ریپو را دوباره از گیت برگردان:

```bash
git checkout -- lib pubspec.yaml
flutter pub get
```

## تنظیم آدرس سرور

فایل `lib/config.dart`:

| محیط | آدرس |
|------|------|
| Android Emulator | `http://10.0.2.2:3000` (پیش‌فرض) |
| iOS Simulator | `http://localhost:3000` |
| گوشی واقعی | `http://IP-کامپیوتر:3000` مثلاً `http://192.168.1.5:3000` |

یا موقع اجرا:

```bash
flutter run --dart-define=API_BASE=http://192.168.1.5:3000
```

**اندروید cleartext:** برای HTTP (نه HTTPS) در `AndroidManifest.xml`:

```xml
<application android:usesCleartextTraffic="true" ...>
```

## اجرا

```bash
# لیست دستگاه‌ها
flutter devices

# اجرا روی دستگاه انتخاب‌شده
flutter run
```

## قابلیت‌ها در این نسخه

- چت متصل به بک‌اند (AI واقعی اگر کلید ست شده باشد)
- نمایش وضعیت اتصال در پروفایل
- تب‌های وظایف و اهداف (دمو)
- RTL و فارسی

## عیب‌یابی

- **Connection refused** → بک‌اند روشن نیست یا IP اشتباه است
- **Cleartext blocked** → `usesCleartextTraffic=true`
- **AI mock** → کلید `AI_API_KEY` در بک‌اند ست نشده
