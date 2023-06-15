//
// CalendarObserver.swift
// basic birthdays app
//
// notes: the calendar observer concept has only one use in this app, which is to notify the
// calendar that the Friends[] array has been updated. we use it to re-render the calendar.
//
// like most parts of the app, I do not know how any of this actually works, because I am not
// a swift developer. the chatgpt robot told me how to do this.
//

import Foundation

protocol CalendarObserver: AnyObject {
  func calendarDataDidChange()
}
