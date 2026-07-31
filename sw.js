const CACHE_NAME = 'slaterun-v1';

const STATIC_ASSETS = [
  '/manifest.json',
  '/icon-192.svg',
  '/icon-512.svg',
  '/icon-maskable.svg',
];

// Cache static assets only. HTML stays network-first so a stale app shell
// can never outlive a deploy.
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(STATIC_ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('message', e => {
  if (e.data?.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  if (e.request.method !== 'GET') return;
  // Never intercept Supabase, CDNs, or any other cross-origin traffic
  if (url.origin !== location.origin) return;

  const accept = e.request.headers.get('accept') || '';
  const isNavigation = e.request.mode === 'navigate' || accept.includes('text/html');
  if (isNavigation || url.pathname === '/' || url.pathname.endsWith('/index.html')) {
    // Network-first with cached fallback so the app still opens offline
    e.respondWith(
      fetch(e.request, { cache: 'no-store' }).then(resp => {
        if (resp.ok) {
          const clone = resp.clone();
          caches.open(CACHE_NAME).then(cache => cache.put('/index.html', clone));
        }
        return resp;
      }).catch(() =>
        caches.match('/index.html').then(cached =>
          cached || new Response('SlateRun needs a connection for first load.', {
            status: 503,
            headers: { 'Content-Type': 'text/plain; charset=utf-8' },
          })
        )
      )
    );
    return;
  }

  // Static assets: cache-first, refresh in background on miss
  e.respondWith(
    caches.match(e.request).then(cached => {
      if (cached) return cached;
      return fetch(e.request).then(resp => {
        if (resp.ok) {
          const clone = resp.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(e.request, clone));
        }
        return resp;
      });
    })
  );
});
