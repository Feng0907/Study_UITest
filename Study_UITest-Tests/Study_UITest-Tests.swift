//
//  Study_UITest-Tests.swift
//
//
//  Created by Feng on 2025/5/11.
//

import Foundation
import XCTest
@testable import StudyUITest

final class ScheduleViewModelTests: XCTestCase {

    // 模擬Service，取代api
    class MockScheduleService: ScheduleServiceProtocol {
        let mockData: WeeklySchedule

        init(mockData: WeeklySchedule) {
            self.mockData = mockData
        }

        func fetchSchedule(completion: @escaping (WeeklySchedule?, Error?) -> Void) {
            completion(mockData, nil)
        }
    }

    func testGenerateDaySections_withValidData_shouldIncludeTimeSlot() {
        // 準備資料
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: today)!
        let end = calendar.date(bySettingHour: 23, minute: 30, second: 0, of: today)!
        let mockSlot = TimeSlot(startDate: start, endDate: end)
        let mockSchedule = WeeklySchedule(available: [mockSlot], booked: [])

        let mockService = MockScheduleService(mockData: mockSchedule)
        let viewModel = ScheduleViewModel(service: mockService)

        // 執行
        viewModel.generateCurrentWeek(startingFrom: today)

        // 等待主執行緒的更新
        let expectation = XCTestExpectation(description: "Wait for view model to update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 驗證預期的結果
            let todaySection = viewModel.daySections.first { section in
                Calendar.current.isDate(section.date, inSameDayAs: today)
            }
            XCTAssertNotNil(todaySection)
            XCTAssertTrue(todaySection!.timeItems.contains(where: { $0.timeSlotStr == "23:00" }))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
