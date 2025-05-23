//
//  TimeSlotButton.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import UIKit

// 時間按鈕樣式
final class TimeSlotButton: UIButton {
    private var isBooked: Bool = false

    init() {
        super.init(frame: .zero)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStyle()
    }

    private func setupStyle() {
        self.titleLabel?.font = .systemFont(ofSize: 13)
        self.backgroundColor = .clear
        self.contentHorizontalAlignment = .center
    }

    func configure(text: String, booked: Bool) {
        self.setTitle(text, for: .normal)
        self.isBooked = booked
        self.setTitleColor(booked ? .systemGray:.orange, for: .normal)
    }
}
