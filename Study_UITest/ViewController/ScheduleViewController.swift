//
//  ScheduleViewController.swift
//  Study_UITest
//
//  Created by Feng on 2025/5/9.
//

import UIKit
import Combine

class ScheduleViewController: UIViewController {
    private let viewModel = ScheduleViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let titleLabel = UILabel()
    private let dateRangeLabel = UILabel()
    private let prevWeekButton = UIButton(type: .system)
    private let nextWeekButton = UIButton(type: .system)
    private let headerStack = UIStackView()
    private let timezoneNoteLabel = UILabel()
    private let weekdayCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        view.backgroundColor = .white
        
        // 標題
        titleLabel.text = "授課時間"
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 日期區間標題
        dateRangeLabel.textAlignment = .center
        dateRangeLabel.font = UIFont.systemFont(ofSize: 14)
        dateRangeLabel.translatesAutoresizingMaskIntoConstraints = false

        // 切換日期區間按鈕
        prevWeekButton.setTitle("←", for: .normal)
        nextWeekButton.setTitle("→", for: .normal)
        nextWeekButton.tintColor = .orange
        prevWeekButton.tintColor = .orange
        prevWeekButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        nextWeekButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        prevWeekButton.addTarget(self, action: #selector(didTapPreviousWeek), for: .touchUpInside)
        nextWeekButton.addTarget(self, action: #selector(didTapNextWeek), for: .touchUpInside)

        // 切換按鈕與日期區間排版
        headerStack.axis = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .center
        headerStack.distribution = .equalCentering
        headerStack.addArrangedSubview(prevWeekButton)
        headerStack.addArrangedSubview(dateRangeLabel)
        headerStack.addArrangedSubview(nextWeekButton)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)
        
        // 時區顯示提示
        let localTimeZone = TimeZone.current
        let timeZoneName = localTimeZone.identifier.replacingOccurrences(of: "_", with: " ").split(separator: "/").last ?? "Unknown Time Zone"
        let hoursFromGMT = localTimeZone.secondsFromGMT() / 3600
        let gmtOffset = String(format: "GMT %+03d:00", hoursFromGMT)
        timezoneNoteLabel.text = "* 時間以 \(timeZoneName) \(gmtOffset) 顯示"
        timezoneNoteLabel.font = UIFont.systemFont(ofSize: 12)
        timezoneNoteLabel.textColor = .gray
        timezoneNoteLabel.textAlignment = .center
        timezoneNoteLabel.numberOfLines = 0
        timezoneNoteLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timezoneNoteLabel)
        
        // 時間表
        (weekdayCollection.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        weekdayCollection.register(WeekDayCell.self, forCellWithReuseIdentifier: WeekDayCell.reuseId)
        weekdayCollection.dataSource = self
        weekdayCollection.delegate = self
        weekdayCollection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weekdayCollection)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            headerStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timezoneNoteLabel.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 4),
            timezoneNoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weekdayCollection.topAnchor.constraint(equalTo: timezoneNoteLabel.bottomAnchor, constant: 4),
            weekdayCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            weekdayCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            weekdayCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 8),
        ])
    }
    
    private func bindViewModel() {
        viewModel.$daySections
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if let first = self.viewModel.weekDates.first,
                   let last = self.viewModel.weekDates.last {
                    self.dateRangeLabel.text = "\(DateFormatterFactory.dateRangeFormatter().string(from: first)) – \(DateFormatterFactory.dateRangeFormatter().string(from: last))"
                }
                
                if let firstDate = self.viewModel.weekDates.first {
                    let today = Calendar.current.startOfDay(for: Date())
                    self.prevWeekButton.isEnabled = firstDate > today
                    self.prevWeekButton.tintColor = firstDate == today ? .systemGray2 : .orange
                }
                
                self.weekdayCollection.reloadData()
            }.store(in: &cancellables)
    }
    
    @objc private func didTapPreviousWeek() {
        viewModel.shiftWeek(by: -1)
    }

    @objc private func didTapNextWeek() {
        viewModel.shiftWeek(by: 1)
    }

}

extension ScheduleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.weekDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeekDayCell.reuseId, for: indexPath) as! WeekDayCell
        let daySlotSection = viewModel.daySections[indexPath.item]
        cell.configure(daySlotSection: daySlotSection)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: collectionView.bounds.height - 16)
    }
}


