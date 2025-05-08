//
//  ViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import UIKit
import DropDown
import AVKit


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
        //self.setupDatePicker()
        
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondScreenVC") as! SecondScreenVC
        self.navigationController?.pushViewController(navVC, animated: true)
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
        
        
        //self.menu.show()
        
        
        
        // Example Usage:
//        let usdFormatter = CurrencyFormatter(currencyCode: "USD", amount: 12345634.78)
//        let usdInfo = usdFormatter.formattedCurrency()
//
//        if let symbol = usdInfo.symbol, let unicode = usdInfo.unicode, let formattedAmount = usdInfo.formattedAmount {
//            print("USD:")
//            print("Symbol: \(symbol)")
//            print("Unicode (Code): \(unicode)")
//            print("Formatted Amount: \(formattedAmount)")
//        } else {
//            print("Could not format USD currency.")
//        }

//        let eurFormatter = CurrencyFormatter(currencyCode: "EUR", amount: 98734234.65)
//        let eurInfo = eurFormatter.formattedCurrency()
//
//        if let symbol = eurInfo.symbol, let unicode = eurInfo.unicode, let formattedAmount = eurInfo.formattedAmount {
//            print("\nEUR:")
//            print("Symbol: \(symbol)")
//            print("Unicode (Code): \(unicode)")
//            print("Formatted Amount: \(formattedAmount)")
//        } else {
//            print("Could not format EUR currency.")
//        }

//        if let details = CurrencyFormatter.formattedCurrency(for: .INR, amount: 1234567.89) {
//            print("Symbol: \(details.symbol)")
//            print("Unicode: \(details.unicode)")
//            print("Formatted Amount: \(details.formattedAmount)")
//        }
        
//        if let details = CurrencyFormatter.formattedCurrency(for: .USD, amount: 12345678.90) {
//            print("Symbol: \(details.symbol)")
//            print("Formatted Amount: \(details.formattedAmount)")
//        }

//        let jpyFormatter = CurrencyFormatter(currencyCode: "JPY", amount: 10000)
//        let jpyInfo = jpyFormatter.formattedCurrency()
//
//        if let symbol = jpyInfo.symbol, let unicode = jpyInfo.unicode, let formattedAmount = jpyInfo.formattedAmount {
//            print("\nJPY:")
//            print("Symbol: \(symbol)")
//            print("Unicode (Code): \(unicode)")
//            print("Formatted Amount: \(formattedAmount)")
//        } else {
//            print("Could not format JPY currency.")
//        }

//        let unknownFormatter = CurrencyFormatter(currencyCode: "XYZ", amount: 100)
//        let unknownInfo = unknownFormatter.formattedCurrency()
//
//        if let symbol = unknownInfo.symbol, let unicode = unknownInfo.unicode, let formattedAmount = unknownInfo.formattedAmount {
//            print("\nXYZ:")
//            print("Symbol: \(symbol)")
//            print("Unicode (Code): \(unicode)")
//            print("Formatted Amount: \(formattedAmount)")
//        } else {
//            print("Could not format XYZ currency.")
//        }

//        let a = ["1", "2", "3", "4", "5"]
//        let b = ["a", "b"]
//        
//        for i in 0..<a.count {
//            print(a[i])
//            if b.count > i {
//                print(b[i])
//            }
//        }
        
//        if sideMenuViewController.view.frame.origin.x < 0 {
//            // Show the side menu
//            UIView.animate(withDuration: 0.3) {
//                self.sideMenuViewController.view.frame.origin.x = 0
//            }
//        } else {
//            // Hide the side menu
//            UIView.animate(withDuration: 0.3) {
//                self.sideMenuViewController.view.frame.origin.x = -self.view.frame.width
//            }
//        }
        
        //SideMenuManager.shared.toggleMenu()
        //self.showMenu()
        
        if let videoURL = URL(string: "https://growy-lamda.s3.eu-west-2.amazonaws.com/post/post_18_16_49_59_345253.mp4") {
            playVideo(from: videoURL, on: self)
        }
        
    }
    
    func playVideo(from url: URL, on viewController: UIViewController) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        viewController.present(playerViewController, animated: true) {
            player.play()
        }
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
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var tableView: UITableView! {
//        didSet{
//            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//            //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        }
//    }
    
    private var sections = [Section]()
    
    //@IBOutlet weak var viewPlayer: VideoPlayerView!
    @IBOutlet weak var viewPlayer: CustomVideoPlayerView!
    
    
    // MARK: - Variable
    
    var arrStrItem: [Any] = []
    
    private var dropdownView: CustomDropdownView!
    
    var isOpen1: Bool = false
    var isOpen2: Bool = false
    
    
//    static var shared: ViewController?
//    var sideMenuViewController: SideMenuViewController!
    
    
    private let menuVC = SidemenuComponent()
    private var isLoggedIn = false // Update based on user status
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.ivImage.contentMode = .scaleAspectFit
        
        
        // Setup models
        
        sections = [
            Section(title: "Section 1", option: [1, 2, 3].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 2", option: [4, 5, 6].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 3", option: [7, 8, 9].compactMap({ return "Cell \($0)" })),
            Section(title: "Section 4", option: [10, 11, 12].compactMap({ return "Cell \($0)" }))
        ]
        
        self.navigationController?.isNavigationBarHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "SenderMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderMessageBubbleTVCell")
        
