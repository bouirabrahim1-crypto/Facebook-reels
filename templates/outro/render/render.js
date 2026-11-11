const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const FPS = 30;
const DURATION = 3.5;
const TOTAL_FRAMES = Math.round(FPS * DURATION);
const OUT_DIR = path.join(__dirname, '_frames_tmp');
const OUT_VIDEO = path.join(__dirname, '..', 'outro.mp4');

(async () => {
  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR);

  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1080, height: 1920 } });
  await page.goto('file://' + path.join(__dirname, 'outro.html'));
  await page.waitForFunction(() => document.fonts.status === 'loaded');

  for (let i = 0; i < TOTAL_FRAMES; i++) {
    const t = i / FPS;
    await page.evaluate((t) => window.__setTime(t), t);
    const frameName = String(i).padStart(4, '0') + '.png';
    await page.screenshot({ path: path.join(OUT_DIR, frameName) });
  }

  await browser.close();
  console.log('Rendered', TOTAL_FRAMES, 'frames to', OUT_DIR);

  const { execSync } = require('child_process');
  execSync(
    `ffmpeg -y -framerate ${FPS} -i "${OUT_DIR}/%04d.png" -c:v libx264 -pix_fmt yuv420p -crf 18 -r ${FPS} "${OUT_VIDEO}"`,
    { stdio: 'inherit' }
  );
  fs.rmSync(OUT_DIR, { recursive: true, force: true });
  console.log('Wrote', OUT_VIDEO);
})();
