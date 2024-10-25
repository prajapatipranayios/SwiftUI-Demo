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
    
    init(frame: CGRect, selectionMode: DateSelectionMode) {
        self.selectionMode = selectionMode
        self.currentMonth = Date()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setupToolbar()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarDateCell.self, forCellWithReuseIdentifier: "CalendarDateCell")
        collectionView.backgroundColor = .white
        //self.backgroundColor = .black.withAlphaComponent(0.6)
        
        self.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 50),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
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
    
    @objc private func cancelTapped() {
        onCancel?()
    }
    
    @objc private func doneTapped() {
        onDone?(selectedDates)
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let month = monthFor(section: indexPath.section)
        let dayOffset = indexPath.row - firstWeekdayOffset(for: month)
        if dayOffset >= 0 {
            let date = dateFor(dayOffset, in: month)
            if isDateWithinBounds(date) {
                handleDateSelection(date)
                collectionView.reloadData()
            }
        }
    }
    
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
    
    private func handleDateSelection(_ date: Date) {
        switch selectionMode {
        case .single:
            selectedDates = [date]
        case .range:
            if startDate == nil {
                startDate = date
            } else if endDate == nil {
                endDate = date
                selectedDates = datesInRange(from: startDate!, to: endDate!)
            } else {
                startDate = date
                endDate = nil
                selectedDates = []
            }
        case .multiple:
            if let index = selectedDates.firstIndex(of: date) {
                selectedDates.remove(at: index)
            } else {
                selectedDates.append(date)
            }
        }
    }
    
    private func isDateSelected(_ date: Date) -> Bool {
        return selectedDates.contains(date)
    }
    
    private func isDateWithinBounds(_ date: Date) -> Bool {
        if let minDate = minimumDate, date < minDate { return false }
        if let maxDate = maximumDate, date > maxDate { return false }
        return true
    }
    
    private func datesInRange(from start: Date, to end: Date) -> [Date] {
        var dates = [Date]()
        var currentDate = start
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
}

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



/// For call Date
//func selectDate() {
//    let datePickerFrame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: (self.view.frame.height * 0.7))
//    datePickerView = CustomDatePickerView(frame: datePickerFrame, selectionMode: .single) // or .single, .multiple
//    
//    // Set date bounds (optional)
//    datePickerView.minimumDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) // 30 days ago
//    datePickerView.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())  // 30 days ahead
//    
//    // Handle the done action when dates are selected
//    datePickerView.onDone = { [weak self] selectedDates in
//        self?.handleDateSelection(selectedDates)
//    }
//    
//    // Handle the cancel action
//    datePickerView.onCancel = { [weak self] in
//        self?.dismissDatePicker()
//    }
//    
//    self.view.addSubview(datePickerView)
//}
//
//private func handleDateSelection(_ selectedDates: [Date]) {
//    // Process the selected dates
//    print("Selected Dates: \(selectedDates)")
//    
//    // Dismiss or update UI as needed
//    // Example: Dismiss view controller after selection
//    dismissDatePicker()
//}
//
//private func dismissDatePicker() {
//    // Dismiss the view or remove it from the superview
//    datePickerView.removeFromSuperview()
//    // Or dismiss the view controller if it's presented modally
//    self.dismiss(animated: true, completion: nil)
//}
