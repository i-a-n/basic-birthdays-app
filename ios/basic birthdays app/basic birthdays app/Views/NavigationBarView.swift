//
//  NavigationBarView.swift
//  dead simple birthdays
//
//  Created by ian on 6/4/23.
//

import SwiftUI

struct NavigationBarView: View {
    var body: some View {
        HStack {
            // Add your app's logo or any other elements you want to display in the navigation bar
            // Example: Image("logo")
            Text("x.x").fontWeight(Font.Weight.bold).foregroundColor(Color(UIColor.darkText))
            Spacer()
            Text("dead simple birthdays").foregroundColor(Color(UIColor.darkText))
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
}
