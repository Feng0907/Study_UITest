//
//  TimeSlot+splitTime.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/10.
//

import Foundation

// 拆分時間區段為每 30 分鐘
extension TimeSlot {
    func splitTime(intervalMinutes: Int = 30) -> [Date] {
        var result: [Date] = []
        var current = start

        while current < end {
            result.append(current)
            if let next = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: current) {
                current = next
            } else {
                break
            }
        }
        return result
    }
}
