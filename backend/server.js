/**
 * یار (Yar) - Backend API با هوش مصنوعی واقعی
 * Node.js 18+ | Express
 *
 * تنظیمات از طریق متغیر محیطی:
 *   AI_API_KEY   — کلید OpenAI یا xAI (الزامی برای AI واقعی)
 *   AI_BASE_URL  — پیش‌فرض: https://api.openai.com/v1
 *   AI_MODEL     — پیش‌فرض: gpt-4o-mini
 *
 * مثال Grok:
 *   AI_BASE_URL=https://api.x.ai/v1
 *   AI_MODEL=grok-2-latest
 */

const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

const AI_API_KEY = process.env.AI_API_KEY || process.env.OPENAI_API_KEY || process.env.XAI_API_KEY || '';
const AI_BASE_URL = (process.env.AI_BASE_URL || 'https://api.openai.com/v1').replace(/\/$/, '');
const AI_MODEL = process.env.AI_MODEL || 'gpt-4o-mini';

app.use(cors());
app.use(express.json({ limit: '1mb' }));

const SYSTEM_PROMPT = `تو «یار» هستی — یک دستیار هوشمند شخصی فارسی‌زبان.

شخصیت و قوانین:
- همیشه به فارسی روان، دوستانه و مختصر جواب بده.
- مثل یک دستیار واقعی کمک کن: برنامه‌ریزی، یادآوری، ایده‌پردازی، خلاصه‌سازی، پیشنهاد خرید، سفر و کارهای روزمره.
- اگر کاری نیاز به تأیید کاربر دارد (پرداخت، ارسال پیام، رزرو) اول بپرس و تأیید بگیر.
- وقتی مطمئن نیستی، صادق باش و حدس نزن.
- از ایموجی کم و به‌جا استفاده کن.
- خودت را به‌عنوان یار معرفی کن، نه به‌عنوان ChatGPT یا مدل دیگر.`;

const conversations = new Map();

const mockUser = {
  id: 'user_1',
  name: 'کاربر نمونه',
  plan: 'free',
  dailyUsage: 0,
  dailyLimit: 50
};

// داده‌های قابل تغییر در حافظه
let mockTasks = [
  {
    id: 'task_1',
    title: 'بررسی قبض برق',
    status: 'pending_approval',
    createdAt: new Date().toISOString(),
    description: 'قبض برق این ماه ۲۸۰ هزار تومان است. می‌خوای پرداختش کنم؟'
  },
  {
    id: 'task_2',
    title: 'خلاصه گزارش هفتگی',
    status: 'in_progress',
    createdAt: new Date().toISOString(),
    description: 'در حال خلاصه‌سازی گزارش فروش هفته گذشته...'
  },
  {
    id: 'task_3',
    title: 'رزرو بلیط تهران-شیراز',
    status: 'completed',
    createdAt: new Date(Date.now() - 86400000).toISOString(),
    description: 'انجام شد • دیروز'
  }
];

let mockGoals = [
  { id: 'goal_1', title: 'یادگیری Flutter', progress: 35, target: '۱۰ ساعت در ماه' },
  { id: 'goal_2', title: 'ورزش منظم', progress: 60, target: '۳ جلسه در هفته' },
  { id: 'goal_3', title: 'خواندن کتاب', progress: 20, target: '۱ کتاب در ماه' }
];

function getHistory(sessionId) {
  if (!conversations.has(sessionId)) {
    conversations.set(sessionId, []);
  }
  return conversations.get(sessionId);
}

async function callAI(userMessage, sessionId) {
  if (!AI_API_KEY) {
    throw new Error('NO_API_KEY');
  }

  const history = getHistory(sessionId);
  history.push({ role: 'user', content: userMessage });

  // نگه داشتن حداکثر ۱۰ پیام اخیر برای هزینه کمتر
  while (history.length > 10) history.shift();

  const body = {
    model: AI_MODEL,
    messages: [{ role: 'system', content: SYSTEM_PROMPT }, ...history],
    temperature: 0.7,
    max_tokens: 800
  };

  const res = await fetch(`${AI_BASE_URL}/chat/completions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${AI_API_KEY}`
    },
    body: JSON.stringify(body)
  });

  if (!res.ok) {
    const errText = await res.text();
    console.error('AI API error:', res.status, errText);
    throw new Error(`AI_HTTP_${res.status}`);
  }

  const data = await res.json();
  const reply = data.choices?.[0]?.message?.content?.trim();
  if (!reply) throw new Error('EMPTY_REPLY');

  history.push({ role: 'assistant', content: reply });
  return reply;
}

