//
//  DateFormatter.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/11.
//

import Foundation

// 時間格式
enum DateFormatterFactory {
    static let timeOnlyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = TimeZone.current
        return f
    }()
    
    static func dateRangeFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        f.timeZone = TimeZone.current
        return f
    }
    
    static func weekDayFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "E\ndd"
        f.timeZone = TimeZone.current
        return f
    }
}
