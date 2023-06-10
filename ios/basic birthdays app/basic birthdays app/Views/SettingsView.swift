//
//  SettingsView.swift
//  dead simple birthdays
//
//  Created by ian on 6/7/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("NotificationEnabled") private var notificationEnabled = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            Section() {
                Toggle("Weekly Notifications", isOn: $notificationEnabled)
                    .onChange(of: notificationEnabled) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "NotificationEnabled")
                        if newValue {
                            // Request authorization and configure notifications
                            requestNotificationAuthorization()
                        } else {
                            // Disable notifications
                            disableNotifications()
                        }
                    }
                    .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Notifications Disabled"),
                    message: Text("Please enable notifications for this app in Settings."),
                    primaryButton: .default(Text("Settings"), action: goToSettings),
                    secondaryButton: .cancel()
                )
            }
            Spacer()
        }
    }

    // Function to request notification authorization
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                // Authorization granted, configure and schedule notifications
                configureNotifications()
            } else {
                // Authorization denied or error occurred
                // Handle accordingly
                print("let's pop up an alert")
                DispatchQueue.main.async {
                    notificationEnabled = false
                    showAlert = true

                }
            }
        }
    }


    // Function to configure notifications
    private func configureNotifications() {
        // Implement your code to configure and schedule notifications
        // based on the desired logic for weekly notifications
        print("configure notifications")
        scheduleWeeklyNotificationTrigger()
    }

    // Function to disable notifications
    private func disableNotifications() {
        // Implement your code to disable or remove any scheduled notifications
        print("un-configure notifications?")
    }
    
    private func goToSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func scheduleWeeklyNotificationTrigger() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = 5 // Monday
        dateComponents.hour = 10
        dateComponents.minute = 1

        guard let nextMonday = calendar.nextDate(after: Date(), matching: dateComponents, matchingPolicy: .nextTime) else {
            return
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.weekday, .hour, .minute], from: nextMonday), repeats: true)
        let request = UNNotificationRequest(identifier: "WeeklyNotificationTrigger", content: UNMutableNotificationContent(), trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule weekly notification trigger: \(error.localizedDescription)")
            } else {
                print("Weekly notification trigger scheduled for Monday at 12:00 AM.")
            }
        }
    }
    
    private func evaluateWeeklyNotification() {
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Weekly Notification"
        content.body = "This is your weekly notification message."
        content.sound = .default

        // Configure the notification trigger for 8 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 5 // Monday
        dateComponents.hour = 10
        dateComponents.minute = 2
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create the request identifier
        let requestIdentifier = "WeeklyNotification"

        // Create the notification request
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)

        // Check if the condition is true before scheduling the notification
        let isConditionMet = true // Replace with your own logic to determine if the condition is met
        if isConditionMet {
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // Failed to schedule the notification
                    print("Failed to schedule notification: \(error.localizedDescription)")
                } else {
                    // Notification scheduled successfully
                    print("Weekly notification scheduled.")
                }
            }
        } else {
            // Remove any previously scheduled notification with the same request identifier
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
            print("Weekly notification canceled.")
        }
    }

}

