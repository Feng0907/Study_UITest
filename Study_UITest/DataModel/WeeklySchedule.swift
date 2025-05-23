//
//  WeeklySchedule.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import Foundation

// MARK: - TimeSlot & WeeklySchedule
struct WeeklySchedule: Decodable {
    let available: [TimeSlot]
    let booked: [TimeSlot]
}

struct TimeSlot: Decodable {
    let startDate: Date
    let endDate: Date

    var start: Date { startDate }
    var end: Date { endDate }
    
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }
    
    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }

    func contains(_ date: Date) -> Bool {
        return startDate <= date && date < endDate
    }

    // 將api接到的字串時間轉換成Date格式
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let startString = try container.decode(String.self, forKey: .start)
        let endString = try container.decode(String.self, forKey: .end)

        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withColonSeparatorInTimeZone]

        // fallback if no milliseconds
        let backupFormatter = ISO8601DateFormatter()
        backupFormatter.timeZone = TimeZone.current
        backupFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]

        if let startDate = formatter.date(from: startString) ?? backupFormatter.date(from: startString),
           let endDate = formatter.date(from: endString) ?? backupFormatter.date(from: endString) {
            self.startDate = startDate
            self.endDate = endDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .start, in: container, debugDescription: "Date format incorrect")
        }
    }
}

// MARK: - 顯示用Model
struct TimeSlotType {
    let timeSlotStr: String
    let booked: Bool
}

struct DaySlotSection {
    let date: Date
    let timeItems: [TimeSlotType]
}

