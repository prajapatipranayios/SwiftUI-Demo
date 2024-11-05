//
//  CustomActionSheetViewController.swift
//
//  Created by Pranay on 05/11/24.
//

import Foundation
import UIKit

class CustomActionSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let items: [Any] // Can be either [String] or [Int]
    private let isMultipleSelectionEnabled: Bool
    private var selectedItems = [Any]()
    private let shouldAnimate: Bool
    private let rowHeight: CGFloat
    
    // Customizable button colors and texts
    private let cancelButtonBackgroundColor: UIColor
    private let confirmButtonBackgroundColor: UIColor
    private let cancelButtonTextColor: UIColor
    private let confirmButtonTextColor: UIColor
    private let cancelButtonText: String
    private let confirmButtonText: String
    private let cancelButtonFontSize: CGFloat
    private let confirmButtonFontSize: CGFloat
    
    // Title properties
    private let titleText: String
    private let titleBackgroundColor: UIColor
    private let titleTextColor: UIColor
    private let titleFontSize: CGFloat
    
    // Closure to handle item selection
    var onSelection: (([Any]) -> Void)?
    
    private let containerView = UIView()
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initializer
    
    init(
        items: [Any],
        multipleSelection: Bool = false,
        shouldAnimate: Bool = false,
        rowHeight: CGFloat = 45,
        cancelButtonBackgroundColor: UIColor = .brown,
        confirmButtonBackgroundColor: UIColor = .white,
        cancelButtonTextColor: UIColor = .systemBlue,
        confirmButtonTextColor: UIColor = .systemBlue,
        cancelButtonText: String = "Cancel",
        confirmButtonText: String = "Done",
        cancelButtonFontSize: CGFloat = 19,
        confirmButtonFontSize: CGFloat = 19,
        titleText: String = "Select Option",
        titleBackgroundColor: UIColor = .white,
        titleTextColor: UIColor = .black,
        titleFontSize: CGFloat = 20
    ) {
        self.items = items
        self.isMultipleSelectionEnabled = multipleSelection
        self.shouldAnimate = shouldAnimate
        self.cancelButtonBackgroundColor = cancelButtonBackgroundColor
        self.confirmButtonBackgroundColor = confirmButtonBackgroundColor
        self.cancelButtonTextColor = cancelButtonTextColor
        self.confirmButtonTextColor = confirmButtonTextColor
        self.cancelButtonText = cancelButtonText
        self.confirmButtonText = confirmButtonText
        self.cancelButtonFontSize = cancelButtonFontSize
        self.confirmButtonFontSize = confirmButtonFontSize
        self.rowHeight = rowHeight
        self.titleText = titleText
        self.titleBackgroundColor = titleBackgroundColor
        self.titleTextColor = titleTextColor
        self.titleFontSize = titleFontSize
        super.init(nibName: nil, bundle: nil)
        
        if shouldAnimate {
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .coverVertical
        } else {
            modalPresentationStyle = .overCurrentContext
            modalTransitionStyle = .crossDissolve
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustTableViewHeight()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Container view setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 15.0
        view.addSubview(containerView)
        
        // Title label setup
        titleLabel.text = titleText
        titleLabel.backgroundColor = titleBackgroundColor
        titleLabel.textColor = titleTextColor
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = isMultipleSelectionEnabled
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(tableView)
        
        // Cancel button setup
        cancelButton.setTitle(cancelButtonText, for: .normal)
        cancelButton.backgroundColor = cancelButtonBackgroundColor
        cancelButton.setTitleColor(cancelButtonTextColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: cancelButtonFontSize) // Set text size
        cancelButton.addTarget(self, action: #selector(cancelSelection), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)
        
        // Confirm button setup
        confirmButton.setTitle(confirmButtonText, for: .normal)
        confirmButton.backgroundColor = confirmButtonBackgroundColor
        confirmButton.setTitleColor(confirmButtonTextColor, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: confirmButtonFontSize) // Set text size
        confirmButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(confirmButton)
        
        // Dynamic height constraint calculation
        let maxTableViewHeight = view.frame.height - 200
        
        // Layout constraints
        NSLayoutConstraint.activate([
            
            // Center container view in main view
            //containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            
            // Confirm and Cancel buttons layout
            cancelButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0),
            confirmButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor),
            
            
            // Button dimensions
            //cancelButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            //confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Title label layout
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 55),
            
            // TableView layout
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            //tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            //tableView.heightAnchor.constraint(lessThanOrEqualToConstant: maxTableViewHeight),
            //tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
            
        ])
        
        // Call animateAppearance with the `shouldAnimate` parameter
        animateAppearance(shouldAnimate: shouldAnimate)
    }
    
    private func adjustTableViewHeight() {
        // Calculate maximum height based on the available space
        let maxTableViewHeight = view.frame.height - 200
        
        // Remove existing height constraint if any
        //if let existingConstraint = tableViewHeightConstraint {
            //tableView.removeConstraint(existingConstraint)
        //}
        
        // Apply new height constraint
        //tableViewHeightConstraint = tableView.heightAnchor.constraint(lessThanOrEqualToConstant: maxTableViewHeight)
        //tableViewHeightConstraint?.isActive = true
        
        self.tableView.heightAnchor.constraint(equalToConstant: (CGFloat(self.items.count * 45) > maxTableViewHeight ? maxTableViewHeight : CGFloat(self.items.count * 45))).isActive = true
        
        self.tableView.isScrollEnabled = CGFloat(self.items.count * 45) > maxTableViewHeight ? true : false
        
        // Force layout update
        view.layoutIfNeeded()
    }
    
    private func animateAppearance(shouldAnimate: Bool = false) {
        if shouldAnimate {
            view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity
            }
            
            self.tableView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.tableView.transform = .identity
            }
        } else {
            view.transform = .identity
            self.tableView.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func confirmSelection() {
        onSelection?(selectedItems)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelSelection() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource & Delegate

extension CustomActionSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(items[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        
        if isMultipleSelectionEnabled {
            selectedItems.append(selectedItem)
        } else {
            selectedItems = [selectedItem]
            confirmSelection()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isMultipleSelectionEnabled {
            let deselectedItem = items[indexPath.row]
            if let index = selectedItems.firstIndex(where: { "\($0)" == "\(deselectedItem)" }) {
                selectedItems.remove(at: index)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
}
