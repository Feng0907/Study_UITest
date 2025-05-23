//
//  WeekDayCell.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import UIKit

// 每一天格式樣式（包含日期/星期/時間表）
class WeekDayCell: UICollectionViewCell {
    static let reuseId = "WeekDayCell"

    private let label = UILabel()
    private let topBar = UIView()
    private let stackView = UIStackView()
    private let scrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(topBar)
        topBar.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // topBar
            topBar.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            topBar.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 5),
            topBar.widthAnchor.constraint(equalToConstant: 20),

            // label
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),

            // scrollView below label
            scrollView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // stackView inside scrollView
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Important: enables vertical scrolling
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(daySlotSection: DaySlotSection) {
        let highlighted = !daySlotSection.timeItems.isEmpty
        label.text = DateFormatterFactory.weekDayFormatter().string(from: daySlotSection.date)
        topBar.backgroundColor = highlighted ? .orange : .systemGray6
        label.textColor = highlighted ? .gray: .systemGray4
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for slot in daySlotSection.timeItems {
            let timeButton = TimeSlotButton()
            timeButton.configure(text: slot.timeSlotStr, booked: slot.booked)
            stackView.addArrangedSubview(timeButton)
        }
    }
}
