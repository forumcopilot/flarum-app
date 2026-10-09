// Sets the app's rendering of the formatting samples beside the web's.
//
// The app side comes from flarum_ui's screenshot test, which writes
// packages/flarum_ui/build/render/app_<version>_<sample>.png. This script
// screenshots the same posts on the forum, as a guest, in headless Chromium at
// a Pixel's width, and writes one comparison sheet per version:
//
//   (cd packages/flarum_ui && flutter test --run-skipped -t render test/render/screenshots_test.dart)
//   npm install playwright@1.48.2 && npx playwright install chromium
//   node tool/render_compare/compare.mjs v1 http://127.0.0.1:8081 /var/www/flarumapp/tools/formatting-v1.json
//
// Output: packages/flarum_ui/build/render/web_<version>_<sample>.png and
// compare_<version>.png (sample, app, web), at 2x, 412 CSS pixels wide.
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { chromium } from 'playwright';

const [version, base, idsFile] = process.argv.slice(2);
if (!version || !base || !idsFile) {
  console.error('usage: node compare.mjs <v1|v2> <forum url> <formatting ids json>');
  process.exit(64);
}
const ids = JSON.parse(readFileSync(idsFile, 'utf8'));
const out = new URL('../../packages/flarum_ui/build/render/', import.meta.url).pathname;

const browser = await chromium.launch();
const context = await browser.newContext({
  viewport: { width: 412, height: 915 },
  deviceScaleFactor: 2,
  isMobile: true,
  hasTouch: true,
  colorScheme: 'light',
});
const page = await context.newPage();
await page.goto(`${base}/d/${ids.discussion}`, { waitUntil: 'networkidle' });

const rows = [];
for (const [name, postId] of Object.entries(ids.posts)) {
  const body = page.locator(`.PostStream-item[data-id="${postId}"] .Post-body`);
  try {
    await body.scrollIntoViewIfNeeded({ timeout: 10000 });
    await page.waitForTimeout(400);
    await body.screenshot({ path: `${out}web_${version}_${name}.png` });
  } catch (e) {
    console.error(`${name}: ${e.message.split('\n')[0]}`);
  }
  rows.push(name);
}

const cell = (file) => (existsSync(`${out}${file}`) ? `<img src="file://${out}${file}">` : '<em>missing</em>');
const html = `<!doctype html><meta charset=utf-8><style>
  body { font: 14px system-ui, sans-serif; margin: 16px; background: #fff; }
  table { border-collapse: collapse; } td, th { vertical-align: top; padding: 8px; border-bottom: 1px solid #ddd; }
  img { width: 412px; display: block; outline: 1px solid #eee; } th { text-align: left; }
</style><table><tr><th>${version}</th><th>App (FlarumContent)</th><th>Web (${base})</th></tr>
${rows.map((n) => `<tr><td>${n}</td><td>${cell(`app_${version}_${n}.png`)}</td><td>${cell(`web_${version}_${n}.png`)}</td></tr>`).join('\n')}
</table>`;
writeFileSync(`${out}compare_${version}.html`, html);
const sheet = await browser.newPage({ viewport: { width: 1000, height: 800 }, deviceScaleFactor: 1 });
await sheet.goto(`file://${out}compare_${version}.html`);
await sheet.waitForTimeout(500);
await sheet.screenshot({ path: `${out}compare_${version}.png`, fullPage: true });
await browser.close();
console.log(`Wrote ${out}compare_${version}.png`);
