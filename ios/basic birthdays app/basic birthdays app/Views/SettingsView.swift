//
//  SettingsView.swift
//  dead simple birthdays
//
//  Created by ian on 6/7/23.
//

import SwiftUI
import FirebaseMessaging

struct SettingsView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage("NotificationEnabled") private var notificationEnabled = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            Toggle("weekly notifications", isOn: $notificationEnabled)
                .onChange(of: notificationEnabled) { newValue in
                    if newValue {
                        requestNotificationAuthorization { granted in
                            if granted {
                                // Authorization granted, configure and schedule notifications
                                configureNotifications()
                            } else {
                                // Authorization denied or error occurred
                                // Handle accordingly
                                DispatchQueue.main.async {
                                    notificationEnabled = false
                                    showAlert = true
                                }
                            }
                        }
                    } else {
                        disableNotifications {
                            // Notifications disabled, handle accordingly
                        }
                    }
                }
                .padding()
            Text("receive exactly one (1) notification each monday, only if a friend has a birthday that week").font(.system(size: 14)).padding()

            Spacer()

            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("notifications disabled"),
                    message: Text("please enable notifications for this app in your device settings."),
                    primaryButton: .default(Text("settings"), action: goToSettings),
                    secondaryButton: .cancel()
                )
            }
        }

    // Function to request notification authorization
    private func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [self] granted, error in
            if granted {
                DispatchQueue.main.async {
//                    self?.registerForRemoteNotifications()
                    appDelegate.registerForRemoteNotifications()
                    // Messaging.messaging().delegate = self
                    self.didRegisterForRemoteNotifications(with: Data())
                }
            }
            completion(granted)
        }
    }
    
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        // auth
//        if let auth = FUIAuth.defaultAuthUI()?.auth {
//            auth.setAPNSToken(deviceToken, type: .sandbox)
//        }
        
        // messaging
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device token: \(token)")
        
        // Pass the device token to Firebase Cloud Messaging
        Messaging.messaging().apnsToken = deviceToken
    }

    // Function to configure notifications
    private func configureNotifications() {
        FirebaseService.shared.setNotificationEnabled(isEnabled: true) { success in
            if success {
                // Notifications enabled in Firebase, proceed with further configuration
                // ...
            } else {
                // Failed to enable notifications in Firebase, handle accordingly
            }
        }
    }

    // Function to disable notifications
    private func disableNotifications(completion: @escaping () -> Void) {
        FirebaseService.shared.setNotificationEnabled(isEnabled: false) { success in
            if success {
                // Notifications disabled in Firebase, proceed with further actions
                // ...
            } else {
                // Failed to disable notifications in Firebase, handle accordingly
            }
            completion()
        }
    }

    
    private func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    

}

