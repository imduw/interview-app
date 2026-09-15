Vercel proxy (manual steps)

Why a proxy?
- Browser blocks direct cross-origin POST to script.google.com (CORS preflight).
- A server-side proxy on the same origin (Vercel) forwards requests to Apps Script and avoids CORS.

What you must add to the repo (manual):
1) Create folder `api/` at project root.
2) Create file `api/proxy.js` with this content:

```javascript
// api/proxy.js
// Vercel serverless function: forwards requests to Google Apps Script Web App
// Expects environment variable APPS_SCRIPT_URL set in Vercel project settings.

module.exports = async (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(204).end();

  const appsScriptUrl = process.env.APPS_SCRIPT_URL;
  if (!appsScriptUrl) {
    return res.status(500).json({ success: false, error: 'APPS_SCRIPT_URL not configured on server.' });
  }

  try {
    const body = req.rawBody ? req.rawBody.toString() : (req.body && Object.keys(req.body).length ? JSON.stringify(req.body) : '{}');
    const resp = await fetch(appsScriptUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body,
    });
    const text = await resp.text();
    res.status(resp.status);
    const contentType = resp.headers.get('content-type');
    if (contentType) res.setHeader('Content-Type', contentType);
    return res.send(text);
  } catch (err) {
    return res.status(500).json({ success: false, error: String(err) });
  }
};
```

3) Commit and push to GitHub.

Vercel configuration (manual on Vercel dashboard)
1) In your Vercel project settings -> Environment Variables, add:
   - Key: APPS_SCRIPT_URL
   - Value: <your Apps Script Web App URL from Apps Script deploy>
   - Target: Production (and Preview if you want)
2) Push repo -> Vercel will build and deploy. The serverless function will be available at:
   https://<your-vercel-domain>/api/proxy

Flutter project changes (already applied)
- lib/services/config.dart default endpoint is set to '/api/proxy'.
- This means the app will call the proxy when running from your Vercel-hosted web app.

Local testing notes
- When running locally (flutter run -d chrome), calling '/api/proxy' hits localhost origin, not your Vercel proxy.
- For local testing you can either:
  a) set kAppsScriptEndpoint in lib/services/config.dart to full Apps Script URL (temporary), or
  b) run a local proxy that forwards to Apps Script.

Final steps for you
1. Create api/proxy.js as above and commit
2. Push to GitHub
3. In Vercel, add APPS_SCRIPT_URL environment variable (Apps Script URL)
4. Redeploy (Vercel will build). After deploy, test app on Vercel URL.
5. Create a session in the app and confirm a new row in Google Sheet.

If you want, paste here the Apps Script URL and I will validate the expected flow and give exact commands to rebuild & redeploy web if needed.