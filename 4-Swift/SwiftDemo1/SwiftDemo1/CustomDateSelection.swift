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


class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // MARK: - Properties
    var collectionView: UICollectionView!
    var selectionMode: DateSelectionMode = .single
    var selectionColor: UIColor = .lightBlue
    var selectionShape: DateSelectionShape = .round
    var customDateFormatter: DateFormatter?
    
    var onDatesSelected: (([String]) -> Void)?
    
    // Customizable properties for months before and after the current month
    var monthsBefore: Int = 0  // Number of months before the current month
    var monthsAfter: Int = 0   // Number of months after the current month
    var disablePastDates: Bool = false // Disable all past dates

    private var selectedDates: [Date] = []
    private let calendar = Calendar.current
    private var monthsData: [[Date?]] = []  // Array of arrays, each containing dates for a month
    private var monthNames: [String] = []   // Names of the months displayed
    private let today = Date()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        loadMonthsData()
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
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 30) // Header size
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 44, width: view.bounds.width, height: view.bounds.height - 100), collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarHeaderView")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    // MARK: - Load Months Data
    private func loadMonthsData() {
        monthsData = []
        monthNames = []
        
        // Calculate months from previous, current, to future
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
        
        // Get the weekday of the first date (1 = Sunday, ..., 7 = Saturday)
        let firstDate = interval.start
        let weekday = calendar.component(.weekday, from: firstDate)
        
        // Add nil placeholders to align the first date of the month with the correct weekday
        for _ in 1..<weekday {
            dates.append(nil)
        }
        
        // Populate actual dates of the month, stopping before next month starts
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
        return monthsData.count  // Each month is its own section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsData[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let date = monthsData[indexPath.section][indexPath.row]
        
        // Determine if cell is selectable based on whether it's a past or future date
        if let validDate = date {
            let isPastDate = disablePastDates && calendar.compare(validDate, to: today, toGranularity: .day) == .orderedAscending
            let isSelectable = !isPastDate
            
            // Configure cell with valid date
            cell.configure(with: validDate, isSelected: selectedDates.contains(validDate), isSelectable: isSelectable, selectionColor: selectionColor, selectionShape: selectionShape)
        } else {
            // Configure cell as a placeholder (empty cell)
            cell.configure(with: nil, isSelected: false, isSelectable: false, selectionColor: selectionColor, selectionShape: selectionShape)
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
            if selectedDates.count == 2 {
                selectedDates = [date]
            } else {
                selectedDates.append(date)
                if selectedDates.count == 2 {
                    selectedDates.sort()
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    // MARK: - Date Formatter
    private func formatDate(_ date: Date) -> String {
        let formatter = customDateFormatter ?? DateFormatter()
        formatter.dateFormat = customDateFormatter?.dateFormat ?? "dd-MM-yyyy"
        return formatter.string(from: date)
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
    
    func configure(with date: Date?, isSelected: Bool, isSelectable: Bool, selectionColor: UIColor, selectionShape: DateSelectionShape) {
        //let formatter = DateFormatter()
        //formatter.dateFormat = "d"
        //dateLabel.text = formatter.string(from: date)
        
        if let date = date {
            // Configure for a valid date
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            dateLabel.text = formatter.string(from: date)
            dateLabel.textColor = isSelectable ? .black : .lightGray
            backgroundColor = isSelected ? selectionColor : .clear
        } else {
            // Handle empty placeholder cell
            dateLabel.text = ""
            backgroundColor = .clear
        }
        
        if isSelectable {
            backgroundColor = isSelected ? selectionColor : .clear
            dateLabel.textColor = .black
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
            layer.cornerRadius = 10
        case .custom:
            layer.cornerRadius = frame.width / 4
        }
    }
}






/*class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
 
 // MARK: - Properties
 var collectionView: UICollectionView!
 var selectionMode: DateSelectionMode = .single
 var selectionColor: UIColor = .lightBlue
 var selectionShape: DateSelectionShape = .round
 var customDateFormatter: DateFormatter?
 
 // Closure to return selected dates to ViewController
 var onDatesSelected: (([String]) -> Void)?
 
 private var selectedDates: [Date] = []
 private let calendar = Calendar.current
 
 // MARK: - Initialization
 override func viewDidLoad() {
 super.viewDidLoad()
 setupNavigationBar()
 setupCollectionView()
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
 layout.itemSize = CGSize(width: 40, height: 40)
 layout.minimumInteritemSpacing = 5
 layout.minimumLineSpacing = 5
 
 collectionView = UICollectionView(frame: CGRect(x: 0, y: 44, width: view.bounds.width, height: view.bounds.height - 44), collectionViewLayout: layout)
 collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
 collectionView.delegate = self
 collectionView.dataSource = self
 view.addSubview(collectionView)
 }
 
 // MARK: - Button Actions
 @objc private func doneButtonTapped() {
 let formattedDates = selectedDates.map { formatDate($0) }
 onDatesSelected?(formattedDates)  // Pass selected dates to closure
 dismiss(animated: true, completion: nil)
 }
 
 @objc private func cancelButtonTapped() {
 dismiss(animated: true, completion: nil)  // Simply dismiss the view
 }
 
 // MARK: - Collection View Data Source
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 // Assume 30 days for simplicity
 return 30
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
 return UICollectionViewCell()
 }
 
 let date = calendar.date(byAdding: .day, value: indexPath.row, to: Date()) ?? Date()
 cell.configure(with: date, isSelected: selectedDates.contains(date), selectionColor: selectionColor, selectionShape: selectionShape)
 return cell
 }
 
 // MARK: - Collection View Delegate
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
 let date = calendar.date(byAdding: .day, value: indexPath.row, to: Date()) ?? Date()
 
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
 if selectedDates.count == 2 {
 selectedDates = [date]
 } else {
 selectedDates.append(date)
 if selectedDates.count == 2 {
 selectedDates.sort()
 }
 }
 }
 
 collectionView.reloadData()
 }
 
 // MARK: - Date Formatter
 private func formatDate(_ date: Date) -> String {
 let formatter = customDateFormatter ?? DateFormatter()
 formatter.dateFormat = customDateFormatter?.dateFormat ?? "dd-MM-yyyy"
 return formatter.string(from: date)
 }
 }   //  */

// MARK: - Extensions
extension UIColor {
    static let lightBlue = UIColor(red: 0.68, green: 0.85, blue: 1.0, alpha: 1.0)
}   //  */

/*class CalendarCell: UICollectionViewCell {
 
 private let dateLabel = UILabel()
 
 // MARK: - Initializer
 override init(frame: CGRect) {
 super.init(frame: frame)
 setupViews()
 }
 
 required init?(coder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 
 // MARK: - Setup Views
 private func setupViews() {
 dateLabel.textAlignment = .center
 dateLabel.translatesAutoresizingMaskIntoConstraints = false
 addSubview(dateLabel)
 
 NSLayoutConstraint.activate([
 dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
 dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
 ])
 }
 
 // MARK: - Configure Cell
 func configure(with date: Date, isSelected: Bool, selectionColor: UIColor, selectionShape: DateSelectionShape) {
 let formatter = DateFormatter()
 formatter.dateFormat = "d"
 dateLabel.text = formatter.string(from: date)
 
 // Set background color based on selection state
 backgroundColor = isSelected ? selectionColor : .clear
 
 // Apply selection shape
 switch selectionShape {
 case .round:
 layer.cornerRadius = frame.width / 2
 layer.masksToBounds = true
 case .square:
 layer.cornerRadius = 0
 case .custom:
 // Custom shape if needed (e.g., rounded corners)
 layer.cornerRadius = frame.width / 4
 }
 }
 }   //  */
