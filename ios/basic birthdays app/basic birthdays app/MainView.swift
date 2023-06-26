//
// ContentView.swift
// basic birthdays app
//
// notes:
//

import FirebaseAuth
import SwiftUI

struct MainView: View {

  @StateObject private var viewModel = ViewAndEditBirthdaysViewModel()
  @State private var isLoggedIn = false
  @State private var activeView: ActiveView = .calendar

  var body: some View {
    NavigationBarView()
    ZStack {
      TabView(selection: $activeView) {
        CalendarView(activeView: $activeView, isLoggedIn: $isLoggedIn)
          .environmentObject(viewModel)
          .tabItem {
            Label("calendar", systemImage: "calendar")
          }
          .tag(ActiveView.calendar)

        ListView(isLoggedIn: $isLoggedIn).environmentObject(viewModel)
          .tabItem {
            Label("list", systemImage: "list.bullet")
          }
          .tag(ActiveView.list)

        AddFriendForm(isLoggedIn: $isLoggedIn)
          .tabItem {
            Label("add", systemImage: "plus.circle.fill")
          }
          .tag(ActiveView.add)

        SettingsView(isLoggedIn: $isLoggedIn, onLogout: { self.onLogout() })
          .tabItem {
            Label("settings", systemImage: "gearshape.fill")
          }
          .tag(ActiveView.settings)

        Text(" ")
          .tabItem {
            Label("nothing", systemImage: "square.dotted")
          }
          .tag(ActiveView.nothing)

      }

      // the login prompt is overlayed on all screens (except .nothing) if a user isn't
      // logged in
      VStack {
        Spacer()
        if !isLoggedIn && activeView != .nothing {
          LoginView(onLogin: {
            LoginUtilities.storeLastAuthTimestamp()
            self.isLoggedIn = true
            self.loadFriends()
          })
        }
        Spacer()
      }.padding(.top, UIScreen.main.bounds.height * 0.3)
    }
    .onAppear {
      checkLoggedInUser()
    }
  }

  private func checkLoggedInUser() {
    if Auth.auth().currentUser != nil {
      isLoggedIn = true
      loadFriends()
    }
  }

  private func loadFriends() {
    viewModel.loadFriends()
  }

  private func onLogout() {
    isLoggedIn = false
    viewModel.loadFriends()
  }

  private func onDeleteAccount() {
    isLoggedIn = false
    viewModel.loadFriends()
  }
}
