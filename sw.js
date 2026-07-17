/* SPOTTER AI — service worker (instalable + offline, NETWORK-FIRST para que siempre se actualice) */
const CACHE = "spotter-ai-v3";
const ASSETS = ["./", "./index.html", "./manifest.json",
  "./assets/icon_192.png", "./assets/icon_512.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS).catch(() => {})));
  self.skipWaiting();               // el SW nuevo toma control de inmediato
});

self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(ks =>
    Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))));
  self.clients.claim();
});

/* NETWORK-FIRST: siempre intenta la red (versión fresca); si no hay internet,
   cae al caché. Así "no se me actualiza" ya no vuelve a pasar cuando hay conexión. */
self.addEventListener("fetch", e => {
  if (e.request.method !== "GET") return;
  e.respondWith(
    fetch(e.request).then(res => {
      const cp = res.clone();
      caches.open(CACHE).then(c => c.put(e.request, cp).catch(() => {}));
      return res;
    }).catch(() => caches.match(e.request).then(r => r || caches.match("./index.html")))
  );
});
