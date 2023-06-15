//
// Models.swift
// basic birthdays app
//
// notes: I think this is just a place for loose type defs
//

import Foundation

// the "Friend" typedef is the heart of the app. it really describes three things:
// 1. the friend as it exists in the firebase database
// 2. the friend as it exists when fetched, then passed around the app
// 3. the thing that exists when we initialize a blank form to add a new friend
//
// in typescript, I would have probably made this three "extends" type definitions,
// but I don't know if you can do that in swift, so it's a bit messy. for instance,
// `id = UUID()` is not something that exists in firebase, but it MUST exist when
// iterating over friends in the app (I think), so that's a possible point of
// buginess in the future.
//
// other notes: `fbId` is the firebase ID, typically a long alphanumeric hash
struct Friend: Identifiable {
  let id = UUID()
  let name: String
  let year: Int?
  let day: Int
  let month: Int
  let fbId: String?
}

// defines all the possible navigation "views" in the app
enum ActiveView {
  case calendar
  case list
  case add
  case settings
  case nothing
}
