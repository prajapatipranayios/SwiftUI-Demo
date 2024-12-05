//
//  ViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import UIKit
import DropDown


class Section {
    let title: String
    let option: [String]
    var isOpened: Bool = false
    
    init(title: String, option: [String], isOpened: Bool = false) {
        self.title = title
        self.option = option
        self.isOpened = isOpened
    }
}

class ViewController: UIViewController {
    
    @IBAction func btnShowToastTap(_ sender: UIButton) {
        //let toast = ToastMessage()
        //toast.showToast(message: "Success!", type: .success, inView: self.view)
        //toast.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.orange, textColor: UIColor.black, inView: self.view)
        //toast.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
        
        ToastMessage.shared.showToast(message: "Success!", type: .success, inView: self.view)
        ToastMessage.shared.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.yellow, textColor: UIColor.black, inView: self.view)
        ToastMessage.shared.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
    }
    
    @IBAction func btnDisplayConfirmationDialogTap(_ sender: UIButton) {
        CustomPopupView.shared.show(title: "Test Title...", message: "Message for test custom popup. Message for test custom popup. Message for test custom popup. ", dialogType: .textInputDialog) { strValue in
            print("Confirmed --> \(strValue ?? "")")
        } onCancel: { }
        
    }
    
    @IBAction func btnDisplayInputDialogTap(_ sender: UIButton) {
        self.setupDatePicker()
    }
    
    @IBOutlet weak var btnDisplayMessageDialog: UIButton!
    @IBAction func btnDisplayMessageDialogTap(_ sender: UIButton) {
        /*let isSelectImageFromCamera = true
        
        CameraUtilitySingleImage.shared.showImagePicker(from: self, isSelectImageFromCamera: isSelectImageFromCamera) { image in
            self.ivImage.image = image
        }   //  */
        
        //self.setupVideoPlayer()
        
        /*if !self.isOpen1 {
            self.isOpen1 = true
            // Create DropdownView
            dropdownView = CustomDropdownView(items: ["Select", "Sec", "Min"], parentView: view, textAlignment: .left)
            
            dropdownView.didSelectItem = { [weak self] selectedItem in
                //self?.customButton.setTitle(selectedItem, for: .normal)
                print("Selected item: \(selectedItem)")
            }
        }
        
        dropdownView.frame = self.btnDisplayMessageDialog.frame
        dropdownView.toggleDropdown()   /// */
        
        self.menu.show()
    }
    
    @IBOutlet weak var btnDropdownDialog: UIButton!
    @IBAction func btnDropdownDialogTap(_ sender: UIButton) {
        /*let isSelectImageFromCamera = true
            
        CameraUtilitySingleImage.shared.showImagePicker(from: self, isSelectImageFromCamera: isSelectImageFromCamera) { image in
            self.ivImage.image = image
        }   //  */
        
        //self.setupVideoPlayer()
        
        /*if !self.isOpen2 {
            self.isOpen2 = true
            // Create DropdownView
            //["Short", "Longer text that might wrap to a second line", "Extremely long text example that goes over multiple lines to test wrapping and sizing."]
            dropdownView = CustomDropdownView(items: ["Short", "Longer text that might wrap to a second line", "Extremely long text example that goes over multiple lines to test wrapping and sizing."], parentView: view, textAlignment: .left)
            
            dropdownView.didSelectItem = { [weak self] selectedItem in
                //self?.customButton.setTitle(selectedItem, for: .normal)
                print("Selected item: \(selectedItem)")
            }
        }
        
        dropdownView.frame = self.btnDropdownDialog.frame
        dropdownView.toggleDropdown()   ///  */
        
        
        self.menu.show()
    }
    
    @IBOutlet weak var ivImage: UIImageView!
    
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Item 1",
            "Item 2",
            "Item 3",
            "Item 4",
            "Item 5"
        ]
        return menu
    }()
    
    
    // MARK: - Outlet
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        }
    }
    
    private var sections = [Section]()
    
    
    
    
    
    // MARK: - Variable
    
    var arrStrItem: [Any] = []
    
    private var dropdownView: CustomDropdownView!
    
    var isOpen1: Bool = false
    var isOpen2: Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ivImage.contentMode = .scaleAspectFit
        
        
        // Setup models
        
        sections = [
            Section(title: "Section 1", option: [1, 2, 3].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 2", option: [4, 5, 6].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 3", option: [7, 8, 9].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 4", option: [10, 11, 12].compactMap({ return "Cell \($0)" }))
        ]
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //self.menu.anchorView = self.btnDisplayMessageDialog
        self.menu.anchorView = self.btnDropdownDialog
        
    }
    
    // Function to configure and show the custom date picker
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
    }
    
    func openAction() {
        let imgSelelct: UIImage = UIImage(named: "select") ?? UIImage(systemName: "circle")!
        let imgDeselelct: UIImage = UIImage(named: "deselect") ?? UIImage(systemName: "circle.inset.filled")!
        
        let actionSheet = CustomActionSheetVC(
            items: ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12", "Option 13", "Option 14", "Option 15", "Option 16", "Option 17", "Option 18", "Option 19", "Option 20", "Option 21", "Option 22", "Option 23", "Option 24", "Option 25", "Option 26", "Option 27"],
            initialSelectedItems: self.arrStrItem,
            multipleSelection: true,
            shouldAnimate: false,
            titleText: "Test Options",
            cancelButtonBackgroundColor: .white,
            confirmButtonBackgroundColor: .white,
            cancelButtonTextColor: .red,
            confirmButtonTextColor: .red,
            cancelButtonText: "Close",
            confirmButtonText: "Save",
            cancelButtonFontSize: 22,
            confirmButtonFontSize: 22,
            isCellBorder: true,
            deselectColor: .systemBlue,
            selectColor: .darkGray
            //deselectImage: imgDeselelct,
            //selectImage: imgSelelct
        )
        //let actionSheet = CustomActionSheetVC(items: ["Option 1", "Option 2", "Option 3"], initialSelectedItems: self.arrStrItem, multipleSelection: false, shouldAnimate: true, separatorColor: .systemBrown)
        actionSheet.onSelection = { selectedItems in
            print("Selected items: \(selectedItems)")
            self.arrStrItem = selectedItems
        }
        present(actionSheet, animated: true)
    }
    
    private func setupVideoPlayer() {
        // Create the video player view
        let videoPlayerView = VideoPlayerView(frame: CGRect(x: 20, y: 100, width: 300, height: 200))
        view.addSubview(videoPlayerView)
        
        // Load and play a video
        if let videoURL = URL(string: "https://www.example.com/sample.mp4") {
            videoPlayerView.loadVideo(with: videoURL)
            videoPlayerView.play()
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        
        if section.isOpened {
            return section.option.count + 1
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = sections[indexPath.section].title
            //return cell
        }
        else {
            cell.textLabel?.text = sections[indexPath.section].option[indexPath.row - 1]
        }
        return cell
        //return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            sections[indexPath.section].isOpened = !sections[indexPath.section].isOpened
            tableView.reloadSections([indexPath.section], with: .none)
        }
        else {
            print("Selected cell --> \(sections[indexPath.section].option[indexPath.row - 1])")
        }
    }
    
}
