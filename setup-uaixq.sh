#!/bin/bash
set -e

echo "🚀 UAIXQ Setup pro Codespaces"
echo ""

# Vytvoř všechny potřebné soubory
echo "📁 Vytváření souborů..."

# manifest.json
cat > manifest.json << 'EOF_MANIFEST'
{
  "name": "UAIXQ",
  "short_name": "UAIXQ",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#667eea",
  "theme_color": "#667eea",
  "icons": [
    {"src": "/icons/icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "/icons/icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}
EOF_MANIFEST

# Vytvoř icons složku
mkdir -p icons

# Stáhni ikony (placeholder)
curl -s "https://via.placeholder.com/192/667eea/FFFFFF?text=UAIXQ" -o icons/icon-192.png 2>/dev/null || echo "Ikona 192 skip"
curl -s "https://via.placeholder.com/512/667eea/FFFFFF?text=UAIXQ" -o icons/icon-512.png 2>/dev/null || echo "Ikona 512 skip"

# package.json
cat > package.json << 'EOF_PKG'
{
  "name": "uaixq-pwa",
  "version": "1.0.0",
  "description": "UAIXQ Geo-Intelligence",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "web-push": "^3.6.5",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5"
  }
}
EOF_PKG

# index.html - Hlavní stránka
cat > index.html << 'EOF_HTML'
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UAIXQ - Geo Intelligence</title>
    <link rel="manifest" href="/manifest.json">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: white;
            padding: 2rem;
        }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { text-align: center; font-size: 3rem; margin-bottom: 2rem; }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .card {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            transition: transform 0.3s;
            cursor: pointer;
        }
        .card:hover { transform: translateY(-10px); }
        .card-icon { font-size: 3rem; margin-bottom: 1rem; }
        .card-title { font-size: 1.5rem; margin-bottom: 0.5rem; }
        .card-desc { opacity: 0.9; line-height: 1.6; }
        .status {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: rgba(0,0,0,0.5);
            padding: 1rem;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌍 UAIXQ Geo-Intelligence</h1>
        
        <div class="grid">
            <div class="card" onclick="alert('Feature coming soon!')">
                <div class="card-icon">🗺️</div>
                <div class="card-title">Real-Time Maps</div>
                <div class="card-desc">Leaflet.js maps with live tracking</div>
            </div>
            
            <div class="card" onclick="alert('Feature coming soon!')">
                <div class="card-icon">🤖</div>
                <div class="card-title">ML Prediction</div>
                <div class="card-desc">TensorFlow.js location prediction</div>
            </div>
            
            <div class="card" onclick="alert('Feature coming soon!')">
                <div class="card-icon">🔥</div>
                <div class="card-title">Heatmaps</div>
                <div class="card-desc">Density visualization</div>
            </div>
            
            <div class="card" onclick="alert('Feature coming soon!')">
                <div class="card-icon">🌦️</div>
                <div class="card-title">Weather</div>
                <div class="card-desc">Weather-based targeting</div>
            </div>
        </div>
    </div>
    
    <div class="status" id="status">✅ System Ready</div>
    
    <script>
        console.log('UAIXQ loaded!');
        
        // Service Worker
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js')
                .then(() => console.log('✓ SW registered'))
                .catch(err => console.error('SW error:', err));
        }
    </script>
</body>
</html>
EOF_HTML

# Service Worker
cat > sw.js << 'EOF_SW'
const CACHE = 'uaixq-v1';
const FILES = ['/', '/index.html', '/manifest.json'];

self.addEventListener('install', e => {
    e.waitUntil(
        caches.open(CACHE).then(cache => cache.addAll(FILES))
    );
});

self.addEventListener('fetch', e => {
    e.respondWith(
        caches.match(e.request).then(r => r || fetch(e.request))
    );
});

self.addEventListener('push', e => {
    const data = e.data ? e.data.json() : {};
    e.waitUntil(
        self.registration.showNotification(data.title || 'UAIXQ', {
            body: data.body || 'Notification',
            icon: '/icons/icon-192.png'
        })
    );
});
EOF_SW

# Server
cat > server.js << 'EOF_SERVER'
const express = require('express');
const webpush = require('web-push');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// VAPID klíče (vygenerujeme později)
const VAPID_PUBLIC = process.env.VAPID_PUBLIC || '';
const VAPID_PRIVATE = process.env.VAPID_PRIVATE || '';

if (VAPID_PUBLIC && VAPID_PRIVATE) {
    webpush.setVapidDetails(
        'mailto:admin@uaixq.io',
        VAPID_PUBLIC,
        VAPID_PRIVATE
    );
}

app.use(cors());
app.use(bodyParser.json());
app.use(express.static('.'));

// Subscriptions
const subscriptions = new Map();

// API endpoints
app.post('/api/subscribe', (req, res) => {
    const sub = req.body;
    subscriptions.set(sub.endpoint, sub);
    console.log('✓ New subscription');
    res.json({ success: true });
});

app.post('/api/send', async (req, res) => {
    const { title, body } = req.body;
    const payload = JSON.stringify({ title, body });
    
    let sent = 0;
    for (const sub of subscriptions.values()) {
        try {
            await webpush.sendNotification(sub, payload);
            sent++;
        } catch (err) {
            console.error('Send failed:', err.message);
        }
    }
    
    res.json({ sent, total: subscriptions.size });
});

app.get('/api/stats', (req, res) => {
    res.json({
        subscriptions: subscriptions.size,
        uptime: process.uptime()
    });
});

app.listen(PORT, () => {
    console.log(\`
╔════════════════════════════════════════╗
║  🚀 UAIXQ Server Running               ║
║  Port: \${PORT}                           ║
╚════════════════════════════════════════╝
    \`);
});
EOF_SERVER

echo "✓ Soubory vytvořeny"
echo ""
echo "📦 Instaluji npm packages..."
npm install --silent

echo ""
echo "🔑 Generuji VAPID klíče..."
node -e "const wp=require('web-push');const k=wp.generateVAPIDKeys();console.log('export VAPID_PUBLIC='+k.publicKey);console.log('export VAPID_PRIVATE='+k.privateKey)" > .vapid-keys

echo ""
echo "✅ Setup dokončen!"
echo ""
echo "Spusť server příkazem:"
echo "  npm start"
echo ""

