# إعادة توليد outro.mp4

ملفات المصدر لإنتاج `../outro.mp4` (الخاتمة الموحدة المعتمدة لـ SKAMS YAMS).

## المتطلبات

- Node.js + حزمة `playwright` (مع متصفح Chromium مثبت).
- `ffmpeg` على PATH.

## التوليد

```sh
cd templates/outro/render
node render.js
```

يرندر السكريبت 105 فريم (30fps × 3.5 ثانية) من `outro.html` حسب التوقيت في `../OUTRO_STORYBOARD.md`، ثم يجمعها بـ ffmpeg إلى `../outro.mp4` مباشرة.

## الملفات

| الملف | الدور |
|---|---|
| `outro.html` | التصميم والحركة (CSS + JS)، يحاكي حرفياً توقيت `OUTRO_STORYBOARD.md` |
| `render.js` | يفتح الصفحة بـ Playwright، يضبط الوقت فريم بفريم، ويرندر الفيديو النهائي |
| `fonts/` | خطوط Cairo و Montserrat محلياً (لتجنب الاعتماد على الإنترنت أثناء الرندر) |

## تعديل الخاتمة لاحقاً

أي تغيير على التصميم أو التوقيت يُعدَّل في `outro.html` أولاً (ويُحدَّث `OUTRO_STORYBOARD.md` إذا تغيّر التوقيت)، ثم `node render.js` لإعادة توليد `outro.mp4`. لا يُستبدل `outro.mp4` المعتمد دون موافقة.
