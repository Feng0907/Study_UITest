//
//  ScheduleService.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/11.
//


protocol ScheduleServiceProtocol {
    func fetchSchedule(completion: @escaping DoneHandler<WeeklySchedule>)
}

final class ScheduleService: ScheduleServiceProtocol {
    func fetchSchedule(completion: @escaping DoneHandler<WeeklySchedule>) {
        NetworkManager.shared.doGetSchedule(completion: completion)
    }
}
