/**
 * Yar API — authenticated MVP backend.
 * Node.js 18+. Configure AI_API_KEY, AUTH_SECRET and PORT via environment.
 * JSON storage is a starter persistence layer; use a managed database before scaling.
 */
const express = require('express');
const cors = require('cors');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const app = express();
const PORT = Number(process.env.PORT || 3000);
const AI_API_KEY = process.env.AI_API_KEY || process.env.OPENAI_API_KEY || process.env.XAI_API_KEY || '';
const AI_BASE_URL = (process.env.AI_BASE_URL || 'https://api.openai.com/v1').replace(/\/$/, '');
const AI_MODEL = process.env.AI_MODEL || 'gpt-4o-mini';
const AUTH_SECRET = process.env.AUTH_SECRET || '';
const DATA_FILE = process.env.YAR_DATA_FILE || path.join(__dirname, 'data.json');
app.use(cors({ origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : true }));
app.use(express.json({ limit: '1mb' }));

const SYSTEM_PROMPT = 'تو «یار» هستی؛ دستیار هوشمند شخصی فارسی‌زبان. همیشه فارسی روان، دوستانه و روشن پاسخ بده. در برنامه‌ریزی، یادگیری، خلاصه‌سازی و کارهای روزمره کمک کن. برای اقداماتی مانند پرداخت، رزرو یا ارسال پیام، پیش از انجام تأیید بگیر. اگر مطمئن نیستی صادق باش. خودت را یار معرفی کن.';
function loadDb() {
  try {
    const parsed = JSON.parse(fs.readFileSync(DATA_FILE, 'utf8'));
    return { users: parsed.users || [], tasks: parsed.tasks || {}, goals: parsed.goals || {}, conversations: parsed.conversations || {} };
  } catch (error) {
    if (error.code !== 'ENOENT') console.error('Could not read data file:', error.message);
    return { users: [], tasks: {}, goals: {}, conversations: {} };
  }
}
let db = loadDb();
let writeQueue = Promise.resolve();
function persist() {
  writeQueue = writeQueue.then(async () => {
    const temp = DATA_FILE + '.tmp';
    await fs.promises.mkdir(path.dirname(DATA_FILE), { recursive: true });
    await fs.promises.writeFile(temp, JSON.stringify(db, null, 2), { mode: 0o600 });
    await fs.promises.rename(temp, DATA_FILE);
  }).catch((err) => console.error('Persistence error:', err));
  return writeQueue;
}
function safeUser(user) {
  return { id: user.id, name: user.name, email: user.email, plan: user.plan || 'free', createdAt: user.createdAt };
}
function tokenFor(user) {
  const payload = Buffer.from(JSON.stringify({ sub: user.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30 })).toString('base64url');
  const signature = crypto.createHmac('sha256', AUTH_SECRET).update(payload).digest('base64url');
  return payload + '.' + signature;
}
function verifyToken(token) {
  if (!AUTH_SECRET) return null;
  const parts = String(token || '').split('.');
  if (parts.length !== 2) return null;
  const expected = crypto.createHmac('sha256', AUTH_SECRET).update(parts[0]).digest();
  const actual = Buffer.from(parts[1], 'base64url');
  if (actual.length !== expected.length || !crypto.timingSafeEqual(actual, expected)) return null;
  try {
    const payload = JSON.parse(Buffer.from(parts[0], 'base64url').toString());
    if (!payload.sub || payload.exp < Date.now() / 1000) return null;
    return db.users.find((u) => u.id === payload.sub) || null;
  } catch { return null; }
}
function requireAuth(req, res, next) {
  const user = verifyToken((req.headers.authorization || '').replace(/^Bearer\s+/i, ''));
  if (!user) return res.status(401).json({ error: 'برای ادامه وارد حساب کاربری شوید', code: 'UNAUTHORIZED' });
  req.user = user;
  next();
}
function userBucket(collection, userId) {
  if (!db[collection][userId]) db[collection][userId] = [];
  return db[collection][userId];
}
function hashPassword(password, salt = crypto.randomBytes(16).toString('hex')) {
  return { salt, hash: crypto.scryptSync(password, salt, 64).toString('hex') };
}
function validPassword(password, user) {
  const candidate = crypto.scryptSync(password, user.salt, 64);
  const original = Buffer.from(user.passwordHash, 'hex');
  return candidate.length === original.length && crypto.timingSafeEqual(candidate, original);
}
function mockReply(message) {
  if (/قبض|برق|آب/.test(message)) return 'می‌توانم برای بررسی قبض راهنمایی‌ات کنم. برای پرداخت واقعی باید سرویس پرداخت امن متصل شود.';
  if (/سفر|بلیط/.test(message)) return 'حتماً. مقصد و تاریخ سفرت را بگو تا برنامه‌ریزی کنیم.';
  return 'متوجه شدم: «' + message + '». برای پاسخ هوشمند کامل، کلید سرویس AI را روی سرور تنظیم کن.';
}
async function callAI(message, userId) {
  if (!AI_API_KEY) return mockReply(message);
  const history = db.conversations[userId] || [];
  const nextHistory = [...history, { role: 'user', content: message }].slice(-10);
  const response = await fetch(AI_BASE_URL + '/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + AI_API_KEY },
    body: JSON.stringify({ model: AI_MODEL, messages: [{ role: 'system', content: SYSTEM_PROMPT }, ...nextHistory], temperature: 0.7, max_tokens: 800 })
  });
  if (!response.ok) throw new Error('AI_HTTP_' + response.status);
  const data = await response.json();
  const reply = data.choices?.[0]?.message?.content?.trim();
  if (!reply) throw new Error('EMPTY_REPLY');
  db.conversations[userId] = [...nextHistory, { role: 'assistant', content: reply }].slice(-10);
  await persist();
  return reply;
}
app.get('/api/health', (_req, res) => res.json({ status: 'ok', service: 'yar-api', version: '1.0.0', ai: { configured: Boolean(AI_API_KEY), model: AI_MODEL } }));
app.post('/api/auth/register', async (req, res) => {
  const name = String(req.body?.name || '').trim().slice(0, 80);
  const email = String(req.body?.email || '').trim().toLowerCase();
  const password = String(req.body?.password || '');
  if (name.length < 2 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || password.length < 8) return res.status(400).json({ error: 'نام، ایمیل معتبر و رمز عبور حداقل ۸ کاراکتری لازم است' });
  if (db.users.some((u) => u.email === email)) return res.status(409).json({ error: 'این ایمیل قبلاً ثبت شده است' });
  if (!AUTH_SECRET) return res.status(503).json({ error: 'تنظیم AUTH_SECRET روی سرور الزامی است' });
  const credentials = hashPassword(password);
  const user = { id: crypto.randomUUID(), name, email, salt: credentials.salt, passwordHash: credentials.hash, plan: 'free', createdAt: new Date().toISOString() };
  db.users.push(user);
  await persist();
  res.status(201).json({ token: tokenFor(user), user: safeUser(user) });
});
app.post('/api/auth/login', (req, res) => {
  const email = String(req.body?.email || '').trim().toLowerCase();
  const password = String(req.body?.password || '');
  const user = db.users.find((u) => u.email === email);
  if (!user || !validPassword(password, user)) return res.status(401).json({ error: 'ایمیل یا رمز عبور نادرست است' });
  if (!AUTH_SECRET) return res.status(503).json({ error: 'تنظیم AUTH_SECRET روی سرور الزامی است' });
  res.json({ token: tokenFor(user), user: safeUser(user) });
});
app.get('/api/me', requireAuth, (req, res) => res.json({ ...safeUser(req.user), aiConfigured: Boolean(AI_API_KEY) }));
app.post('/api/auth/logout', requireAuth, (_req, res) => res.json({ ok: true }));
app.post('/api/chat', requireAuth, async (req, res) => {
  const message = String(req.body?.message || '').trim().slice(0, 4000);
  if (!message) return res.status(400).json({ error: 'پیام الزامی است' });
  try {
    const reply = await callAI(message, req.user.id);
    res.json({ reply, mode: AI_API_KEY ? 'ai' : 'mock' });
  } catch (error) {
    console.error('AI error:', error.message);
    res.status(502).json({ error: 'ارتباط با هوش مصنوعی برقرار نشد' });
  }
});
app.post('/api/chat/reset', requireAuth, async (req, res) => {
  delete db.conversations[req.user.id]; await persist(); res.json({ ok: true });
});
app.get('/api/tasks', requireAuth, (req, res) => res.json({ tasks: userBucket('tasks', req.user.id) }));
app.post('/api/tasks', requireAuth, async (req, res) => {
  const title = String(req.body?.title || '').trim();
  if (!title) return res.status(400).json({ error: 'عنوان وظیفه الزامی است' });
  const task = { id: crypto.randomUUID(), title: title.slice(0, 200), description: String(req.body?.description || '').trim().slice(0, 500), status: 'pending', createdAt: new Date().toISOString() };
  userBucket('tasks', req.user.id).unshift(task); await persist(); res.status(201).json({ success: true, task });
});
app.post('/api/tasks/:id/approve', requireAuth, async (req, res) => {
  const task = userBucket('tasks', req.user.id).find((t) => t.id === req.params.id);
  if (!task) return res.status(404).json({ error: 'وظیفه پیدا نشد' });
  task.status = 'completed'; await persist(); res.json({ success: true, task });
});
app.delete('/api/tasks/:id', requireAuth, async (req, res) => {
  const tasks = userBucket('tasks', req.user.id);
  const index = tasks.findIndex((t) => t.id === req.params.id);
  if (index < 0) return res.status(404).json({ error: 'وظیفه پیدا نشد' });
  tasks.splice(index, 1); await persist(); res.json({ success: true });
});
app.get('/api/goals', requireAuth, (req, res) => res.json({ goals: userBucket('goals', req.user.id) }));
app.post('/api/goals', requireAuth, async (req, res) => {
  const title = String(req.body?.title || '').trim();
  if (!title) return res.status(400).json({ error: 'عنوان هدف الزامی است' });
  const goal = { id: crypto.randomUUID(), title: title.slice(0, 200), target: String(req.body?.target || '').trim().slice(0, 100), progress: 0, createdAt: new Date().toISOString() };
  userBucket('goals', req.user.id).unshift(goal); await persist(); res.status(201).json({ success: true, goal });
});
app.use((err, _req, res, _next) => { console.error(err); res.status(500).json({ error: 'خطای داخلی سرور' }); });
app.listen(PORT, () => {
  console.log('Yar API listening on ' + PORT + '; AI ' + (AI_API_KEY ? 'enabled' : 'mock mode'));
  if (!AUTH_SECRET) console.warn('AUTH_SECRET is missing: authentication endpoints will not issue tokens.');
});