function mockReply(message) {
  if (message.includes('قبض') || message.includes('برق') || message.includes('آب')) {
    return 'قبوضت رو چک کردم. قبض برق این ماه حدود ۲۸۰ هزار تومانه. می‌خوای برات پرداختش کنم؟ (حالت آزمایشی — کلید AI تنظیم نشده)';
  }
  if (message.includes('سفر') || message.includes('بلیط')) {
    return 'برای کجا و چه تاریخی می‌خوای سفر برنامه‌ریزی کنم؟ (حالت آزمایشی)';
  }
  return `متوجه شدم: «${message}». الان در حالت آزمایشی هستم. برای پاسخ واقعی، کلید AI را در backend تنظیم کن.`;
}

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'yar-api',
    version: '0.3.0',
    ai: {
      configured: Boolean(AI_API_KEY),
      model: AI_MODEL,
      baseUrl: AI_BASE_URL
    }
  });
});

app.post('/api/chat', async (req, res) => {
  const { message, sessionId = 'default' } = req.body || {};
  if (!message || typeof message !== 'string') {
    return res.status(400).json({ error: 'پیام الزامی است' });
  }

  const text = message.trim().slice(0, 4000);
  if (!text) {
    return res.status(400).json({ error: 'پیام خالی است' });
  }

  try {
    let reply;
    let mode = 'ai';

    if (AI_API_KEY) {
      reply = await callAI(text, sessionId);
    } else {
      reply = mockReply(text);
      mode = 'mock';
    }

    mockUser.dailyUsage += 1;

    res.json({
      reply,
      mode,
      usage: { used: mockUser.dailyUsage, limit: mockUser.dailyLimit }
    });
  } catch (err) {
    console.error(err);
    if (err.message === 'NO_API_KEY') {
      return res.json({ reply: mockReply(text), mode: 'mock' });
    }
    res.status(502).json({
      error: 'خطا در ارتباط با سرویس هوش مصنوعی',
      detail: err.message
    });
  }
});

app.post('/api/chat/reset', (req, res) => {
  const { sessionId = 'default' } = req.body || {};
  conversations.delete(sessionId);
  res.json({ ok: true });
});

// ——— Tasks ———

app.get('/api/tasks', (req, res) => {
  res.json({ tasks: mockTasks });
});

app.post('/api/tasks', (req, res) => {
  const { title, description } = req.body || {};
  if (!title || typeof title !== 'string' || !title.trim()) {
    return res.status(400).json({ error: 'عنوان وظیفه الزامی است' });
  }

  const task = {
    id: `task_${Date.now()}`,
    title: title.trim().slice(0, 200),
    description: (description || '').trim().slice(0, 500),
    status: 'pending',
    createdAt: new Date().toISOString()
  };

  mockTasks.unshift(task);
  res.status(201).json({ success: true, task });
});

app.post('/api/tasks/:id/approve', (req, res) => {
  const task = mockTasks.find((t) => t.id === req.params.id);
  if (!task) return res.status(404).json({ error: 'وظیفه پیدا نشد' });
  task.status = 'completed';
  res.json({ success: true, task });
});

app.delete('/api/tasks/:id', (req, res) => {
  const index = mockTasks.findIndex((t) => t.id === req.params.id);
  if (index === -1) return res.status(404).json({ error: 'وظیفه پیدا نشد' });
  mockTasks.splice(index, 1);
  res.json({ success: true });
});

// ——— Goals ———

app.get('/api/goals', (req, res) => {
  res.json({ goals: mockGoals });
});

app.post('/api/goals', (req, res) => {
  const { title, target } = req.body || {};
  if (!title || typeof title !== 'string' || !title.trim()) {
    return res.status(400).json({ error: 'عنوان هدف الزامی است' });
  }

  const goal = {
    id: `goal_${Date.now()}`,
    title: title.trim().slice(0, 200),
    target: (target || '').trim().slice(0, 100),
    progress: 0
  };

  mockGoals.unshift(goal);
  res.status(201).json({ success: true, goal });
});

app.get('/api/me', (req, res) => {
  res.json({ ...mockUser, aiConfigured: Boolean(AI_API_KEY) });
});

app.listen(PORT, () => {
  console.log(`یار API روی پورت ${PORT}`);
  console.log(`AI: ${AI_API_KEY ? `فعال (${AI_MODEL})` : 'غیرفعال — حالت mock'}`);
});
