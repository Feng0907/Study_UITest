//
//  ScheduleViewModel.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import Foundation
import Combine

class ScheduleViewModel: ObservableObject {
    @Published var weekDates: [Date] = []
    @Published var daySections: [DaySlotSection] = []
    
    private let service: ScheduleServiceProtocol
    private(set) var availableSlots: [TimeSlot] = []
    private(set) var bookedSlots: [TimeSlot] = []

    private let calendar = Calendar.current

    init(service: ScheduleServiceProtocol = ScheduleService()) {
        self.service = service
        generateCurrentWeek()
        fetchSchedule()
    }
    
    // 計算顯示該週日期
    func generateCurrentWeek(startingFrom date: Date = Date()) {
        let start = calendar.startOfDay(for: date)
        weekDates = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: start)
        }
        generateDaySections()
    }
    
    // 從api撈取時間表資料
    func fetchSchedule() {
        service.fetchSchedule { [weak self] data, error in
           guard let self = self else { return }
           if let schedule = data {
               DispatchQueue.main.async {
                   self.availableSlots = schedule.available
                   self.bookedSlots = schedule.booked
                   self.generateDaySections()
               }
           } else {
               print("Error loading schedule: \(error?.localizedDescription ?? "unknown error")")
           }
       }
    }
    
    // 產生每日時間對照時間表資料
    func generateDaySections() {
        daySections = weekDates.map { date in
            let timeItems = generateSlots(for: date)
            return DaySlotSection(date: date, timeItems: timeItems)
        }
    }

    // 產生每日時間表資料
    func generateSlots(for date: Date) -> [TimeSlotType] {
        var slots: [TimeSlotType] = []

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let now = Date()
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return [] }
        var current = startOfDay
        
        while current < endOfDay {
            if current >= now {
                let timeStr = DateFormatterFactory.timeOnlyFormatter.string(from: current)
                let isBooked = bookedSlots.contains { $0.contains(current) }
                let isAvailable = availableSlots.contains { $0.contains(current) }

                if isBooked {
                    slots.append(TimeSlotType(timeSlotStr: timeStr, booked: true))
                } else if isAvailable {
                    slots.append(TimeSlotType(timeSlotStr: timeStr, booked: false))
                }
            }

            guard let next = calendar.date(byAdding: .minute, value: 30, to: current) else { break }
            current = next
        }

        return slots
    }

    // 切換週
    func shiftWeek(by offset: Int) {
        guard let firstDate = weekDates.first else { return }
        let newStartDate = Calendar.current.date(byAdding: .day, value: 7 * offset, to: firstDate) ?? firstDate
        if newStartDate < calendar.startOfDay(for: Date()) { return }
        generateCurrentWeek(startingFrom: newStartDate)
    }
    
}
