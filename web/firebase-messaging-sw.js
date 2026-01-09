importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: "AIzaSyCA8GOoO9G2CvVzlIarAQgPg5hqtH4PSwk",
  authDomain: "smart-habit-health.firebaseapp.com",
  projectId: "smart-habit-health",
  storageBucket: "smart-habit-health.firebasestorage.app",
  messagingSenderId: "412885194702",
  appId: "1:412885194702:web:ba59d05a1fa7e329553d9f",
  measurementId: "G-0PJLB2MSVF"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  const notificationTitle = (payload.notification && payload.notification.title) || 'Reminder';
  const notificationOptions = {
    body: (payload.notification && payload.notification.body) || '',
    icon: '/icons/icon-192.png' // optional
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
