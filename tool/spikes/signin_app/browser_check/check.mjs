// Runs assets/signin.js in headless Chromium against a forum, the way the app's
// web view does, and checks that signing in leaves a usable <prefix>_remember cookie.
// A desktop browser stand-in for the phone: it validates the script and the flow,
// not the Android or iOS web view itself.
//
//   npm install playwright@1.48.2 && npx playwright install chromium
//   FLARUM_TEST_USER=alice FLARUM_TEST_PASSWORD=… node check.mjs http://127.0.0.1:8081
import { readFileSync } from 'node:fs';
import { chromium, devices } from 'playwright';

const base = process.argv[2];
const user = process.env.FLARUM_TEST_USER;
const password = process.env.FLARUM_TEST_PASSWORD;
if (!base || !user || !password) {
  console.error('usage: FLARUM_TEST_USER=… FLARUM_TEST_PASSWORD=… node check.mjs <forum url>');
  process.exit(64);
}
const script = readFileSync(new URL('../assets/signin.js', import.meta.url), 'utf8');

const browser = await chromium.launch();
const context = await browser.newContext({ ...devices['Pixel 7'] });
const page = await context.newPage();
page.on('console', (m) => m.text().startsWith('signinStatus') && console.log('  page:', m.text()));
const started = Date.now();

await page.goto(base, { waitUntil: 'networkidle' });
await page.evaluate(script);
await page.evaluate((fill) => window.flarumAppSignIn.start(fill), { identification: user, password });
await page.waitForSelector('.LogInModal input[name=password]');
const captcha = await page.$('.LogInModal iframe[src*="challenges.cloudflare.com"], .LogInModal .cf-turnstile, .LogInModal [class*=urnstile]');
console.log(`  Turnstile widget in the modal: ${captcha ? 'yes' : 'no'}`);
if (captcha) await page.waitForTimeout(4000); // the test site key passes on its own after a moment

// The reader's tap on "Log In".
await page.click('.LogInModal button[type=submit]');

let remember;
for (let i = 0; i < 40 && !remember; i++) {
  remember = (await context.cookies(base)).find((c) => c.name.endsWith('_remember'));
  if (!remember) await page.waitForTimeout(250);
}
if (!remember) {
  const error = await page.$eval('.Alert, .Modal-alert', (e) => e.textContent).catch(() => null);
  console.log(`  FAIL: no *_remember cookie${error ? ` (forum says: ${error.trim()})` : ''}`);
  await browser.close();
  process.exit(1);
}
console.log(`  cookie ${remember.name} captured after ${Date.now() - started} ms (httpOnly=${remember.httpOnly})`);

const response = await fetch(`${base}/api`, { headers: { Authorization: `Token ${remember.value}` } });
const body = await response.json();
const actorId = body.data.relationships.actor?.data?.id;
const actor = body.included?.find((r) => r.type === 'users' && r.id === actorId);
console.log(`  GET /api with it as a header token: HTTP ${response.status}, actor ${actor?.attributes.username ?? 'none'}`);
await browser.close();
process.exit(actor?.attributes.username === user ? 0 : 1);
