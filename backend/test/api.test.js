const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');

const port = 38000 + Math.floor(Math.random() * 10000);
const base = 'http://127.0.0.1:' + port;
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'yar-api-'));
let server;

async function request(route, options = {}) {
  return fetch(base + route, {
    ...options,
    headers: { ...(options.headers || {}), ...(options.body ? { 'Content-Type': 'application/json' } : {}) },
  });
}
async function register(email, name) {
  const response = await request('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({ name, email, password: 'secure-pass-123' }),
  });
  assert.equal(response.status, 201);
  return (await response.json()).token;
}

before(async () => {
  server = spawn(process.execPath, ['server.js'], {
    cwd: __dirname + '/..',
    env: { ...process.env, PORT: String(port), AUTH_SECRET: 'test-secret-that-is-long-enough', YAR_DATA_FILE: path.join(tempDir, 'data.json') },
    stdio: 'ignore',
  });
  let ready = false;
  for (let i = 0; i < 60; i++) {
    try {
      const r = await fetch(base + '/api/health');
      if (r.ok) { ready = true; break; }
    } catch {}
    await new Promise((resolve) => setTimeout(resolve, 150));
  }
  assert.equal(ready, true, 'API server did not start');
});

after(() => {
  if (server) server.kill();
  fs.rmSync(tempDir, { recursive: true, force: true });
});

test('private routes require authentication', async () => {
  const response = await request('/api/tasks');
  assert.equal(response.status, 401);
});

test('accounts keep tasks isolated and data persists', async () => {
  const tokenA = await register('first@example.com', 'First');
  const tokenB = await register('second@example.com', 'Second');
  const created = await request('/api/tasks', {
    method: 'POST',
    headers: { Authorization: 'Bearer ' + tokenA },
    body: JSON.stringify({ title: 'My private task' }),
  });
  assert.equal(created.status, 201);
  const listA = await request('/api/tasks', { headers: { Authorization: 'Bearer ' + tokenA } });
  const listB = await request('/api/tasks', { headers: { Authorization: 'Bearer ' + tokenB } });
  assert.equal((await listA.json()).tasks.length, 1);
  assert.equal((await listB.json()).tasks.length, 0);
  assert.equal(fs.existsSync(path.join(tempDir, 'data.json')), true);
});

test('duplicate account email is rejected', async () => {
  const response = await request('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({ name: 'Again', email: 'first@example.com', password: 'secure-pass-123' }),
  });
  assert.equal(response.status, 409);
});
