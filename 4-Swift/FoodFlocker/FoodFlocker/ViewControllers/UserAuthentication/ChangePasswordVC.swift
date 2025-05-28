//
//  ChangePasswordVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    
    @IBOutlet weak var btnUpdate: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        for tf in textFields {
            tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        for view in viewBack {
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 30.0
        }
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height / 2
        
        btnUpdate.isUserInteractionEnabled = false
        btnUpdate.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        var value = true
        for tf in textFields {
            if tf.text?.trimmedString == "" {
                value = false
                break
            }
        }
        
        if value == true {
            btnUpdate.backgroundColor = Colors.themeGreen.returnColor()
            btnUpdate.isUserInteractionEnabled = true
        }else {
            btnUpdate.isUserInteractionEnabled = false
            btnUpdate.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if textFields[i].text == "" {
                lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                value = false
                //
                viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                textFields[i].titleTextColour = Colors.red.returnColor()
                //
            }else {
                if (textFields[i].text?.count)! >= MIN_PASSWORD_LENGTH {
                    if i == 2 {
                        if textFields[1].text?.trimmedString != textFields[i].text?.trimmedString {
                            lblError[i].setLeftArrow(title: Confirm_Password_Not_Match)
                            value = false
                            //
                            viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                            textFields[i].titleTextColour = Colors.red.returnColor()
                            //
                        } else {
                            lblError[i].text = ""
                            //
                            viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                            textFields[i].titleTextColour = Colors.gray.returnColor()
                            //
                        }
                    } else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.gray.returnColor()
                        //
                    }
                }else {
                    lblError[i].setLeftArrow(title: Valid_Password)
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }
            }
        }
        return value
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapUpdate(_ sender: UIButton) {
        if checkValidation(to: 0, from: 2) {
            view.endEditing(true)
            changePassword()
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

    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        lblError[textField.tag].text = ""
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].title.textColor = Colors.themeGreen.returnColor()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= MAX_PASSWORD_LENGTH
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField.tag == 0 {
            textFields[1].becomeFirstResponder()
        } else if textField.tag == 1 {
            textFields[2].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if checkValidation(to: textField.tag, from: textField.tag + 1) {
        }
    }

    // MARK: Webservices
    
    func changePassword() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changePassword()
                }
            }
            return
        }
        
        let dictParms = ["oldPassword": (textFields[0].text?.trimmedString)!,
                        "newPassword": (textFields[1].text?.trimmedString)!,
                        "confirmPassword": (textFields[2].text?.trimmedString)!]

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_PASSWORD, parameters: dictParms) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
