import SwiftUI
import FirebasePhoneAuthUI
import FirebaseCore
import FirebaseAuthUI
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, FUIAuthDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
      // auth
      let authUI = FUIAuth.defaultAuthUI()
      
      let providers: [FUIAuthProvider] = [
        FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!),
      ]
      authUI?.providers = providers
      // You need to adopt a FUIAuthDelegate protocol to receive callback
      authUI?.delegate = self
      
      // notifications
      // Request authorization for user notifications
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
          if let error = error {
              print("Failed to request authorization for user notifications: \(error.localizedDescription)")
          } else {
              print("Authorization for user notifications granted: \(granted)")
          }
      }
      
      // Register for remote notifications
      application.registerForRemoteNotifications()
      Messaging.messaging().delegate = self


    return true
  }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // auth
        if let auth = FUIAuth.defaultAuthUI()?.auth {
            auth.setAPNSToken(deviceToken, type: .sandbox)
        }
        
        // messaging
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device token: \(token)")
        
        // Pass the device token to Firebase Cloud Messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let auth = FUIAuth.defaultAuthUI()?.auth {
            auth.canHandleNotification(userInfo)
        }
        
        //debug
        print("Received remote notification: \(userInfo)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {
            return
        }
        print("FCM registration token: \(token)")
        
        // Use the registration token as needed
        // For example, send it to your server to associate it with the user
    }
    
    
}

@main
struct YourAppNameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(loginViewModel)
        }
    }
}
