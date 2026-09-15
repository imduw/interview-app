// Default endpoint: proxy path on the same Vercel deployment.
// After you add api/proxy.js and set APPS_SCRIPT_URL on Vercel, leave this as '/api/proxy'.
// If you prefer to call Apps Script directly, replace with full Apps Script URL.
const String kAppsScriptEndpoint = '/api/proxy';

bool get hasAppsScriptEndpoint =>
    kAppsScriptEndpoint.trim().isNotEmpty &&
    !kAppsScriptEndpoint.contains('<YOUR') &&
    !kAppsScriptEndpoint.contains('YOUR_');