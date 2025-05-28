//
//  ReportPostVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ReportPostVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    
    @IBOutlet var btnReportOptions: [UIButton]!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var tvReport: FFTextView!

    var selectedOption = 0
    var module: String = ""
    var moduleId: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        for btn in btnReportOptions {
            btn.layer.borderWidth = 1.0
            btn.layer.cornerRadius = 5.0
            if btn.tag == selectedOption {
                btn.layer.borderColor = Colors.themeGreen.returnColor().cgColor
                btn.isSelected = true
            } else {
                btn.layer.borderColor = Colors.lightGray.returnColor().cgColor
                btn.isSelected = false
            }
        }
        
        lblTitle.text = "Report \(module)"
        lblSubTitle.text = "Select Why you are Reporting this \(module)?"
        
        self.tvReport.updateColor(Colors.lightGray.returnColor())
        
        self.tvReport.isHidden = true
        
    }
    
    func setupUI() {
        btnReport.layer.cornerRadius = btnReport.frame.size.height / 2
        
        viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapReportOptions(_ sender: UIButton) {
        self.view.endEditing(true)
        
        selectedOption = sender.tag
        for btn in btnReportOptions {
            if btn.tag == selectedOption {
                btn.layer.borderColor = Colors.themeGreen.returnColor().cgColor
                btn.isSelected = true
            } else {
                btn.layer.borderColor = Colors.lightGray.returnColor().cgColor
                btn.isSelected = false
            }
        }
        if selectedOption == 3 {
            self.tvReport.isHidden = false
            if tvReport.text == "" {
                btnReport.isUserInteractionEnabled = false
                btnReport.backgroundColor = Colors.inactiveButton.returnColor()
            }else {
                btnReport.isUserInteractionEnabled = true
                btnReport.backgroundColor = Colors.orange.returnColor()

            }
        } else {
            self.tvReport.isHidden = true
            btnReport.isUserInteractionEnabled = true
            btnReport.backgroundColor = Colors.orange.returnColor()

        }
        
    }
    
    @IBAction func onTapReport(_ sender: UIButton) {
        reportPost()
    }
    
    // MARK: - Webservices
    func reportPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.reportPost()
                }
            }
            return
        }
        
        var params = ["moduleId": moduleId, "module": module] as [String : Any]
        
        if selectedOption != 3 {
            params.updateValue((btnReportOptions[selectedOption].titleLabel?.text)!, forKey: "comment")
        } else {
            params.updateValue(tvReport.text!, forKey: "comment")
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REPORT_POST, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReportPostVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        tvReport.updateColor(Colors.themeGreen.returnColor())
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        
        if newString == "" {
            btnReport.isUserInteractionEnabled = false
            btnReport.backgroundColor = Colors.inactiveButton.returnColor()
        }else {
            btnReport.isUserInteractionEnabled = true
            btnReport.backgroundColor = Colors.orange.returnColor()
        }
        
        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmedString
        
        if textView.text == "" {
            tvReport.updateColor(Colors.lightGray.returnColor())
        } else {
            tvReport.updateColor(Colors.gray.returnColor())
        }

    }

    func textViewDidChange(_ textView: UITextView) {
//        placeholderTVLabel.isHidden = !textView.text.isEmpty
    }
}
