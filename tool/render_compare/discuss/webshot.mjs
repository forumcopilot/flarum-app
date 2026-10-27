// Screenshots posts on discuss.flarum.org as the web shows them on a phone, through the Chrome
// that's installed (its DevTools protocol over Node's built-in WebSocket; nothing downloaded).
//
//   node webshot.mjs samples.json outdir [body|post]
//
// samples.json: {"name": {"discussion": "123", "number": 4}, ...}. Writes outdir/web_<name>.png,
// 412 CSS pixels wide at 2x, light mode, as a guest.
import { spawn } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';

const [samplesFile, outDir, part = 'body'] = process.argv.slice(2);
const samples = JSON.parse(readFileSync(samplesFile, 'utf8'));
mkdirSync(outDir, { recursive: true });
const port = 9333;
const chrome = spawn('/Applications/Google Chrome.app/Contents/MacOS/Google Chrome', [
  '--headless=new', `--remote-debugging-port=${port}`, `--user-data-dir=${outDir}/.chrome-profile`,
  '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', 'about:blank',
], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

let tab;
for (let i = 0; i < 50 && !tab; i++) {
  await sleep(200);
  try {
    tab = (await (await fetch(`http://127.0.0.1:${port}/json/list`)).json()).find((t) => t.type === 'page');
  } catch {}
}
const ws = new WebSocket(tab.webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let nextId = 0;
const pending = new Map();
ws.addEventListener('message', (e) => {
  const msg = JSON.parse(e.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg);
    pending.delete(msg.id);
  }
});
const send = (method, params = {}) => new Promise((resolve) => {
  const id = ++nextId;
  pending.set(id, resolve);
  ws.send(JSON.stringify({ id, method, params }));
});
const evaluate = async (expression) =>
  (await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true })).result?.result?.value;

await send('Page.enable');
await send('Emulation.setDeviceMetricsOverride', { width: 412, height: 915, deviceScaleFactor: 2, mobile: true });
await send('Emulation.setUserAgentOverride', {
  userAgent: 'Mozilla/5.0 (Linux; Android 15; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36',
});
await send('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] });

for (const [name, { discussion, number }] of Object.entries(samples)) {
  await send('Page.navigate', { url: `https://discuss.flarum.org/d/${discussion}/${number}` });
  const selector = `.PostStream-item[data-number="${number}"] ${part === 'post' ? '.Post' : '.Post-body'}`;
  let rect = null;
  for (let i = 0; i < 60 && !rect; i++) {
    await sleep(500);
    rect = await evaluate(`(() => { const e = document.querySelector(${JSON.stringify(selector)});
      if (!e) return null; e.scrollIntoView({block: 'start'}); return true; })()`);
  }
  if (!rect) {
    console.error(`${name}: not found`);
    continue;
  }
  // The site's cookie banner: Decline (the privacy-preserving choice), remembered in this profile.
  await evaluate(`(() => { const b = [...document.querySelectorAll('button')].find((x) => x.textContent.trim() === 'Decline');
    if (b) b.click(); })()`);
  // Pictures and embeds load, then measure where it ended up.
  await sleep(2500);
  const box = await evaluate(`(() => { const e = document.querySelector(${JSON.stringify(selector)});
    const r = e.getBoundingClientRect(); return {x: r.left + scrollX, y: r.top + scrollY, w: r.width, h: r.height}; })()`);
  const shot = await send('Page.captureScreenshot', {
    format: 'png', captureBeyondViewport: true,
    clip: { x: Math.max(0, box.x - 8), y: Math.max(0, box.y - 8), width: Math.min(412, box.w + 16), height: Math.min(box.h + 16, 6000), scale: 1 },
  });
  writeFileSync(`${outDir}/web_${name}.png`, Buffer.from(shot.result.data, 'base64'));
  console.log(`${name}: ${Math.round(box.h)}px`);
}
ws.close();
chrome.kill();
