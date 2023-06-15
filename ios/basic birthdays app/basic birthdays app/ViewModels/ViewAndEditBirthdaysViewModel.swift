//
// ViewAndEditBirthdaysViewModel.swift
// basic birthdays app
//
// notes:
//

import Foundation

class ViewAndEditBirthdaysViewModel: ObservableObject {

  // these next ~20 lines or so were all copied from chatGPT's solution for how to update the
  // calendar instance when the friends list changes. the friends list can be changed in
  // firebase and will result in instant updates to Friend[] everywhere in the app, like list
  // views, etc, but the calendar does NOT re-render by default. so we have to set up this
  // big observer/notifier thing to do that. see ../CalendarObserver.swift and the CalendarView
  // for more code.
  @Published var friends: [Friend] = [] {
    didSet {
      notifyCalendarObservers()
    }
  }

  private var calendarObservers = NSHashTable<AnyObject>.weakObjects()

  func registerCalendarObserver(_ observer: CalendarObserver) {
    calendarObservers.add(observer)
  }

  func unregisterCalendarObserver(_ observer: CalendarObserver) {
    calendarObservers.remove(observer)
  }

  private func notifyCalendarObservers() {
    print("calendarObservers: \(calendarObservers.allObjects)")
    calendarObservers.allObjects.forEach { observer in
      (observer as? CalendarObserver)?.calendarDataDidChange()
    }
  }

  // I can't remember why we have to do this on the DispatchQueue. sorry.
  func loadFriends() {
    FirebaseService.shared.getUserFriends { [weak self] friends in
      DispatchQueue.main.async {
        self?.friends = friends
      }
    }
  }

  func addOrUpdateFriend(
    friendID: String? = nil, name: String, year: Int?, month: Int, day: Int,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    FirebaseService.shared.addOrUpdateFriend(
      friendID: friendID, name: name, year: year, month: month, day: day, completion: completion)
  }

  func deleteFriend(friendID: String, completion: @escaping (Result<Void, Error>) -> Void) {
    FirebaseService.shared.deleteFriend(friendID: friendID, completion: completion)
  }
}
