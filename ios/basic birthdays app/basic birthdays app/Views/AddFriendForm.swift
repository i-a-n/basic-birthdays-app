//
//  AddFriendForm.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import SwiftUI

struct AddFriendForm: View {
  @StateObject private var viewModel = ViewAndEditBirthdaysViewModel()

  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""

  @State private var name = ""
  @State private var selectedMonth = 1
  @State private var day = 1

  @State private var selectedYear: Int?

  private enum Field: Int, CaseIterable {
    case name
  }
  @FocusState private var focusedField: Field?
  
  var editFriend: Friend?
  var hideClearForm: Bool?
  @Binding var isLoggedIn: Bool

  init(isLoggedIn: Binding<Bool>, editFriend: Friend? = nil, hideClearForm: Bool? = false) {
    self._isLoggedIn = isLoggedIn
    self.editFriend = editFriend
    self.hideClearForm = hideClearForm

    if let friend = editFriend {
      _name = State(initialValue: friend.name)
      _selectedMonth = State(initialValue: friend.month)
      _day = State(initialValue: friend.day)
      _selectedYear = State(initialValue: friend.year)
    }
  }

  var body: some View {
    Form {
      Section(header: Text("name")) {
        TextField("name", text: $name)
          .focused($focusedField, equals: .name)
          .textFieldStyle(.roundedBorder)
      }

      Section(header: Text("birthday")) {
        Picker("month", selection: $selectedMonth) {
          ForEach(1..<13, id: \.self) { monthNumber in
            Text(DateFormatter().monthSymbols[monthNumber - 1].lowercased())
              .tag(monthNumber)
          }
        }
        .pickerStyle(MenuPickerStyle())

        Picker("day", selection: $day) {
          let numberOfDays = DateUtilities.numberOfDaysInMonth(selectedMonth: selectedMonth)
          ForEach(1..<(numberOfDays + 1), id: \.self) { day in
            Text("\(day)")
              .tag(day)
          }
        }

        Picker("year", selection: $selectedYear) {
          let currentYear = Calendar.current.component(.year, from: Date())
          let years = (1900...currentYear).reversed().map { String($0) }

          Text("no year")
            .tag(nil as Int?)

          ForEach(years, id: \.self) { year in
            Text(year)
              .tag(Int(year))
          }
        }
        .pickerStyle(DefaultPickerStyle())

      }
      Section {
        HStack {
          Spacer()
          if let friendID = editFriend?.fbId {
            Button("delete friend") {
              deleteFriend(friendID: friendID)
            }.buttonStyle(.borderless).padding([.trailing], 16)
            Button("update friend") {
              submitForm()
            }.buttonStyle(.borderedProminent)
          } else {
            if !(hideClearForm ?? false) {
              Button("clear form") {
                name = ""
                selectedMonth = 1
                day = 1
                selectedYear = nil
              }.buttonStyle(.borderless).padding([.trailing], 16)
            }
            Button("add friend") {
              submitForm()
            }.disabled(!isLoggedIn).buttonStyle(.borderedProminent)
          }
        }
      }
    }.opacity(isLoggedIn ? 1.0 : 0.33).toolbar {
      ToolbarItem(placement: .keyboard) {
        Button("done") {
          focusedField = nil
        }
      }
    }.alert(isPresented: $showAlert) {
      Alert(
        title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("ok")))
    }
    .scrollContentBackground(.hidden)

  }

  func showAlert(title: String, message: String) {
    alertTitle = title
    alertMessage = message
    showAlert = true
  }

  func deleteFriend(friendID: String) {
    viewModel.deleteFriend(friendID: friendID) { result in
      switch result {
      case .success:
        // Friend added successfully
        showAlert(title: "success", message: "friend removed")
        print("worked")
      case .failure(let error):
        // Handle the error
        showAlert(title: "error", message: error.localizedDescription)
        print("Failed to remove friend: \(error.localizedDescription)")
      }
    }
  }

  func submitForm() {
    let friendID = editFriend?.fbId

    viewModel.addOrUpdateFriend(
      friendID: friendID, name: name, year: selectedYear, month: selectedMonth, day: day
    ) { result in
      switch result {
      case .success:
        // Friend added successfully
        if friendID == nil {
          name = ""
          selectedMonth = 1
          day = 1
          selectedYear = nil
        }
        showAlert(title: "success", message: "friend added/updated")
        print("worked")
      case .failure(let error):
        // Handle the error
        showAlert(title: "error", message: error.localizedDescription)
        print("Failed to add friend: \(error.localizedDescription)")
      }
    }
  }
}
