//
// DateUtilities.swift
// basic birthdays app
//
// notes:
//

import Foundation

class DateUtilities {
  // takes month and day and constructs a Date() object, which is useful for sorting by birthday
  static func getBirthdayDate(for friend: Friend) -> Date? {
    let calendar = Calendar.current
    var components = DateComponents()
    components.month = friend.month
    components.day = friend.day

    return calendar.date(from: components)
  }

  // returns a lowercase "mmm dd" string, examples: "jul 22", "oct 04"
  static func getBirthdayString(for friend: Friend) -> String? {
    let day = friend.day
    let month = friend.month

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"

    let calendar = Calendar.current
    var components = DateComponents()
    components.month = month
    components.day = day

    if let date = calendar.date(from: components) {
      let dateString = dateFormatter.string(from: date)
      return dateString.lowercased()

    } else {
      return nil
    }
  }

  // returns "turning XX", where XX is the age the friend will turn on the given date.
  // if the friend has no "year", returns nothing.
  static func getAgeString(for friend: Friend, selectedDate: Date) -> String? {
    if let year = friend.year {
      if year == 0 {
        return nil
      }

      let calendar = Calendar.current
      let currentYear = calendar.component(.year, from: selectedDate)
      let age = currentYear - year

      return "turning \(age)"
    } else {
      return nil
    }
  }

  // does what it says on the tin
  static func numberOfDaysInMonth(selectedMonth: Int) -> Int {
    let calendar = Calendar.current

    // note about the next line: we are usually calling this function before a user has selected
    // a year. so what do we do to determine how many days are in the selected month if we don't
    // know the year? well, all of the months always have the same number of days every year,
    // except of course february. so my solution here is to just hard-code the year 2004 in there,
    // since it was a leap-year, and therefore feb 29 will always be selectable. yes, even if the
    // user has chosen a non-leap-year, they could select feb 29. shrug.
    guard let date = calendar.date(from: DateComponents(year: 2004, month: selectedMonth)) else {
      return 0
    }

    guard let range = calendar.range(of: .day, in: .month, for: date) else {
      return 0
    }

    return range.count
  }

}