//        ViewController.shared = self
//        setupSideMenu()
        
//        // Load the side menu from the storyboard
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        sideMenuViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuViewController") as? SideMenuViewController
//        
//        // Add the side menu to the container
//        addChild(sideMenuViewController)
//        sideMenuViewController.view.frame = CGRect(x: -view.frame.width, y: 0, width: view.frame.width * 0.75, height: view.frame.height)
//        view.addSubview(sideMenuViewController.view)
//        sideMenuViewController.didMove(toParent: self)
           
//        // Add pan gesture recognizer
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        view.addGestureRecognizer(panGesture)
        
        menuVC.delegate = self
        menuVC.updateMenuItems(forUserLoggedIn: isLoggedIn)
        setupNavigationBar()
        
        
        // Add constraints
        NSLayoutConstraint.activate([
            viewPlayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // height is handled internally
        ])
        
        if let url = URL(string: "https://www.w3schools.com/html/mov_bbb.mp4") {
        //if let url = URL(string: "https://growy-lamda.s3.eu-west-2.amazonaws.com/post/post_18_16_49_59_345253.mp4") {
            self.viewPlayer.playVideo(with: url)
        }
    }
    
    private func setupNavigationBar() {
        let menuButton = UIBarButtonItem(title: "☰", style: .plain, target: self, action: #selector(showMenu))
        navigationItem.leftBarButtonItem = menuButton
    }
    
    @objc func showMenu() {
        menuVC.delegate = self  // Ensure delegate is set before showing menu
        menuVC.showMenu(from: self)
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
    
//    private func setupVideoPlayer() {
//        // Create the video player view
//        let videoPlayerView = VideoPlayerView(frame: CGRect(x: 20, y: 100, width: 300, height: 200))
//        view.addSubview(videoPlayerView)
//        
//        // Load and play a video
//        if let videoURL = URL(string: "https://www.example.com/sample.mp4") {
//            //videoPlayerView.loadVideo(with: videoURL)
//            //videoPlayerView.play()
//        }
//    }
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
            //cell.textLabel?.text = sections[indexPath.section].option[indexPath.row - 1]
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "SenderMessageBubbleTVCell", for: indexPath) as! SenderMessageBubbleTVCell
            
            if indexPath.row % 2 == 0 {
                cell1.constraintTopViewMsgToSuper.priority = .required
                cell1.viewDateSection.isHidden = true
                cell1.lblEdited.text = ""
            }
            else {
                cell1.constraintTopViewMsgToSuper.priority = .defaultLow
                cell1.viewDateSection.isHidden = false
                cell1.lblMsg.text = "f sdf fdsf g"
                cell1.lblEdited.text = "Edited"
            }
            
            return cell1
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

extension ViewController: SideMenuDelegate {
    
    func didSelectMenuItem(named: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootNav = window.rootViewController as? UINavigationController else {
            print("❌ Navigation Controller not found!")
            return
        }
        
        // Choose the correct view controller to navigate
        var viewController: UIViewController?
        
        switch named {
        case "Dashboard":
            viewController = SecondScreenVC()
        case "Profile":
            viewController = ThirdScreenVC()
        case "Settings":
            viewController = ForthScreenVC()
        case "Logout":
            self.isLoggedIn = false
            self.menuVC.updateMenuItems(forUserLoggedIn: self.isLoggedIn)
        case "Login":
            self.isLoggedIn = true
            self.menuVC.updateMenuItems(forUserLoggedIn: self.isLoggedIn)
            viewController = SecondScreenVC()
        case "About":
            viewController = ThirdScreenVC()
        case "Help":
            viewController = ForthScreenVC()
        default:
            break
        }
        
        // Navigate only if a valid ViewController is found
        if let vc = viewController {
            rootNav.popToRootViewController(animated: false) // Ensure we start navigation from root
            rootNav.pushViewController(vc, animated: true) // Navigate to selected screen
        }
        
        //dismissMenu() // Close the side menu
    }
}
