//
//  CalendarView.swift
//  WorkingWIthCalendars
//
//  Created by Rupesh Chaudhari on 12/09/22.
//

import SwiftUI
import UIKit
import FSCalendar

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var dateIsSelected = false
    
    @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
    
    @Binding var activeView: ActiveView
    
    private var filteredFriends: [Friend] {
        let selectedDateComponents = Calendar.current.dateComponents([.month, .day], from: selectedDate)
        
        return viewModel.friends.filter { friend in
            let friendMonth = friend.month
                    let friendDay = friend.day
            return friendMonth == selectedDateComponents.month && friendDay == selectedDateComponents.day
        }
    }
    
    private var selectedMonthAndDay:  DateComponents  {
        return Calendar.current.dateComponents([.month, .day], from: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarViewRepresentable(selectedDate: $selectedDate, dateIsSelected: $dateIsSelected)
                    .environmentObject(viewModel)
                    .sheet(isPresented: $dateIsSelected, content: {
                        NavigationView { // Wrap the VStack in a NavigationView
                            VStack {
                                Text(selectedDate.formatted(.dateTime.day().month(.wide).year())).font(.title)
                                    .textCase(.lowercase).padding()
                                Spacer()
                                if filteredFriends.isEmpty {
                                    Text("no birthdays")
                                } else {
                                    List(filteredFriends, id: \.id) { friend in
                                        FriendListItemView(friend: friend).environmentObject(viewModel)
                                    }
                                }
                                Spacer()
                                NavigationLink(destination: AddFriendForm(editFriend: Friend(name: "", year: nil, day: selectedMonthAndDay.day ?? 1, month: selectedMonthAndDay.month ?? 1, fbId: nil))) {
                                    Text("add birthday")
                                }
                            }
                            
                        }.presentationDetents([.medium])
//                            .presentationBackground(Color(UIColor.systemGray6))
                    })
            }
            .onChange(of: selectedDate) { newDate in
                dateIsSelected = true;
            }
        }
    }

}

struct FriendListItemView: View {
    @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
    let friend: Friend
    
    var body: some View {
        HStack {
            Text(friend.name)
            Spacer()
            if let birthday = viewModel.getBirthdayString(for: friend) {
                Text(birthday)
            }
        }
    }
}


struct CalendarViewRepresentable: UIViewRepresentable {
    @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
    typealias UIViewType = FSCalendar
    
    fileprivate var calendar = FSCalendar()
    @Binding var selectedDate: Date
    @Binding var dateIsSelected: Bool
    
    func makeUIView(context: Context) -> FSCalendar {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.appearance.headerDateFormat = "MMMM"
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.headerTitleColor = .darkGray
        calendar.scope = .month
        calendar.clipsToBounds = false
        
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        let dayEnum = calendar.calendarWeekdayView.weekdayLabels
        
        dayEnum.forEach{ (cell) in
            let c = cell
            let str = c.text ?? " "
            c.text = String(str.lowercased())
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarViewRepresentable
        
        init(_ parent: CalendarViewRepresentable) {
            self.parent = parent
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            
            // hacky way to make sure you can re-select a date after
            // dismissing the sheet
            if date == parent.selectedDate {
                parent.dateIsSelected = true
            }
        }
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let eventDates = parent.viewModel.friends.compactMap { friend -> Date? in
                let month = friend.month
                let day = friend.day
                
                let calendar = Calendar.current
                var friendDateComponents = DateComponents()
                friendDateComponents.month = month
                friendDateComponents.day = day
                
                if let year = friend.year {
                    friendDateComponents.year = Int(year)
                }
                
                return calendar.date(from: friendDateComponents)
            }

            let currentDateComponents = Calendar.current.dateComponents([.month, .day], from: date)
            let eventCount = eventDates.filter { eventDate in
                let eventDateComponents = Calendar.current.dateComponents([.month, .day], from: eventDate)
                return eventDateComponents.month == currentDateComponents.month &&
                       eventDateComponents.day == currentDateComponents.day
            }.count

            return eventCount
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//            if isWeekend(date: date) {
//                return false
//            }
            return true
        }
    }
}
