//
//  ViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import UIKit

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
    
    @IBAction func btnDisplayMessageDialogTap(_ sender: UIButton) {
        /*let isSelectImageFromCamera = true
        
        CameraUtilitySingleImage.shared.showImagePicker(from: self, isSelectImageFromCamera: isSelectImageFromCamera) { image in
            self.ivImage.image = image
        }   //  */
        
        //self.openAction()
        videoPlayer.togglePictureInPicture()
    }
    
    @IBOutlet weak var ivImage: UIImageView!
    
    
    var arrStrItem: [Any] = []
    
    private var videoPlayer: CustomVideoPlayer!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ivImage.contentMode = .scaleAspectFit
        
        self.setupVideoPlayer()
        
        //videoPlayer.togglePictureInPicture()
        
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
        let videoURL = URL(string: "https://example.com/sample.mp4")!
        
        // Initialize video player with PiP disabled by default
        videoPlayer = CustomVideoPlayer(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 300))
        videoPlayer.setupPlayer(with: videoURL, enablePiP: true) // Pass `true` to enable PiP
        view.addSubview(videoPlayer)
        videoPlayer.play()
    }
}
