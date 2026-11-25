// Generic scene renderer: node render_scene.js <html_file> <duration_seconds> <output_mp4>
// The HTML page must define window.__setTime(t) like templates/outro/render/outro.html does.
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

const [,, htmlFile, durationArg, outputPath] = process.argv;
if (!htmlFile || !durationArg || !outputPath) {
  console.error('usage: node render_scene.js <html_file> <duration_seconds> <output_mp4>');
  process.exit(1);
}

const FPS = 30;
const DURATION = parseFloat(durationArg);
const TOTAL_FRAMES = Math.round(FPS * DURATION);
const FRAMES_DIR = path.join(__dirname, '_frames_' + path.basename(htmlFile, '.html'));

(async () => {
  if (fs.existsSync(FRAMES_DIR)) fs.rmSync(FRAMES_DIR, { recursive: true, force: true });
  fs.mkdirSync(FRAMES_DIR);

  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 } });
  await page.goto('file://' + path.resolve(htmlFile));
  await page.waitForFunction(() => document.fonts.status === 'loaded');

  for (let i = 0; i < TOTAL_FRAMES; i++) {
    const t = i / FPS;
    await page.evaluate((t) => window.__setTime(t), t);
    const frameName = String(i).padStart(4, '0') + '.png';
    await page.screenshot({ path: path.join(FRAMES_DIR, frameName) });
  }
  await browser.close();

  execSync(
    `ffmpeg -y -framerate ${FPS} -i "${FRAMES_DIR}/%04d.png" -c:v libx264 -pix_fmt yuv420p -crf 18 -r ${FPS} "${outputPath}"`,
    { stdio: 'inherit' }
  );
  fs.rmSync(FRAMES_DIR, { recursive: true, force: true });
  console.log('Wrote', outputPath, '(' + TOTAL_FRAMES + ' frames, ' + DURATION + 's)');
})();
