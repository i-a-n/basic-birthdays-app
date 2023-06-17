//
// LoginView.swift
// basic birthdays app
//
// notes:
//

import FirebasePhoneAuthUI
import SwiftUI

class LoginViewAuthDelegate: NSObject, FUIAuthDelegate {
  var onLogin: (() -> Void)?

  func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
    if (authDataResult?.user) != nil {
      // auth successful, call the function MainView provided
      onLogin?()
    } else {
      // auth failed
      // TODO: display this in the MainView.swift view
      print("error logging in: \(String(describing: error))")
    }
  }
}

struct LoginView: View {
  var onLogin: (() -> Void)
  private let authDelegate = LoginViewAuthDelegate()

  var body: some View {
    VStack {
      Button(action: {
        let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as? FUIPhoneAuth
        phoneProvider?.signIn(
          withPresenting: (UIApplication.shared.windows.first?.rootViewController)!,
          phoneNumber: nil)
      }) {
        Text("login with phone")
      }
      .buttonStyle(.borderedProminent)
      .padding()
      Text(
        "your phone number is only used for logging you in. it will never be saved anywhere else or used for anything else, ever."
      ).font(.system(size: 14)).multilineTextAlignment(.center).padding([.leading, .trailing], 28)

    }
    .onAppear {
      authDelegate.onLogin = onLogin
      FUIAuth.defaultAuthUI()?.delegate = authDelegate
    }
  }
}
