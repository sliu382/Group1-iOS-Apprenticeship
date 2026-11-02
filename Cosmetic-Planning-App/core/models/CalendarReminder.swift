//
//  CalendarReminder.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//



import Foundation

struct CalendarReminder: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var isComplete = false

    var timeText: String {
        date.formatted(
            date: .omitted,
            time: .shortened
        )
    }

    var dateText: String {
        date.formatted(
            .dateTime.weekday(.abbreviated)
                .month(.abbreviated)
                .day()
        )
    }
}
