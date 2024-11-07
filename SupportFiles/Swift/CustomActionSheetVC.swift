//
//  CustomActionSheetVC.swift
//
//  Created by Pranay on 05/11/24.
//

import Foundation
import UIKit

class CustomActionSheetVC: UIViewController {
    
    // MARK: - Properties
    
    // Title properties
    private let titleText: String
    private let titleBackgroundColor: UIColor
    private let titleTextColor: UIColor
    private let titleFontSize: CGFloat
    
    private let items: [Any] // Can be either [String] or [Int]
    private let isMultipleSelectionEnabled: Bool
    private var selectedItems = [Any]()
    private let shouldAnimate: Bool
    private let rowHeight: CGFloat
    private let cellTextColor: UIColor
    private let selectionStyle: SelectionStyle
    
    // Customizable button colors and texts
    private let cancelButtonBackgroundColor: UIColor
    private let confirmButtonBackgroundColor: UIColor
    private let cancelButtonTextColor: UIColor
    private let confirmButtonTextColor: UIColor
    private let cancelButtonText: String
    private let confirmButtonText: String
    private let cancelButtonFontSize: CGFloat
    private let confirmButtonFontSize: CGFloat
    private var separatorColor: UIColor
    private let isCellBorder: Bool
    private let cellBordeColor: UIColor
    private let deselectColor: UIColor
    private let selectColor: UIColor
    private let deselectImage: UIImage?
    private let selectImage: UIImage?
    
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
        initialSelectedItems: [Any] = [],
        multipleSelection: Bool = false,
        shouldAnimate: Bool = false,
        titleText: String = "Select Option",
        titleBackgroundColor: UIColor = .white,
        titleTextColor: UIColor = .black,
        titleFontSize: CGFloat = 20,
        cancelButtonBackgroundColor: UIColor = .white,
        confirmButtonBackgroundColor: UIColor = .white,
        cancelButtonTextColor: UIColor = .black,
        confirmButtonTextColor: UIColor = .black,
        cancelButtonText: String = "Cancel",
        confirmButtonText: String = "Done",
        cancelButtonFontSize: CGFloat = 19,
        confirmButtonFontSize: CGFloat = 19,
        rowHeight: CGFloat = 48,
        separatorColor: UIColor? = nil,
        isCellBorder: Bool = false,
        cellTextColor: UIColor = .black,
        cellBordeColor: UIColor = .lightGray,
        deselectColor: UIColor = .lightGray,
        selectColor: UIColor = .green,
        deselectImage: UIImage? = nil,
        selectImage: UIImage? = nil,
        selectionStyle: SelectionStyle? = nil
    ) {
        self.items = items
        self.selectedItems = initialSelectedItems // Assign initial selected items
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
        self.separatorColor = titleBackgroundColor
        self.isCellBorder = isCellBorder
        self.cellTextColor = cellTextColor
        self.cellBordeColor = cellBordeColor
        self.deselectColor = deselectColor
        self.selectColor = selectColor
        self.deselectImage = deselectImage
        self.selectImage = selectImage
        self.selectionStyle = selectionStyle ?? (multipleSelection ? .square : .round)
        
        if let sepColor = separatorColor {
            self.separatorColor = sepColor
        }
        
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
        
        // Register the custom cell class
        CustomActionSheetCell.SelectionStyle.none
        tableView.register(CustomActionSheetCell.self, forCellReuseIdentifier: "CustomActionSheetCell")
        
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
        containerView.backgroundColor = self.separatorColor
        view.addSubview(containerView)
        
        // Title label setup
        titleLabel.text = titleText
        titleLabel.backgroundColor = titleBackgroundColor
        titleLabel.textColor = titleTextColor
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)
        
        // TableView setup
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = isMultipleSelectionEnabled
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
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
        _ = view.frame.height - 190
        
        // Layout constraints
        NSLayoutConstraint.activate([
            
            // Center container view in main view
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15),
            
            // Confirm and Cancel buttons layout
            cancelButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 1),
            confirmButton.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 0),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
            confirmButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor),
            
            
            // Button dimensions
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 45),
            //confirmButton.heightAnchor.constraint(equalToConstant: 45),
            confirmButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor, multiplier: 1),
            
            // Title label layout
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 55),
            
            // TableView layout
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
        ])
        
        // Call animateAppearance with the `shouldAnimate` parameter
        animateAppearance(shouldAnimate: shouldAnimate)
    }
    
    private func adjustTableViewHeight() {
        // Calculate maximum height based on the available space
        let maxTableViewHeight = view.frame.height - 190
        
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

extension CustomActionSheetVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomActionSheetCell", for: indexPath) as! CustomActionSheetCell
        let itemText = "\(items[indexPath.row])"
        let isSelected = selectedItems.contains { "\($0)" == itemText }
        
        // Set selection style based on the selectionStyle property
        let isRoundSelection = (selectionStyle == .round)
        
        // Set selection style based on whether multiple selection is enabled
        cell.configure(
            with: itemText, 
            textColor: self.cellTextColor,
            isSelectedState: isSelected,
            isRoundSelection: isRoundSelection,
            selectedColor: self.selectColor,
            unselectedColor: self.deselectColor,
            hasBorder: self.isCellBorder, // Pass border option here
            bordeColor: cellBordeColor,
            unselectedImage: self.deselectImage,
            selectedImage: self.selectImage
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        
        if isMultipleSelectionEnabled {
            if !selectedItems.contains(where: { ($0 as? String) == (selectedItem as? String) }) {
                selectedItems.append(selectedItem)
            }
            else {
                if let index = selectedItems.firstIndex(where: { "\($0)" == "\(selectedItem)" }) {
                    selectedItems.remove(at: index)
                }
            }
        } else {
            selectedItems = [selectedItem]
            confirmSelection()
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isMultipleSelectionEnabled {
            let deselectedItem = items[indexPath.row]
            if let index = selectedItems.firstIndex(where: { "\($0)" == "\(deselectedItem)" }) {
                selectedItems.remove(at: index)
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
}


// Enum to define selection style
enum SelectionStyle {
    case round
    case square
}

class CustomActionSheetCell: UITableViewCell {
    
    // Selection indicator
    private let selectionIndicator = UIView()
    private let insetCircleLayer = CALayer()
    
    // Images for selected and unselected states
    var unselectedImage: UIImage?
    var selectedImage: UIImage?
    
    private let containerView = UIView() // Container view to add padding
    
    var isSelectedState: Bool = false {
        didSet {
            updateSelectionIndicator()
        }
    }

    // Configure selection colors
    var selectedColor: UIColor = .green
    var unselectedColor: UIColor = .gray
    var isRoundSelection: Bool = true
    var hasBorder: Bool = false // New property for border toggle
    var borderColor: UIColor = .lightGray
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set up container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Constraints for containerView to create a 5-point padding from contentView edges
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
        ])
        
        // Add selection indicator inside containerView
        selectionIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(selectionIndicator)
        
        // Constraints for selection indicator
        NSLayoutConstraint.activate([
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24),
            selectionIndicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            selectionIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Configure the outer circle layer
        selectionIndicator.layer.cornerRadius = 12 // Radius for round shape
        selectionIndicator.layer.borderWidth = 1.5 // Border width for outer circle
        selectionIndicator.layer.borderColor = isSelectedState ? selectedColor.cgColor : unselectedColor.cgColor
        selectionIndicator.layer.masksToBounds = true
        
        // Configure the inner inset layer
        insetCircleLayer.backgroundColor = selectedColor.cgColor
        insetCircleLayer.cornerRadius = 7 // Adjust radius for inset effect
        //insetCircleLayer.frame = CGRect(x: 2, y: 2, width: 20, height: 20) // Position inside the outer circle
        insetCircleLayer.frame = CGRect(x: 5, y: 5, width: 14, height: 14) // Position inside the outer circle
        
        selectionIndicator.layer.addSublayer(insetCircleLayer) // Add inset layer to outer layer
        
        updateBorder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        with text: String,
        textColor: UIColor,
        isSelectedState: Bool,
        isRoundSelection: Bool,
        selectedColor: UIColor,
        unselectedColor: UIColor,
        hasBorder: Bool,
        bordeColor: UIColor,
        unselectedImage: UIImage? = nil,
        selectedImage: UIImage? = nil
    ) {
        self.textLabel?.text = text
        self.textLabel?.textColor = textColor
        self.isSelectedState = isSelectedState
        self.isRoundSelection = isRoundSelection
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.hasBorder = hasBorder
        self.borderColor = bordeColor
        self.unselectedImage = unselectedImage
        self.selectedImage = selectedImage
        
        updateSelectionIndicator()
        updateBorder() // Update border when configuration is set
    }
    
    private func updateSelectionIndicator() {
        
        if let unselectedImage = unselectedImage, let selectedImage = selectedImage {
            // Use images for selection indicator
            selectionIndicator.layer.contents = isSelectedState ? selectedImage.cgImage : unselectedImage.cgImage
            selectionIndicator.layer.borderWidth = 0 // No border if using images
            selectionIndicator.backgroundColor = .clear
            insetCircleLayer.isHidden = true
        }
        else {
            // Configure shape based on selection type
            
            selectionIndicator.layer.contents = nil // Remove any set image
            selectionIndicator.layer.borderColor = isSelectedState ? selectedColor.cgColor : unselectedColor.cgColor
            insetCircleLayer.backgroundColor = selectedColor.cgColor
            selectionIndicator.layer.cornerRadius = isRoundSelection ? 12 : 4
            
            insetCircleLayer.cornerRadius = isRoundSelection ? 7 : 2 // Adjust radius based on shape
            insetCircleLayer.isHidden = !isSelectedState // Show only if selected
        }
    }
    
    private func updateBorder() {
        // Apply border to the containerView if hasBorder is true
        if hasBorder {
            containerView.layer.borderColor = self.borderColor.cgColor
            containerView.layer.borderWidth = 1.0
            containerView.layer.cornerRadius = 8
            containerView.clipsToBounds = true
        } else {
            containerView.layer.borderWidth = 0
        }
    }
}




// MARK: - For Call

//let actionSheet = CustomActionSheetVC(
//    items: <#T##[Any]#>,
//    initialSelectedItems: <#T##[Any]#>,
//    multipleSelection: <#T##Bool#>,
//    shouldAnimate: <#T##Bool#>,
//    titleText: <#T##String#>,
//    titleBackgroundColor: <#T##UIColor#>,
//    titleTextColor: <#T##UIColor#>,
//    titleFontSize: <#T##CGFloat#>,
//    cancelButtonBackgroundColor: <#T##UIColor#>,
//    confirmButtonBackgroundColor: <#T##UIColor#>,
//    cancelButtonTextColor: <#T##UIColor#>,
//    confirmButtonTextColor: <#T##UIColor#>,
//    cancelButtonText: <#T##String#>,
//    confirmButtonText: <#T##String#>,
//    cancelButtonFontSize: <#T##CGFloat#>,
//    confirmButtonFontSize: <#T##CGFloat#>,
//    rowHeight: <#T##CGFloat#>,
//    separatorColor: <#T##UIColor#>,
//    isCellBorder: <#T##Bool#>,
//    cellTextColor: <#T##UIColor#>,
//    cellBordeColor: <#T##UIColor#>,
//    deselectColor: <#T##UIColor#>,
//    selectColor: <#T##UIColor#>,
//    deselectImage: <#T##UIImage?#>,
//    selectImage: <#T##UIImage?#>,
//    selectionStyle: <#T##SelectionStyle#>
//)
