// Default endpoint: proxy path on the same Vercel deployment.
// After you add api/proxy.js and set APPS_SCRIPT_URL on Vercel, leave this as '/api/proxy'.
// If you prefer to call Apps Script directly, replace with full Apps Script URL.
// const String kAppsScriptEndpoint = '/api/proxy';
const String kAppsScriptEndpoint = 'https://script.google.com/macros/s/AKfycbwegaVvAdDxO727cIWz7yiWa1xwgA--H74tz9MQgMG5ff5V08XJx8L9QJ_-mBMnMJosXw/exec';

bool get hasAppsScriptEndpoint =>
    kAppsScriptEndpoint.trim().isNotEmpty &&
    !kAppsScriptEndpoint.contains('<YOUR') &&
    !kAppsScriptEndpoint.contains('YOUR_');