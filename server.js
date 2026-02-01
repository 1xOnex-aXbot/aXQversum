const express = require('express');
const webpush = require('web-push');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 8080;

// VAPID klíče
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

// Subscriptions storage
const subscriptions = new Map();

// API Routes
app.post('/api/subscribe', (req, res) => {
    const sub = req.body;
    subscriptions.set(sub.endpoint, sub);
    console.log('New subscription, total:', subscriptions.size);
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
            if (err.statusCode === 410) {
                subscriptions.delete(sub.endpoint);
            }
        }
    }
    
    res.json({ sent, total: subscriptions.size });
});

app.get('/api/stats', (req, res) => {
    res.json({
        subscriptions: subscriptions.size,
        uptime: Math.floor(process.uptime()),
        memory: process.memoryUsage(),
        port: PORT
    });
});

app.get('/api/test', async (req, res) => {
    const payload = JSON.stringify({
        title: 'UAIXQ Test',
        body: 'Test notification from server'
    });
    
    let sent = 0;
    for (const sub of subscriptions.values()) {
        try {
            await webpush.sendNotification(sub, payload);
            sent++;
        } catch (err) {
            console.error('Test send failed:', err.message);
        }
    }
    
    res.json({ message: 'Test sent', sent, total: subscriptions.size });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime() });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log('========================================');
    console.log('  UAIXQ Server Running');
    console.log('  Port: ' + PORT);
    console.log('  Subscriptions: ' + subscriptions.size);
    console.log('========================================');
    console.log('');
    console.log('Ready to accept connections!');
});
