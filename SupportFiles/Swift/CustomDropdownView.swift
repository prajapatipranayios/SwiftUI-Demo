//
//  DropdownView.swift
//  SwiftDemo1
//
//  Created by Auxano on 04/12/24.
//

import Foundation
import UIKit

class CustomDropdownView: UIView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    private let tableView = UITableView()
    private var items: [String] = []
    private var isExpanded = false
    private var parentView: UIView?
    private var dropdownDirection: DropdownDirection = .downward

    var didSelectItem: ((String) -> Void)?

    private var tapOutsideGesture: UITapGestureRecognizer?
    
    // New property to control text alignment
    var textAlignment: NSTextAlignment = .center {
        didSet {
            tableView.reloadData() // Reload table view when alignment changes
        }
    }
    
    
    enum DropdownDirection {
        case upward, downward
    }

    // MARK: - Initializer
    init(items: [String], parentView: UIView, textAlignment: NSTextAlignment = .center) {
        super.init(frame: .zero)
        self.items = items
        self.parentView = parentView
        self.textAlignment = textAlignment // Set custom text alignment
        setupTableView()
        addTapOutsideGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
        addTapOutsideGesture()
    }

    // MARK: - Setup Table View
    private func setupTableView() {
        tableView.isHidden = true
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.cornerRadius = 8
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.separatorStyle = .singleLine

        // Register UITableViewCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        if let parentView = parentView {
            parentView.addSubview(tableView)
        }
    }

    // MARK: - Add Tap Gesture to Detect Outside Taps
    private func addTapOutsideGesture() {
        guard let parentView = parentView else { return }

        // Create a tap gesture recognizer
        tapOutsideGesture = UITapGestureRecognizer(target: self, action: #selector(handleOutsideTap))
        tapOutsideGesture?.cancelsTouchesInView = false // Allow other touches to propagate

        if let tapOutsideGesture = tapOutsideGesture {
            parentView.addGestureRecognizer(tapOutsideGesture)
        }
    }

    @objc private func handleOutsideTap(_ gesture: UITapGestureRecognizer) {
        guard isExpanded, let parentView = parentView else { return }

        // Check if tap is outside the dropdown frame
        let tapLocation = gesture.location(in: parentView)
        if !self.frame.contains(tapLocation) && !tableView.frame.contains(tapLocation) {
            toggleDropdown() // Close the dropdown
        }
    }

    // MARK: - Calculate Dropdown Width
    private func calculateDropdownWidth() -> CGFloat {
        let maxScreenWidth = UIScreen.main.bounds.width * 0.7
        let maxTextWidth = items.map { text -> CGFloat in
            let label = UILabel()
            label.text = text
            label.sizeToFit()
            return label.frame.width
        }.max() ?? frame.width

        return min(maxTextWidth + 40, maxScreenWidth) // Add padding of 30 and cap at 70% of the screen width
    }

    // MARK: - Adjust Dropdown Direction
    private func adjustDropdownDirection() {
        guard let parentView = parentView else { return }
        let screenHeight = UIScreen.main.bounds.height
        let dropdownHeight = CGFloat(items.count * 44)
        
        // Get the position of the dropdown relative to the parent view
        let spaceBelow = screenHeight - frame.maxY
        let spaceAbove = frame.minY
        
        // If there's more space below than above, show the dropdown downward, otherwise upward
        dropdownDirection = (spaceBelow > spaceAbove) ? .downward : .upward
    }

    // MARK: - Update Table View Frame to Ensure It Stays within Screen Bounds
    private func updateTableViewFrame() {
        let dropdownHeight = CGFloat(items.count * 44)
        let dropdownWidth = calculateDropdownWidth()
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        var dropdownY: CGFloat
        var dropdownX: CGFloat

        // Determine dropdown Y based on direction (upward or downward)
        switch dropdownDirection {
        case .downward:
            dropdownY = frame.maxY
            if dropdownY + dropdownHeight > screenHeight {
                dropdownY = screenHeight - dropdownHeight // Position it near the bottom
            }
        case .upward:
            dropdownY = frame.minY - dropdownHeight
            if dropdownY < 0 {
                dropdownY = 0 // Position it near the top
            }
        }

        // Determine the horizontal position (X axis)
        dropdownX = frame.origin.x
        if dropdownX + dropdownWidth > screenWidth { // Adjust for right edge overflow
            dropdownX = screenWidth - dropdownWidth
        } else if dropdownX < 0 { // Adjust for left edge overflow
            dropdownX = 0
        }

        // Set the frame for the tableView
        tableView.frame = CGRect(x: dropdownX, y: dropdownY, width: dropdownWidth, height: min(dropdownHeight, screenHeight * 0.7)) // Cap height to 70% of the screen
    }

    // MARK: - Toggle Dropdown
    func toggleDropdown() {
        isExpanded.toggle()
        if isExpanded {
            adjustDropdownDirection() // Determine direction based on available space
            tableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.updateTableViewFrame()
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = CGRect(x: self.frame.origin.x, y: self.dropdownDirection == .downward ? self.frame.maxY : self.frame.minY, width: self.frame.width, height: 0)
            }) { _ in
                self.tableView.isHidden = true
            }
        }
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textAlignment = textAlignment
        cell.textLabel?.numberOfLines = 0 // Allow multi-line text
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        didSelectItem?(selectedItem)
        toggleDropdown()
    }

    // MARK: - Remove Gesture on Deinitialization
    deinit {
        if let parentView = parentView, let tapOutsideGesture = tapOutsideGesture {
            parentView.removeGestureRecognizer(tapOutsideGesture)
        }
    }
}
