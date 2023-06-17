//
// NavigationBarView.swift
// basic birthdays app
//
// notes:
//

import SwiftUI

struct NavigationBarView: View {
  var body: some View {
    HStack {
      Text("basic")
        .fontWeight(.bold)
        .font(.system(size: 17, weight: .bold, design: .default))
        .foregroundColor(Color(UIColor.darkText))

      Spacer()

      Text("birthdays app")
        .font(.system(size: 17, weight: .regular, design: .default))
        .foregroundColor(Color(UIColor.darkText))
    }
    .padding()
    .background(Color(UIColor.systemGray6))
  }
}
