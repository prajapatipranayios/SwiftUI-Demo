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
        
        self.openAction()
    }
    
    @IBOutlet weak var ivImage: UIImageView!
    
    
    var arrStrItem: [Any] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ivImage.contentMode = .scaleAspectFit
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
        let actionSheet = CustomActionSheetViewController(items: ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6", "Option 7", "Option 8", "Option 9", "Option 10", "Option 11", "Option 12", "Option 13", "Option 14", "Option 15", "Option 16", "Option 17", "Option 18", "Option 19", "Option 20", "Option 21", "Option 22", "Option 23", "Option 24", "Option 25", "Option 26", "Option 27"], initialSelectedItems: self.arrStrItem, multipleSelection: true, shouldAnimate: false, isCellBorder: true, selectColor: .blue)
        //let actionSheet = CustomActionSheetViewController(items: ["Option 1", "Option 2", "Option 3"], initialSelectedItems: self.arrStrItem, multipleSelection: false, shouldAnimate: true, separatorColor: .systemBrown)
        actionSheet.onSelection = { selectedItems in
            print("Selected items: \(selectedItems)")
            self.arrStrItem = selectedItems
        }
        present(actionSheet, animated: true)
    }
}
