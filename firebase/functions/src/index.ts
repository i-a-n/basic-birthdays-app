/* eslint-disable */

const admin = require("firebase-admin");
const functions = require("firebase-functions");

// uncomment to test locally
// var serviceAccount = require("/Users/ian/scratch/cloud-functions-service-account.json");

admin
  .initializeApp
  // uncomment to test locally
  // ({
  // credential: admin.credential.cert(serviceAccount),
  // databaseURL: "https://basic-birthdays-app-default-rtdb.firebaseio.com",
  // });
  // ...and comment out the next line
  ();

type Friends = Record<
  string,
  { name: string; day: number; month: number; year?: number }
>;

exports.sendWeeklyNotifications = functions.pubsub
  .schedule("every monday 09:30")
  .onRun(async () => {
    try {
      const usersSnapshot = await admin.database().ref("/users").once("value");
      const users = usersSnapshot.val();

      for (const userId in users) {
        const user = users[userId];
        const deviceTokens = user.deviceTokens || {};
        const friendsWithBirthdays = friendsWithBirthdaysInTheNextWeek(
          user.friends || {}
        );

        for (const tokenId in deviceTokens) {
          const deviceToken = deviceTokens[tokenId];
          const isNotificationEnabled = deviceToken.notificationEnabled;

          if (isNotificationEnabled && friendsWithBirthdays.length) {
            const notification = createNotification(
              friendsWithBirthdays,
              deviceToken.token
            ); // Create the notification payload
            // Use FCM API to send the notification to the user's device
            console.log(
              "Sending a notification to user",
              userId,
              "with token ID",
              tokenId
            );
            await admin.messaging().send(notification);
          } else {
            console.log(
              "Not sending a notification to user",
              userId,
              "with token",
              tokenId
            );
          }
        }
      }

      console.log("Weekly notifications sent successfully");
      return null;
    } catch (error) {
      console.error("Failed to send weekly notifications:", error);
      return null;
    }
  });

function friendsWithBirthdaysInTheNextWeek(friends: Friends): string[] {
  const today = new Date();
  const nextWeek = new Date();
  nextWeek.setDate(today.getDate() + 7);

  return Object.values(friends)
    .filter((friend) => {
      const friendBirthday = new Date(
        today.getFullYear(),
        friend.month - 1,
        friend.day
      );
      return friendBirthday >= today && friendBirthday <= nextWeek;
    })
    .map((friend) => {
      const birthdayText = getBirthdayText(friend);
      return `${friend.name}${birthdayText}`;
    });
}

function getBirthdayText(friend: {
  day: number;
  month: number;
  year?: number;
}): string {
  const date = new Date();
  date.setDate(friend.day);
  date.setMonth(friend.month - 1);

  const options: Intl.DateTimeFormatOptions = { weekday: "long" }; // Specify weekday option
  const formattedDay = date.toLocaleDateString(undefined, options); // Use formattedDay instead of formattedDate

  return friend.year
    ? ` turns ${
        date.getFullYear() - friend.year
      } on ${formattedDay.toLowerCase()}` // Convert to lowercase
    : `'s birthday is ${formattedDay.toLowerCase()}`; // Convert to lowercase
}

function createNotification(
  friendsWithBirthdays: string[],
  deviceToken: string
) {
  let notificationBody = "";

  if (friendsWithBirthdays.length === 0) {
    notificationBody = "you have no friends with birthdays next week.";
  } else {
    let friendCount = friendsWithBirthdays.length;
    let friendsText = "friends";
    if (friendCount === 1) {
      notificationBody = `you have one friend with a birthday next week: \n`;
      notificationBody += friendsWithBirthdays[0];
    } else if (friendCount > 3) {
      friendsWithBirthdays = friendsWithBirthdays.slice(0, 3);
      friendsText = "friends";

      const remainingFriends = friendCount - 3;
      notificationBody = `you have ${friendCount} ${friendsText} with birthdays next week: \n`;
      notificationBody += friendsWithBirthdays.join("\n");
      notificationBody += `... and ${remainingFriends} more ${friendsText}.`;
    } else {
      notificationBody = `you have ${friendCount} ${friendsText} with birthdays next week: \n`;
      notificationBody += friendsWithBirthdays.join("\n");
    }
  }
  return {
    token: deviceToken,
    notification: {
      title: "basic birthday notification",
      body: notificationBody,
    },
    data: {
      // custom data payload for the notification. note that this doesn't work in
      // the app yet.
      action: "VIEW_BIRTHDAYS",
    },
  };
}
