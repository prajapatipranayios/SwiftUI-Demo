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
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Function to configure and show the custom date picker
    private func setupDatePicker() {
        let calendarVC = CalendarViewController()
        
        // Customize the calendar settings
        calendarVC.selectionMode = .multiple  // Options: .single, .multiple, .range
        calendarVC.selectionColor = .green  // Custom selection color
        calendarVC.selectionShape = .roundedCSquare    // Options: .round, .square, .custom
        //calendarVC.monthsBefore = 2
        calendarVC.monthsAfter   = 2
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
    
    // Function to handle selected dates
    func handleDateSelection(dates: [String]) {
        print("Selected Dates: \(dates)")
        // No need to remove the date picker manually; it's done in CustomDatePickerView
    }
}

