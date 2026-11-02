//
//  Appointment.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 11/2/26.
//

import Foundation

struct Appointment: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var location: String?
    var notes: String?
    var isComplete: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case location
        case notes
        case isComplete = "is_complete"
    }

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
