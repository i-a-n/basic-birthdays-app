//
//  LoginView.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import SwiftUI
import FirebasePhoneAuthUI

class LoginViewAuthDelegate: NSObject, FUIAuthDelegate {
    var onLogin: (() -> Void)?
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let user = authDataResult?.user {
            // Authentication successful
            // Handle the authenticated user, perform necessary actions, etc.
            onLogin?() // Call the provided onLogin closure
            print("logged in")
        } else {
            // Authentication failed
            // Handle the error
            print("NOT logged in")
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    var onLogin: (() -> Void)  // Add the onLogin closure
    private let authDelegate = LoginViewAuthDelegate()

    var body: some View {
        VStack {
            Button(action: {
                // Perform Firebase Phone Authentication
                let phoneProvider = FUIAuth.defaultAuthUI()?.providers.first as? FUIPhoneAuth
                phoneProvider?.signIn(withPresenting: (UIApplication.shared.windows.first?.rootViewController)!, phoneNumber: nil)
            }) {
                Text("Login with Phone")
            }
            .padding()
        }
        .onAppear {
            authDelegate.onLogin = onLogin
            FUIAuth.defaultAuthUI()?.delegate = authDelegate
        }
    }
}
