//
//  CustomDateSelection.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/10/24.
//

import Foundation
import UIKit

// CalendarViewController.swift

enum DateSelectionMode {
    case single
    case multiple
    case range
}

enum DateSelectionShape {
    case round
    case square
    case roundedCSquare
    case custom
}



class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    var collectionView: UICollectionView!
    var selectionMode: DateSelectionMode = .single
    var selectionColor: UIColor = .lightBlue
    var calendarBgColor: UIColor = .white
    var calendarTextColor: UIColor = .black
    var selectionShape: DateSelectionShape = .round
    var customDateFormatter: DateFormatter?
    
    var onDatesSelected: (([String]) -> Void)?
    
    var monthsBefore: Int = 0
    var monthsAfter: Int = 0
    var disablePastDates: Bool = false
    
    private var selectedDates: [Date] = []
    private let calendar = Calendar.current
    private var monthsData: [[Date?]] = []
    private var monthNames: [String] = []
    private let today = Date()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupWeekdayHeader()
        setupCollectionView()
        loadMonthsData()
    }
    
    // MARK: - Setup Weekday Header
    private func setupWeekdayHeader() {
        let weekdayHeader = WeekdayHeaderView(frame: CGRect(x: 0, y: 44, width: view.frame.width, height: 30))
        weekdayHeader.backgroundColor = self.selectionColor
        view.backgroundColor = self.calendarBgColor
        view.addSubview(weekdayHeader)
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let navItem = UINavigationItem(title: "Select Dates")
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        
        navItem.rightBarButtonItem = doneButton
        navItem.leftBarButtonItem = cancelButton
        
        navBar.items = [navItem]
        view.addSubview(navBar)
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        //layout.itemSize = CGSize(width: view.frame.width / 7, height: 40)
        layout.itemSize = CGSize(width: view.frame.width / 7, height: view.frame.width / 7)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 30) // Header size
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 74, width: view.bounds.width, height: view.bounds.height - 144), collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarHeaderView")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = self.calendarBgColor
        view.addSubview(collectionView)
    }
    
    // MARK: - Load Months Data
    private func loadMonthsData() {
        monthsData = []
        monthNames = []
        
        for offset in -monthsBefore...monthsAfter {
            if let monthStart = calendar.date(byAdding: .month, value: offset, to: today) {
                let monthName = DateFormatter().monthSymbols[calendar.component(.month, from: monthStart) - 1]
                monthNames.append(monthName)
                
                let monthInterval = calendar.dateInterval(of: .month, for: monthStart)!
                let monthDates = datesWithWeekdayAlignment(for: monthInterval)
                monthsData.append(monthDates)
            }
        }
    }
    
    private func datesWithWeekdayAlignment(for interval: DateInterval) -> [Date?] {
        var dates: [Date?] = []
        
        let firstDate = interval.start
        let weekday = calendar.component(.weekday, from: firstDate)
        
        for _ in 1..<weekday {
            dates.append(nil)
        }
        
        var date = firstDate
        while calendar.isDate(date, equalTo: interval.start, toGranularity: .month) {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return dates
    }
    
    // MARK: - Button Actions
    @objc private func doneButtonTapped() {
        let formattedDates = selectedDates.map { formatDate($0) }
        onDatesSelected?(formattedDates)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let date = monthsData[indexPath.section][indexPath.row]
        
        if let validDate = date {
            let isPastDate = disablePastDates && calendar.compare(validDate, to: today, toGranularity: .day) == .orderedAscending
            let isSelectable = !isPastDate
            
            cell.configure(with: validDate, isSelected: selectedDates.contains(validDate), isSelectable: isSelectable, textColor: self.calendarTextColor, bgColor: self.calendarBgColor, selectionColor: selectionColor, selectionShape: selectionShape)
        } else {
            cell.configure(with: nil, isSelected: false, isSelectable: false, textColor: self.calendarTextColor, bgColor: self.calendarBgColor, selectionColor: selectionColor, selectionShape: selectionShape)
        }
        
        return cell
    }
    
    // MARK: - Section Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarHeaderView", for: indexPath) as? CalendarHeaderView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = monthNames[indexPath.section]
        header.titleLabel.textColor = (self.calendarBgColor == self.calendarTextColor) ? (self.calendarBgColor == .black ? .white : .black) : self.calendarTextColor
        return header
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = monthsData[indexPath.section][indexPath.row],
              !disablePastDates || calendar.compare(date, to: today, toGranularity: .day) != .orderedAscending else {
            return
        }
        
        switch selectionMode {
        case .single:
            selectedDates = [date]
        case .multiple:
            if selectedDates.contains(date) {
                selectedDates.removeAll { $0 == date }
            } else {
                selectedDates.append(date)
            }
        case .range:
            if selectedDates.count == 1 {
                selectedDates.append(date)
                selectedDates.sort()
                // Add dates between the range
                if let start = selectedDates.first, let end = selectedDates.last {
                    selectedDates = datesBetween(start: start, end: end)
                }
            } else {
                // Reset to only one date (the starting date)
                selectedDates = [date]
            }
            /*if selectedDates.count == 2 {
             selectedDates = [date]
             } else {
             selectedDates.append(date)
             if selectedDates.count == 2 {
             selectedDates.sort()
             }
             }   //  */
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Helper to Calculate Dates Between Range
    private func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = start
        
        while currentDate <= end {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    // MARK: - Date Formatter
    private func formatDate(_ date: Date) -> String {
        let formatter = customDateFormatter ?? DateFormatter()
        formatter.dateFormat = customDateFormatter?.dateFormat ?? "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0) // Space between months
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



// MARK: - Weekday Header View
class WeekdayHeaderView: UIView {
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWeekdayLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWeekdayLabels()
    }
    
    private func setupWeekdayLabels() {
        let labelWidth = frame.width / 7
        for (index, day) in weekdays.enumerated() {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.frame = CGRect(x: CGFloat(index) * labelWidth, y: 0, width: labelWidth, height: frame.height)
            addSubview(label)
        }
    }
}



// MARK: - Calendar Header View
class CalendarHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CalendarCell: UICollectionViewCell {
    
    private let dateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(with date: Date?, isSelected: Bool, isSelectable: Bool, textColor: UIColor, bgColor: UIColor, selectionColor: UIColor, selectionShape: DateSelectionShape) {
        
        if let date = date {
            // Configure for a valid date
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            dateLabel.text = formatter.string(from: date)
            //dateLabel.textColor = isSelectable ? ((textColor == .black) ? .white : .black) : .lightGray
            dateLabel.textColor = isSelectable ? ((bgColor == textColor) ? (bgColor == .black ? .white : .black) : textColor) : .lightGray
            backgroundColor = isSelected ? selectionColor : .clear
        } else {
            // Handle empty placeholder cell
            dateLabel.text = ""
            backgroundColor = .clear
        }
        
        if isSelectable {
            backgroundColor = isSelected ? selectionColor : .clear
            //dateLabel.textColor = (textColor == .black) ? .white : textColor
            dateLabel.textColor = (bgColor == textColor) ? (bgColor == .black ? .white : .black) : textColor
            isUserInteractionEnabled = true
        } else {
            backgroundColor = .clear
            dateLabel.textColor = .lightGray
            isUserInteractionEnabled = false
        }
        
        switch selectionShape {
        case .round:
            layer.cornerRadius = frame.width / 2
            layer.masksToBounds = true
        case .square:
            layer.cornerRadius = 0
        case .roundedCSquare:
            layer.cornerRadius = frame.width / 4
        case .custom:
            layer.cornerRadius = frame.width / 4
        }
    }
}


// MARK: - Extensions
extension UIColor {
    static let lightBlue = UIColor(red: 0.68, green: 0.85, blue: 1.0, alpha: 1.0)
}


/*// Function to configure and show the custom date picker
 private func setupDatePicker() {
     let calendarVC = CalendarViewController()
     
     // Customize the calendar settings
     //calendarVC.selectionMode = .multiple  // Options: .single, .multiple, .range
     calendarVC.selectionMode = .range  // Options: .single, .multiple, .range
     calendarVC.selectionColor = .lightBlue  // Custom selection color
     calendarVC.selectionShape = .custom    // Options: .round, .square, .custom
     //calendarVC.monthsBefore = 2
     calendarVC.monthsAfter   = 1
     calendarVC.disablePastDates = true
     
     // Custom date format example
     let dateFormatter = DateFormatter()
     dateFormatter.dateFormat = "dd-MM-yyyy"
     calendarVC.customDateFormatter = dateFormatter
     
     // Set up the closure to receive selected dates
     calendarVC.onDatesSelected = { selectedDates in
         print("Selected Dates: \(selectedDates)")  // Handle dates as needed
     }
     
     // Present the CalendarViewController
     self.present(calendarVC, animated: true, completion: nil)
 }   //  */
