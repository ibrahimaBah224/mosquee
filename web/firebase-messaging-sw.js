// Service Worker Firebase pour les notifications push web
// Ce fichier permet de recevoir des notifications même quand le site n'est pas ouvert

// Import Firebase scripts
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Configuration Firebase (même que dans l'app)
const firebaseConfig = {
  apiKey: 'AIzaSyCLB-F-sHmVZgTO4ukY8OplFkHMHMBO2ys',
  authDomain: 'mosquee-64c87.firebaseapp.com',
  projectId: 'mosquee-64c87',
  storageBucket: 'mosquee-64c87.firebasestorage.app',
  messagingSenderId: '775213541089',
  appId: '1:775213541089:web:00c26e4a5e7a23c3f579a0'
};

// Initialiser Firebase
firebase.initializeApp(firebaseConfig);

// Initialiser Firebase Messaging
const messaging = firebase.messaging();

// Gestion des notifications en arrière-plan
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  // Personnaliser la notification
  const notificationTitle = payload.notification.title || 'MOMED';
  const notificationOptions = {
    body: payload.notification.body || 'Nouvelle notification de la mosquée',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data,
    tag: 'momed-notification',
    renotify: true,
    requireInteraction: true,
    actions: [
      {
        action: 'open',
        title: 'Ouvrir l\'app',
        icon: '/icons/Icon-192.png'
      },
      {
        action: 'dismiss',
        title: 'Ignorer'
      }
    ],
    vibrate: [100, 50, 100],
    silent: false,
  };

  // Afficher la notification
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Gestion des clics sur les notifications
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  
  event.notification.close();
  
  // Gestion des actions
  if (event.action === 'dismiss') {
    return;
  }
  
  // Ouvrir ou focus sur l'application
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      const data = event.notification.data || {};
      
      // Construire l'URL de destination selon le type de notification
      let targetUrl = '/';
      
      if (data.type) {
        switch (data.type) {
          case 'prayer_times_changed':
            targetUrl = '/prayer-times';
            break;
          case 'new_event':
            targetUrl = '/events';
            break;
          case 'new_donation_campaign':
            targetUrl = '/donations';
            break;
          case 'new_staff_member':
            targetUrl = data.staff_type === 'imam' ? '/imams' : '/muezzins';
            break;
          case 'general_announcement':
            targetUrl = '/';
            break;
          default:
            targetUrl = '/';
        }
      }
      
      // Chercher une fenêtre ouverte
      for (let i = 0; i < clientList.length; i++) {
        const client = clientList[i];
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          client.focus();
          client.postMessage({
            type: 'NOTIFICATION_CLICK',
            data: data,
            targetUrl: targetUrl
          });
          return;
        }
      }
      
      // Ouvrir une nouvelle fenêtre si aucune n'est ouverte
      if (clients.openWindow) {
        return clients.openWindow(self.location.origin + targetUrl);
      }
    })
  );
});

// Gestion des erreurs
self.addEventListener('error', function(event) {
  console.error('[firebase-messaging-sw.js] Error:', event.error);
});

// Log d'installation du service worker
self.addEventListener('install', function(event) {
  console.log('[firebase-messaging-sw.js] Service worker installed');
  self.skipWaiting();
});

// Log d'activation du service worker
self.addEventListener('activate', function(event) {
  console.log('[firebase-messaging-sw.js] Service worker activated');
  event.waitUntil(self.clients.claim());
});

// Heartbeat pour maintenir le service worker actif
setInterval(() => {
  console.log('[firebase-messaging-sw.js] Service worker heartbeat');
}, 30000); // Toutes les 30 secondes 