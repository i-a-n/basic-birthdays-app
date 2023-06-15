//
//  CalendarView.swift
//  WorkingWIthCalendars
//
//  Created by Rupesh Chaudhari on 12/09/22.
//

import FSCalendar
import SwiftUI
import UIKit

struct CalendarView: View {
  @State private var selectedDate = Date()
  @State private var dateIsSelected = false
  @State private var monthBeingViewed = 0

  @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel

  @Binding var activeView: ActiveView

  private var filteredFriends: [Friend] {
    let selectedDateComponents = Calendar.current.dateComponents(
      [.month, .day], from: selectedDate)

    return viewModel.friends.filter { friend in
      let friendMonth = friend.month
      let friendDay = friend.day
      return friendMonth == selectedDateComponents.month && friendDay == selectedDateComponents.day
    }
  }

  private var friendsWithBirthdaysThisMonth: [Friend] {
    let currentDate = Date()
    let currentDay = Calendar.current.component(.day, from: currentDate)
    let currentMonth = Calendar.current.component(.month, from: currentDate)
    let currentYear = Calendar.current.component(.year, from: currentDate)

    return viewModel.friends.filter { friend in
      let friendMonth = friend.month
      let friendDay = friend.day

      if currentMonth == monthBeingViewed {
        // Filter out birthdays that have already occurred only when
        // the current month matches the month being viewed
        return friendMonth == monthBeingViewed && friendDay >= currentDay
      } else {
        // Include all friends when the current month doesn't match
        // the month being viewed
        return friendMonth == monthBeingViewed
      }
    }
    .sorted { friend1, friend2 in
      let friend1Date =
        Calendar.current.date(
          from: DateComponents(year: currentYear, month: friend1.month, day: friend1.day))
        ?? currentDate
      let friend2Date =
        Calendar.current.date(
          from: DateComponents(year: currentYear, month: friend2.month, day: friend2.day))
        ?? currentDate
      return friend1Date < friend2Date
    }
  }

  private var selectedMonthAndDay: DateComponents {
    return Calendar.current.dateComponents([.month, .day], from: selectedDate)
  }

  var body: some View {
    NavigationView {
      VStack {
        CalendarViewRepresentable(
          selectedDate: $selectedDate, dateIsSelected: $dateIsSelected,
          monthBeingViewed: $monthBeingViewed
        )
        .environmentObject(viewModel)
        .sheet(
          isPresented: $dateIsSelected,
          content: {
            NavigationView {  // Wrap the VStack in a NavigationView
              VStack {
                Text(selectedDate.formatted(.dateTime.day().month(.wide).year())).font(.title)
                  .textCase(.lowercase).padding()
                Spacer()
                if filteredFriends.isEmpty {
                  Text("no birthdays").font(.system(size: 14, weight: .light))
                } else {
                  List(filteredFriends, id: \.id) { friend in
                    FriendListSingleDateView(friend: friend, selectedDate: selectedDate)
                      .environmentObject(viewModel)
                  }.listStyle(.plain)
                }
                NavigationLink(
                  destination: AddFriendForm(
                    editFriend: Friend(
                      name: "", year: nil, day: selectedMonthAndDay.day ?? 1,
                      month: selectedMonthAndDay.month ?? 1, fbId: nil), hideClearForm: true)
                ) {
                  Text("add a birthday")
                }.buttonStyle(.borderedProminent)
                Spacer()
              }

            }.presentationDetents([.medium])
          }
        )
        .frame(height: UIScreen.main.bounds.height * 0.46)
        VStack {
          List {
            Section(header: Text("upcoming birthdays")) {
              ForEach(friendsWithBirthdaysThisMonth, id: \.id) { friend in
                FriendListItemView(friend: friend).environmentObject(viewModel)
              }
            }
          }.listStyle(InsetGroupedListStyle())
          //.listStyle(.plain)
          Spacer()
        }.background(Color(UIColor.systemGray6))
      }
      .onChange(of: selectedDate) { newDate in
        dateIsSelected = true
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
      if let birthday = DateUtilities.getBirthdayString(for: friend) {
        Text(birthday).fontWeight(.light)
      }
    }
  }
}

struct FriendListSingleDateView: View {
  @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
  let friend: Friend
  let selectedDate: Date

  var body: some View {
    HStack {
      Text(friend.name)
      Spacer()
      if let birthday = DateUtilities.getAgeString(for: friend, selectedDate: selectedDate) {
        Text(birthday).fontWeight(.light)
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
  @Binding var monthBeingViewed: Int

  func makeUIView(context: Context) -> FSCalendar {
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator
    //calendar.delgateAppearance = context.coordinator

    calendar.appearance.headerDateFormat = "MMMM"
    calendar.appearance.weekdayTextColor = .darkGray
    calendar.appearance.headerTitleColor = .darkGray
    calendar.appearance.caseOptions = [.headerUsesUpperCase]
    calendar.scope = .month

    return calendar
  }

  func updateUIView(_ uiView: FSCalendar, context: Context) {
    // lowercase the day names
    let dayEnum = calendar.calendarWeekdayView.weekdayLabels
    dayEnum.forEach { (cell) in
      let c = cell
      let str = c.text ?? " "
      c.text = String(str.lowercased())
    }

    // set month being viewed
    let calendar = Calendar.current
    let month = calendar.component(.month, from: uiView.currentPage)
    self.monthBeingViewed = month

  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource,
    FSCalendarDelegateAppearance, CalendarObserver
  {
    var parent: CalendarViewRepresentable

    init(_ parent: CalendarViewRepresentable) {
      self.parent = parent
      super.init()

      parent.viewModel.registerCalendarObserver(self)

    }

    func calendarDataDidChange() {
      print("okay we're really gonna reload now")
      parent.calendar.reloadData()
      // changeMonthName()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
      let currentPage = calendar.currentPage
      let calendar = Calendar.current
      let month = calendar.component(.month, from: currentPage)

      parent.monthBeingViewed = month

      // changeMonthName()
    }

    func changeMonthName() {
      let collectionView =
        parent.calendar.calendarHeaderView.value(forKey: "collectionView") as! UICollectionView

      collectionView.visibleCells.forEach { (cell) in
        let c = cell as! FSCalendarHeaderCell

        c.titleLabel.text = c.titleLabel.text?.lowercased()

      }

      for header in parent.calendar.visibleStickyHeaders {
        let h = header as! FSCalendarStickyHeader
        h.titleLabel.text = h.titleLabel.text?.lowercased()
      }
    }

    func calendar(
      _ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition
    ) {
      parent.selectedDate = date

      // hacky way to make sure you can re-select a date after
      // dismissing the sheet
      if date == parent.selectedDate {
        parent.dateIsSelected = true
      }
    }

    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
      print("numberOfEventsFor called with date: \(date)")

      let eventDates = parent.viewModel.friends.compactMap { friend -> Date? in
        print(friend.name)
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
        return eventDateComponents.month == currentDateComponents.month
          && eventDateComponents.day == currentDateComponents.day
      }.count

      return eventCount
    }

    func calendar(
      _ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition
    ) -> Bool {
      return true
    }

  }
}
