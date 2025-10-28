const functions = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// /s/{code} → Firestore short/{code} の url に 302 リダイレクト
exports.s = functions.onRequest({region: "asia-northeast1"}, async (req, res) => {
  try {
    const segments = req.path.split("/");
    const code = segments[segments.length - 1] || "";
    if (!code) {
      res.status(400).send("Bad Request");
      return;
    }

    const doc = await db.collection("short").doc(code).get();
    if (!doc.exists) {
      res.status(404).send("Not Found");
      return;
    }
    const data = doc.data() || {};
    const url = data.url;
    const urls = data.urls;
    const expiresAt = Number(data.expiresAt || 0);
    const now = Date.now();
    // 単一 or 複数URLに対応（2枚ある場合は同一ページに画像をインライン表示）
    if (Array.isArray(urls) && urls.length >= 2) {
      res.set("Content-Type", "text/html; charset=utf-8");
      res.set("Cache-Control", "no-store");
      res.status(200).send(`<!doctype html>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Quick Card</title>
      <style>
        body{margin:16px;font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial}
        .img{width:100%;height:auto;display:block;margin:0 0 16px 0;border:1px solid #eee;border-radius:4px}
        .label{margin:8px 0 4px 0;color:#555;font-size:14px}
      </style>
    </head>
    <body>
      <div class="label">Front</div>
      <img class="img" src="${urls[0]}" alt="Front">
      <div class="label">Back</div>
      <img class="img" src="${urls[1]}" alt="Back">
    </body>
  </html>`);
      return;
    }
    const target = url || (Array.isArray(urls) && urls.length > 0 ? urls[0] : null);
    if (!target) { res.status(500).send("Invalid target"); return; }
    if (expiresAt && now > expiresAt) {
      res.status(410).send("Expired");
      return;
    }

    res.set("Cache-Control", "no-store");
    res.redirect(302, target);
  } catch (e) {
    res.status(500).send("Internal Error");
  }
});


