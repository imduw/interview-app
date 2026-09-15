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