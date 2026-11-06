/**
 * یار (Yar) - Backend API Skeleton
 * Node.js + Express
 */

const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const mockUser = {
  id: 'user_1',
  name: 'کاربر نمونه',
  plan: 'free',
  dailyUsage: 3,
  dailyLimit: 20
};

const mockTasks = [
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
  }
];

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'yar-api', version: '0.1.0' });
});

app.post('/api/chat', async (req, res) => {
  const { message } = req.body;
  if (!message) {
    return res.status(400).json({ error: 'پیام الزامی است' });
  }
  await new Promise(r => setTimeout(r, 800));
  let reply = 'متوجه شدم. چطور می‌تونم کمکت کنم؟';
  let suggestedActions = [];
  if (message.includes('قبض') || message.includes('برق') || message.includes('آب')) {
    reply = 'قبوضت رو چک کردم. قبض برق این ماه ۲۸۰ هزار تومانه. می‌خوای برات پرداختش کنم؟';
    suggestedActions = [
      { id: 'pay_bill', label: 'پرداخت کن', type: 'confirm' },
      { id: 'remind_later', label: 'بعداً یادآوری کن', type: 'secondary' }
    ];
  } else if (message.includes('سفر') || message.includes('بلیط')) {
    reply = 'برای کجا و چه تاریخی می‌خوای سفر برنامه‌ریزی کنم؟';
  } else if (message.includes('خرید') || message.includes('دیجی')) {
    reply = 'چی می‌خوای بخری؟ می‌تونم از دیجی‌کالا برات پیدا کنم و مقایسه قیمت انجام بدم.';
  } else if (message.includes('خلاصه') || message.includes('گزارش')) {
    reply = 'فایل رو بفرست یا لینکش رو بده تا برات خلاصه کنم.';
  } else {
    reply = `در مورد «${message}» فکر کردم. می‌تونم برات برنامه‌ریزی کنم، یادآوری بگذارم یا اطلاعات جمع کنم. کدومش رو می‌خوای؟`;
  }
  res.json({
    reply,
    suggestedActions,
    usage: { used: mockUser.dailyUsage + 1, limit: mockUser.dailyLimit }
  });
});

app.get('/api/tasks', (req, res) => {
  res.json({ tasks: mockTasks });
});

app.post('/api/tasks/:id/approve', (req, res) => {
  const task = mockTasks.find(t => t.id === req.params.id);
  if (!task) return res.status(404).json({ error: 'وظیفه پیدا نشد' });
  task.status = 'completed';
  res.json({ success: true, task });
});

app.get('/api/goals', (req, res) => {
  res.json({
    goals: [
      { id: 'goal_1', title: 'یادگیری Flutter', progress: 35, target: '۱۰ ساعت در ماه' },
      { id: 'goal_2', title: 'ورزش منظم', progress: 60, target: '۳ جلسه در هفته' }
    ]
  });
});

app.get('/api/me', (req, res) => {
  res.json(mockUser);
});

app.listen(PORT, () => {
  console.log(`یار API در حال اجرا روی پورت ${PORT}`);
});
