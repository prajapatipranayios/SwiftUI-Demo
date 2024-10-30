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
    
    private var selectedDates: [Date] = []
    private let calendar = Calendar.current
    private var currentMonthDates: [Date] = []
    private var nextMonthDates: [Date] = []
    private let today = Date()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        loadDates()
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
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 44, width: view.bounds.width, height: view.bounds.height - 44), collectionViewLayout: layout)
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.register(CalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarHeaderView")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    // MARK: - Load Dates
    private func loadDates() {
        let currentMonth = calendar.dateInterval(of: .month, for: today)!
        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: currentMonth.start)!
        let nextMonth = calendar.dateInterval(of: .month, for: nextMonthStart)!
        
        currentMonthDates = datesInMonth(interval: currentMonth)
        nextMonthDates = datesInMonth(interval: nextMonth)
    }
    
    private func datesInMonth(interval: DateInterval) -> [Date] {
        var dates: [Date] = []
        var date = interval.start
        
        while date <= interval.end {
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
        return 2  // Current month and next month
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? currentMonthDates.count : nextMonthDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as? CalendarCell else {
            return UICollectionViewCell()
        }
        
        let date = indexPath.section == 0 ? currentMonthDates[indexPath.row] : nextMonthDates[indexPath.row]
        let isPastDate = calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
        let isSelectable = !isPastDate
        
        cell.configure(with: date, isSelected: selectedDates.contains(date), isSelectable: isSelectable, selectionColor: selectionColor, selectionShape: selectionShape)
        return cell
    }
    
    // MARK: - Section Headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarHeaderView", for: indexPath) as? CalendarHeaderView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = indexPath.section == 0 ? "Current Month" : "Next Month"
        return header
    }
    
    // MARK: - Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = indexPath.section == 0 ? currentMonthDates[indexPath.row] : nextMonthDates[indexPath.row]
        let isPastDate = calendar.compare(date, to: today, toGranularity: .day) == .orderedAscending
        
        guard !isPastDate else { return }
        
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
    
    func configure(with date: Date, isSelected: Bool, isSelectable: Bool, selectionColor: UIColor, selectionShape: DateSelectionShape) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)
        
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
