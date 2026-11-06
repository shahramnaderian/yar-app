# یار (Yar) — دستیار هوشمند شخصی

**یار** یک عامل هوش مصنوعی شخصی است. نسخهٔ فعلی به **AI واقعی** (OpenAI یا xAI Grok) وصل می‌شود.

## ساختار

| مسیر | توضیح |
|------|--------|
| `web-prototype/index.html` | رابط چت (به بک‌اند وصل می‌شود) |
| `backend/` | API + اتصال به مدل زبانی |
| `flutter-skeleton/` | اپ موبایل (چت واقعی + راهنمای اجرا) |
| `docs/` | مستندات |

## راه‌اندازی AI واقعی (۵ دقیقه)

### ۱. کلید API بگیر

- **OpenAI:** https://platform.openai.com/api-keys  
- **xAI Grok:** https://console.x.ai

### ۲. بک‌اند را اجرا کن

```bash
cd backend
npm install

# OpenAI
export AI_API_KEY="sk-..."
export AI_BASE_URL="https://api.openai.com/v1"
export AI_MODEL="gpt-4o-mini"

# یا Grok:
# export AI_API_KEY="xai-..."
# export AI_BASE_URL="https://api.x.ai/v1"
# export AI_MODEL="grok-2-latest"

npm start
```

سرور روی `http://localhost:3000` بالا می‌آید.

### ۳. پروتوتایپ وب

فایل `web-prototype/index.html` را در مرورگر باز کن. باید **«AI فعال»** را ببینی.

## اجرای اپ Flutter روی گوشی

جزئیات کامل: [`flutter-skeleton/README.md`](flutter-skeleton/README.md)

خلاصه:

```bash
cd flutter-skeleton
flutter create . --project-name yar --org com.yar.app
git checkout -- lib pubspec.yaml   # اگر lib بازنویسی شد
flutter pub get

# آدرس سرور را در lib/config.dart تنظیم کن
flutter run
```

| محیط | API در `lib/config.dart` |
|------|--------------------------|
| Android Emulator | `http://10.0.2.2:3000` |
| iOS Simulator | `http://localhost:3000` |
| گوشی واقعی | `http://IP-کامپیوتر:3000` |

## تست سلامت API

```bash
curl http://localhost:3000/api/health
```

## نکته امنیتی

کلید API را فقط روی سرور (متغیر محیطی) بگذار؛ داخل فرانت یا گیت‌هاب commit نکن.
