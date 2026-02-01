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
