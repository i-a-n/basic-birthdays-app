import FirebaseAuthUI
import FirebaseCore
import FirebaseMessaging
import FirebasePhoneAuthUI
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, FUIAuthDelegate,
  UNUserNotificationCenterDelegate, MessagingDelegate
{
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()

    // init auth (FirebaseAuthUI)
    let authUI = FUIAuth.defaultAuthUI()

    let providers: [FUIAuthProvider] = [
      FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
    ]
    authUI?.providers = providers
    authUI?.delegate = self

    // init messaging (Firebase Cloud Messaging)
    Messaging.messaging().delegate = self

    return true
  }

  // this is called when a user enables notifications on the system
  func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  // for debugging. uncomment to see console messaging.
  // func application(
  //   _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  // ) {
  //   print("Failed to register for remote notifications with error: \(error.localizedDescription)")
  // }

  // for debugging. uncomment to see console messaging.
  // func application(
  //   _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
  //   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  // ) {
  //   print("Received remote notification: \(userInfo)")
  // }

  // for auth flow. I believe this is part of the "captcha" redirects/callbacks.
  func application(
    _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
    if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
      return true
    }
    // other URL handling goes here.
    return false
  }

  // I'm led to believe that this is called every time the app starts, and may result in a new
  // token for this device. it is unclear to me why we do not call
  // `Messaging.messaging().apnsToken = deviceToken` here, but rather we call it a few lines
  // above, in much more limited circumstances. however, this is what both the Firebase
  // documentation and chatGPT recommended, so here we go.
  //
  // if we see major bugginess, with messages not being delivered to many users, this COULD
  // be one source of the problem.
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let token = fcmToken else {
      return
    }

    FirebaseService.shared.setDeviceToken(token: token)
  }

  // helper method that serttingsview.swift will call when a user enables notifications
  func registerForRemoteNotifications() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }

}

@main
struct BasicBirthdaysApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      MainView()
    }
  }
}
