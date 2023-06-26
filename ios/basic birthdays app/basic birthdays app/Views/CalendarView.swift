//
// CalendarView.swift
// basic birthdays app
//
// notes: https://github.com/WenchaoD/FSCalendar
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
  @Binding var isLoggedIn: Bool

  var body: some View {
    NavigationStack {
      VStack {
        CalendarViewRepresentable(
          selectedDate: $selectedDate, dateIsSelected: $dateIsSelected,
          isLoggedIn: $isLoggedIn, monthBeingViewed: $monthBeingViewed
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
                if friendsWithBirthdaysOnSelectedDay.isEmpty {
                  Text("no birthdays").font(.system(size: 14, weight: .light))
                } else {
                  List(friendsWithBirthdaysOnSelectedDay, id: \.id) { friend in
                    HStack {
                      Text(friend.name)
                      Spacer()
                      if let birthday = DateUtilities.getAgeString(
                        for: friend, selectedDate: selectedDate)
                      {
                        Text(birthday).fontWeight(.light)
                      }
                    }
                  }.listStyle(.plain)
                }
                NavigationLink(
                  destination: AddFriendForm(
                    isLoggedIn: $isLoggedIn,
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
        if isLoggedIn {
          VStack {

            List {
              Section(header: Text("upcoming birthdays")) {
                ForEach(friendsWithBirthdaysThisMonth, id: \.id) { friend in
                  HStack {
                    Text(friend.name)
                    Spacer()
                    if let birthday = DateUtilities.getBirthdayString(for: friend) {
                      Text(birthday).fontWeight(.light)
                    }
                  }
                }
              }
            }.listStyle(InsetGroupedListStyle())
            Spacer()
          }.background(Color(UIColor.systemGray6))
        } else {
          Spacer()
        }
      }
      .onChange(of: selectedDate) { newDate in
        dateIsSelected = true
      }
    }
  }

  // returns friends with birthdays on $selectedDay. disregards year.
  private var friendsWithBirthdaysOnSelectedDay: [Friend] {
    let selectedDateComponents = Calendar.current.dateComponents(
      [.month, .day], from: selectedDate)

    return viewModel.friends.filter { friend in
      let friendMonth = friend.month
      let friendDay = friend.day
      return friendMonth == selectedDateComponents.month && friendDay == selectedDateComponents.day
    }
  }

  // sorted list of friends with birthdays in a given month. if given month is this month, only
  // returns friends whose birthdays have not occurred yet.
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

}

// almost all of this comes from the logrocket FSCalendar tutorial:
// https://blog.logrocket.com/working-calendars-swift/#displaying-calendar-view-fscalendar
struct CalendarViewRepresentable: UIViewRepresentable {
  @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
  typealias UIViewType = FSCalendar

  fileprivate var calendar = FSCalendar()

  @Binding var selectedDate: Date
  @Binding var dateIsSelected: Bool
  @Binding var isLoggedIn: Bool

  // we need the "month being viewed" to properly display upcoming birthdays for that
  // month
  @Binding var monthBeingViewed: Int

  func makeUIView(context: Context) -> FSCalendar {
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator

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
      parent.calendar.reloadData()
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
      let currentPage = calendar.currentPage
      let calendar = Calendar.current
      let month = calendar.component(.month, from: currentPage)

      parent.monthBeingViewed = month

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
      let eventDates = parent.viewModel.friends.compactMap { friend -> Date? in
        let month = friend.month
        let day = friend.day

        let calendar = Calendar.current
        var friendDateComponents = DateComponents()
        friendDateComponents.month = month
        friendDateComponents.day = day

        // this is probably extranneous but I'm afraid to take it out
        // in case there is some very odd, very rare bug or something
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

    // this disables selecting dates if the user isn't logged in
    func calendar(
      _ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition
    ) -> Bool {
      if !parent.isLoggedIn {
        return false
      }
      return true
    }

  }
}
