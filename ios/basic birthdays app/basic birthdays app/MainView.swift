//
//  ContentView.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var viewModel = ViewAndEditBirthdaysViewModel()
    @State private var isLoggedIn = false
    @State private var activeView: ActiveView = .calendar

    
    var body: some View {
        VStack {
            if isLoggedIn {
                NavigationBarView()
                TabView(selection: $activeView) {
                    CalendarView(activeView: $activeView).environmentObject(viewModel)
                        .tabItem {
                            Label("calendar", systemImage: "calendar")
                        }
                        .tag(ActiveView.calendar)
                    
                    ListView().environmentObject(viewModel)
                        .tabItem {
                            Label("list", systemImage: "list.bullet")
                        }
                        .tag(ActiveView.list)
                    
                    AddFriendForm()
                        .tabItem {
                            Label("add", systemImage: "plus.circle.fill")
                        }
                        .tag(ActiveView.add)
                    
                    SettingsView()
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
            } else {
                LoginView(onLogin: {
                    self.isLoggedIn = true
                    self.loadFriends()
                })
            }
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

