//
//  CalendarObserver.swift
//  basic birthdays app
//
//  Created by ian on 6/12/23.
//

import Foundation

protocol CalendarObserver: AnyObject {
    func calendarDataDidChange()
}
