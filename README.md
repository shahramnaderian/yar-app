# یار (Yar) — دستیار هوشمند شخصی

**یار** یک عامل هوش مصنوعی شخصی است. نسخهٔ فعلی به **AI واقعی** (OpenAI یا xAI Grok) وصل می‌شود.

## ساختار

| مسیر | توضیح |
|------|--------|
| `web-prototype/index.html` | رابط چت (به بک‌اند وصل می‌شود) |
| `backend/` | API + اتصال به مدل زبانی |
| `flutter-skeleton/` | اسکلت اپ موبایل |
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

### ۳. پروتوتایپ را باز کن

فایل `web-prototype/index.html` را در مرورگر باز کن.

بالای صفحه باید **«AI فعال»** را ببینی. بعد هر پیامی بفرستی با مدل واقعی جواب می‌دهد.

بدون کلید API، حالت **mock** (پاسخ آزمایشی) کار می‌کند.

## تست سلامت API

```bash
curl http://localhost:3000/api/health
```

نمونه پاسخ وقتی کلید ست شده:

```json
{ "status": "ok", "ai": { "configured": true, "model": "gpt-4o-mini" } }
```

## نکته امنیتی

کلید API را فقط روی سرور (متغیر محیطی) بگذار؛ داخل فرانت یا گیت‌هاب commit نکن.
