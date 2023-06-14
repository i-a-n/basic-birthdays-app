//
//  Friend.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import Foundation

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let year: Int?
    let day: Int
    let month: Int
    let monthNameForGrouping: String?
    let fbId: String?
}

enum ActiveView {
    case calendar
    case list
    case add
    case settings
    case nothing
    case birthdayView
}
