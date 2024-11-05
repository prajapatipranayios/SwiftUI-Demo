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
    
    // Closure to handle item selection
    var onSelection: (([Any]) -> Void)?
    
    private let tableView = UITableView()
    private let confirmButton = UIButton(type: .system)
    
    // MARK: - Initializer
    
    init(items: [Any], multipleSelection: Bool = false, shouldAnimate: Bool = false) {
        self.items = items
        self.isMultipleSelectionEnabled = multipleSelection
        self.shouldAnimate = shouldAnimate
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
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = isMultipleSelectionEnabled
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        // Confirm button setup
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmSelection), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(confirmButton)
        
        // Dynamic height constraint calculation
        let maxTableViewHeight = view.frame.height - 100
        
        // Layout constraints
        NSLayoutConstraint.activate([
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: maxTableViewHeight)
        ])
        
        // Force layout update
        view.layoutIfNeeded()
        
        // Call animateAppearance with the `shouldAnimate` parameter
        animateAppearance(shouldAnimate: shouldAnimate)
    }
    
    private func animateAppearance(shouldAnimate: Bool = false) {
        if shouldAnimate {
            view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity
            }
        } else {
            view.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func confirmSelection() {
        onSelection?(selectedItems)
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
}
