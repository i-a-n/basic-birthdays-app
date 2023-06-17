//
// SettingsView.swift
// basic birthdays app
//
// notes:
//

import FirebaseMessaging
import SwiftUI

struct SettingsView: View {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  // my interpretation of this code is that there is a native iOS storage system in which
  // we are keeping a `NotificationEnabled` constant, defaulting to `false`, which will
  // set the on/off value of the `notificationEnabled` switch below when a user loads the
  // settings page. any further updates to the `notificationEnabled` var will update this
  // in the iOS storage system, I am led to believe.
  @AppStorage("NotificationEnabled") private var notificationEnabled = false

  @State private var showAlert = false

  var body: some View {
    VStack {
      Toggle("weekly notifications", isOn: $notificationEnabled)
        .onChange(of: notificationEnabled) { newValue in
          // if they've turned it "on":
          if newValue {
            // request to send notifications. if they accept, or if it was already
            // authorized to send notifications, `granted` will be `true`.
            requestNotificationAuthorization { granted in
              if granted {
                configureNotifications()
              } else {
                // authorization denied, so let's tell them they
                // need to authorize notifications manually in Settings, and ensure
                // local `notificationEnabled` value is false. note that we aren't
                // "unsetting" the value in Firebase, partially because I don't see
                // how they could deny the request for notifications but already have
                // a device token set? potential future bugginess could be found here.
                disableNotifications()
                DispatchQueue.main.async {
                  notificationEnabled = false
                  showAlert = true
                }
              }
            }
          } else {
            disableNotifications()
          }
        }
        .padding()
      Text(
        "receive exactly one (1) notification each monday on this device, but only if one of your friends has a birthday coming up that week"
      ).font(.system(size: 14)).padding()

      Spacer()

    }.alert(isPresented: $showAlert) {
      Alert(
        title: Text("notifications disabled"),
        message: Text("please enable notifications for this app in your device settings"),
        primaryButton: .default(Text("settings"), action: goToSettings),
        secondaryButton: .cancel()
      )
    }
  }

  // this pops up a system notification to let the user authorize notifications. if they accept,
  // it calls the appDelegate function which generates a deviceToken and sends it to apple's APNs
  // system. if they do not accept, it returns false.
  private func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      [self] granted, error in
      if granted {
        DispatchQueue.main.async {
          appDelegate.registerForRemoteNotifications()
        }
      }
      completion(granted)
    }
  }

  // turn on notifications for this device in Firebase
  private func configureNotifications() {
    FirebaseService.shared.setNotificationEnabled(isEnabled: true) { success in
      if success {
        // TODO: log success?
      } else {
        // TODO: log failure? unset the item? unsure.
      }
    }
  }

  // turn off notifications for this device in Firebase
  private func disableNotifications() {
    FirebaseService.shared.setNotificationEnabled(isEnabled: false) { success in
      if success {
        // TODO: log success?
      } else {
        // TODO: log failure? reset the item? unsure.
      }
    }
  }

  // helper function that generates a link that'll take the user to their settings for this app
  private func goToSettings() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl)
    }
  }

}
