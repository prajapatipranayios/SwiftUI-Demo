//
//  CustomDateSelection.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/10/24.
//

import Foundation
import UIKit

enum DateSelectionMode {
    case single
    case range
    case multiple
}

class CustomDatePickerView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    var selectionMode: DateSelectionMode = .single
    var selectedDates: [Date] = []
    var startDate: Date?
    var endDate: Date?
    var calendar = Calendar.current
    var currentMonth: Date
    var minimumDate: Date?
    var maximumDate: Date?
    
    var previousMonthLimit: Int = 1
    var nextMonthLimit: Int = 1
    
    var onCancel: (() -> Void)?
    var onDone: (([Date]) -> Void)?
    
    private var backgroundView: UIView!

    // Init with a selection mode and frame
    init(frame: CGRect = UIScreen.main.bounds, selectionMode: DateSelectionMode = .range) {
        self.selectionMode = selectionMode
        self.currentMonth = Date() // Start with the current month
        super.init(frame: frame)
        setupTransparentBackground()
        setupView()
        animateDatePickerIn()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup transparent background
    private func setupTransparentBackground() {
        backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        addSubview(backgroundView)
        
        // Dismiss picker on background tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // Setup view with default frame and properties
    private func setupView() {
        // Set up the top toolbar
        setupToolbar()
        
        // Setup collection view for the calendar
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarDateCell.self, forCellWithReuseIdentifier: "CalendarDateCell")
        collectionView.backgroundColor = .white
        
        // Default date bounds: one month before and one month after today
        minimumDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())

        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    // Set up toolbar
    private func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        let titleLabel = UILabel()
        titleLabel.text = "Select Date"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        let titleItem = UIBarButtonItem(customView: titleLabel)
        
        toolbar.setItems([cancelButton, UIBarButtonItem.flexibleSpace(), titleItem, UIBarButtonItem.flexibleSpace(), doneButton], animated: false)
        
        self.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: self.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // Date Picker In Animation
    private func animateDatePickerIn() {
        self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }

    // Date Picker Out Animation and dismiss
    @objc private func cancelTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        }) { _ in
            self.removeFromSuperview()
        }
        onCancel?()
    }
    
    // Done action with selected dates
    @objc private func doneTapped() {
        onDone?(selectedDates)
        cancelTapped() // Dismiss the picker
    }

    // MARK: - Date Selection Logic
    private func handleDateSelection(_ date: Date) {
        switch selectionMode {
        case .single:
            selectedDates = [date]
        case .range:
            if startDate == nil {
                startDate = date
                selectedDates = [date]
            } else if endDate == nil {
                if date < startDate! {
                    endDate = startDate
                    startDate = date
                } else {
                    endDate = date
                }
                selectedDates = datesInRange(from: startDate!, to: endDate!)
            } else {
                startDate = date
                endDate = nil
                selectedDates = [date]
            }
        case .multiple:
            if let index = selectedDates.firstIndex(of: date) {
                selectedDates.remove(at: index)
            } else {
                selectedDates.append(date)
            }
        }
    }
    
    // Helper to get dates in the selected range
    private func datesInRange(from start: Date, to end: Date) -> [Date] {
        var dates = [Date]()
        var currentDate = start
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }

    // MARK: - UICollectionView DataSource & Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return previousMonthLimit + 1 + nextMonthLimit
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let month = monthFor(section: section)
        let range = calendar.range(of: .day, in: .month, for: month)!
        return range.count + firstWeekdayOffset(for: month)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDateCell", for: indexPath) as! CalendarDateCell
        let month = monthFor(section: indexPath.section)
        let dayOffset = indexPath.row - firstWeekdayOffset(for: month)
        
        if dayOffset >= 0 {
            let date = dateFor(dayOffset, in: month)
            cell.configure(with: date, isSelected: isDateSelected(date), isEnabled: isDateWithinBounds(date))
        } else {
            cell.configure(with: nil, isSelected: false)
        }
        
        return cell
    }

    // Helper functions to calculate dates
    private func monthFor(section: Int) -> Date {
        let components = DateComponents(month: section - previousMonthLimit)
        return calendar.date(byAdding: components, to: currentMonth)!
    }
    
    private func firstWeekdayOffset(for month: Date) -> Int {
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        return weekday - calendar.firstWeekday
    }
    
    private func dateFor(_ dayOffset: Int, in month: Date) -> Date {
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = dayOffset + 1
        return calendar.date(from: components)!
    }

    private func isDateSelected(_ date: Date) -> Bool {
        return selectedDates.contains(date)
    }

    private func isDateWithinBounds(_ date: Date) -> Bool {
        if let minDate = minimumDate, date < minDate { return false }
        if let maxDate = maximumDate, date > maxDate { return false }
        return true
    }
}

// MARK: - Custom CollectionViewCell
class CalendarDateCell: UICollectionViewCell {

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true
    }

    func configure(with date: Date?, isSelected: Bool, isEnabled: Bool = true) {
        if let date = date {
            let day = Calendar.current.component(.day, from: date)
            dateLabel.text = "\(day)"
            contentView.backgroundColor = isSelected ? .systemBlue : .clear
            dateLabel.textColor = isSelected ? .white : (isEnabled ? .black : .lightGray)
        } else {
            dateLabel.text = nil
            contentView.backgroundColor = .clear
        }
    }
}
