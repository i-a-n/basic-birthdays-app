//
// LoginUtilities.swift
// basic birthdays app
//
// notes: chat robot wrote this
//

import Foundation

class LoginUtilities {
  // returns whether a user has authed within the last 5 minutes
  static func hasAuthenticatedRecently() -> Bool {
    guard let lastAuthTimestamp = getLastAuthTimestamp() else {
      // no last authentication timestamp available
      return false
    }

    let fiveMinutesInSeconds: TimeInterval = 300
    let currentTime = Date().timeIntervalSince1970
    let timeDifference = currentTime - lastAuthTimestamp

    return timeDifference <= fiveMinutesInSeconds
  }

  static func getLastAuthTimestamp() -> TimeInterval? {
    // retrieve the last authentication timestamp from your app's storage
    let lastAuthTimestamp = UserDefaults.standard.double(forKey: "LastAuthTimestamp")
    return lastAuthTimestamp > 0 ? lastAuthTimestamp : nil
  }

  static func storeLastAuthTimestamp() {
    let currentTimestamp = Date().timeIntervalSince1970
    UserDefaults.standard.set(currentTimestamp, forKey: "LastAuthTimestamp")
  }
}
