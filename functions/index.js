const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.scheduleNotification = functions.pubsub
    .schedule("every day 08:00")
    .timeZone("Asia/Colombo")
    .onRun(async () => {
      const payload = {
        notification: {
          title: "Daily Habit Reminder",
          body: "Don’t forget your habits!",
        },
      };

      const tokensSnapshot = await admin.firestore()
          .collection("fcm_tokens")
          .get();

      const tokens = tokensSnapshot.docs.map((doc) => doc.id);
      if (tokens.length > 0) {
        await admin.messaging().sendToDevice(tokens, payload);
      }

      return null;
    });
