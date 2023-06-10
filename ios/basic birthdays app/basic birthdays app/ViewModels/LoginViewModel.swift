//
//  LoginViewModel.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import Foundation
import SwiftUI
import FirebaseCore

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    
    private let authService = FirebaseService.shared
    
    func signIn() {
        authService.signIn(email: email, password: password) { [weak self] (_, error) in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                return
            }
            
            self?.isLoggedIn = true
        }
    }
}
