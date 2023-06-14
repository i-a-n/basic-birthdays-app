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

    init(editFriend: Friend? = nil, hideClearForm: Bool? = false) {
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
                    ForEach(1..<(numberOfDaysInMonth() + 1), id: \.self) { day in
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
                        }.buttonStyle(.borderedProminent)
                    }
                }
            }
        }                   .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("done") {
                    focusedField = nil
                }
            }
        }.alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("ok")))
        }
        .scrollContentBackground(.hidden)

    }
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    func numberOfDaysInMonth() -> Int {
        let calendar = Calendar.current
              let selectedMonth = selectedMonth
        guard let date = calendar.date(from: DateComponents(year: 2004, month: selectedMonth)) else { return 0 }

        
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return 0
        }
        
        return range.count
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
        // Perform any necessary actions with the form data
//        let friend = Friend(name: name, year: selectedYear, day: day, month: selectedMonth)
//        print("Submitted friend: \(friend)")
//
//        // Reset the form fields
//        name = ""
//        selectedMonth = 1
//        day = 1
//        selectedYear = 2023
        let friendID = editFriend?.fbId
        
        viewModel.addOrUpdateFriend(friendID: friendID, name: name, year: selectedYear, month: selectedMonth, day: day) { result in
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

//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            AddFriendForm()
//                .navigationTitle("add friend")
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
