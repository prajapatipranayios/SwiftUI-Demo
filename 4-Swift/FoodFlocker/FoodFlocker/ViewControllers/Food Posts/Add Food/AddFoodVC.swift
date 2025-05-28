//
//  AddFoodVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel
import CropViewController

class AddFoodVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var btnAdd: UIButton!
    
//    @IBOutlet weak var tfQuantity: FFTextField!
//    @IBOutlet weak var lblQtyError: UILabel!

    @IBOutlet weak var lblCategoryTitle: UILabel!

    @IBOutlet weak var viewFoodTypeContainer: UIView!
    @IBOutlet var btnFoodTypes: [UIButton]!
    
    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!
    
    @IBOutlet weak var txtViewReceipe: FFTextView!

//    @IBOutlet weak var tfIngredients: FFTextField!
//    @IBOutlet weak var tfRealName: FFTextField!
//    @IBOutlet weak var tfCookName: FFTextField!

    @IBOutlet weak var viewCookImgContainer: UIView!
    @IBOutlet weak var ivCook: UIImageView!

//    @IBOutlet weak var tfTags: FFTextField!
//    @IBOutlet weak var lblTagsError: UILabel!

    
    @IBOutlet weak var tvCostingSheet: UITableView!
    @IBOutlet weak var heightTVCostingSheet: NSLayoutConstraint!

    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    var blurView: UIVisualEffectView!
    
    var selectedFoodType: Int = -1

    var costingSheet = [["name": "", "price": ""],
                        ["name": "", "price": ""]]
    
    let imagePicker =  UIImagePickerController()
    
    var addFoodItem: ((Dictionary<String, Any>)->Void)?

    var selectedCookImg: UIImage?
    var dictParamsImgUpload = Dictionary<String, Any>()
    var personBgImage: String = ""

    var foodDetailsToEdit: Dictionary<String, Any>?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.ivCook.layer.cornerRadius = self.ivCook.frame.height / 2
            self.ivCook.clipsToBounds = true
            
            self.setupUI()
            
            if self.foodDetailsToEdit != nil {
                if self.txtViewReceipe.text == "" {
                    self.txtViewReceipe.updateColor(Colors.lightGray.returnColor())
                } else {
                    self.txtViewReceipe.updateColor(Colors.gray.returnColor())
                }
                
                self.lblTitle.text = "Edit Food"
                self.btnAdd.setTitle("Update", for: .normal)
                self.textFields[0].text = self.foodDetailsToEdit!["quantity"] as? String
                if self.foodDetailsToEdit!["categoryId"] as? Int == 1 {
                    self.onTapFoodType(self.btnFoodTypes[0])
                } else {
                    self.onTapFoodType(self.btnFoodTypes[1])
                }
                self.txtViewReceipe.text = self.foodDetailsToEdit!["recipe"] as? String
                
                self.textFields[1].text = self.foodDetailsToEdit!["ingredients"] as? String
                self.textFields[2].text = self.foodDetailsToEdit!["realName"] as? String
                self.textFields[3].text = self.foodDetailsToEdit!["cookName"] as? String
                
                //Download image and set
                if self.foodDetailsToEdit!["backgroundImage"] as? String != "" {
                    self.ivCook.setImage(imageUrl: "\(BASE_IMG_URL)\(self.foodDetailsToEdit!["backgroundImage"] as! String)")
                }
                
                self.textFields[4].text = self.foodDetailsToEdit!["tags"] as? String
                
                self.costingSheet.removeAll()
                for i in 0..<(self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])!.count {
                    self.costingSheet.append(["name": (self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["name"] as! String, "price": (self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["price"]! as! String])
                }
                
                self.tvCostingSheet.reloadData()
                
                self.btnAdd.isUserInteractionEnabled = true
                self.btnAdd.backgroundColor = Colors.orange.returnColor()
            }else {
                self.lblTitle.text = "Add Food"
                self.btnAdd.setTitle("Add", for: .normal)
                
                self.txtViewReceipe.updateColor(Colors.lightGray.returnColor())
            }
        }
        
        self.dictParamsImgUpload.updateValue("FoodBackground", forKey: "module")

        tvCostingSheet.register(UINib(nibName: "AddCostSheetTVCell", bundle: nil), forCellReuseIdentifier: "AddCostSheetTVCell")
        tvCostingSheet.dataSource = self
        tvCostingSheet.delegate = self
        tvCostingSheet.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvCostingSheet.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvCostingSheet.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVCostingSheet.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    func setupUI() {
        lblCategoryTitle.setAttributedRequiredText()
        
        textFields[0].setAttributedPlaceholder(Colors.lightGray.returnColor())
        textFields[4].setAttributedPlaceholder(Colors.lightGray.returnColor())

        textFields[0].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textFields[4].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)


        self.btnAdd.layer.cornerRadius = self.btnAdd.frame.size.height / 2
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        viewFoodTypeContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewFoodTypeContainer.layer.borderWidth = 1.0
        viewFoodTypeContainer.layer.cornerRadius = viewFoodTypeContainer.frame.size.height / 2
        
        for btn in btnFoodTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        
        selectedFoodType = 1
        btnFoodTypes[0].isSelected = true
        btnFoodTypes[0].backgroundColor = Colors.themeGreen.returnColor()
        btnFoodTypes[0].setTitleColor(UIColor.white, for: .normal)
        btnFoodTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
        
        viewCookImgContainer.layer.cornerRadius = viewCookImgContainer.frame.size.height / 2
        viewCookImgContainer.layer.masksToBounds = false
        viewCookImgContainer.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        viewCookImgContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        viewCookImgContainer.layer.shadowOpacity = 0.7
        viewCookImgContainer.layer.shadowRadius = 5.0
        
        btnAdd.isUserInteractionEnabled = false
        btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textFields[4] == textField {
            if textFields[4].text!.count > 0 {
                if textFields[4].text?.count == 1 && textFields[4].text != "#" {
                        textFields[4].text = "#\(textFields[4].text ?? "")"
                    }else {
                        
                        if textFields[4].text!.last != " " && textFields[4].text!.last != "," && textFields[4].text?.count != 1 {
                            let lastChar = textFields[4].text!.last == nil ? "#" : String(textFields[4].text!).last
                            textFields[4].text! = String(textFields[4].text!.dropLast())
                            
                            if lastChar == "#" {
                                if textFields[4].text!.last == "," {
                                    textFields[4].text! += " \(String(lastChar!))"
                                }else if textFields[4].text!.last != " " && textFields[4].text!.last != "," {
                                    textFields[4].text! += ", \(String(lastChar!))"
                                }else {
                                    textFields[4].text! += "\(String(lastChar!))"
                                }
                            }else {
                                if textFields[4].text!.last == "," {
                                    if lastChar != "#" {
                                        let arrValue = textFields[4].text!.split(separator: "#")
                                        
                                        if arrValue.count > 6 {
                                            textFields[4].text! += "\(String(lastChar!))"
                                        }else {
                                            textFields[4].text! += " #\(String(lastChar!))"
                                        }
                                        
                                    }else {
                                        textFields[4].text! += " \(String(lastChar!))"
                                    }
                                }else if textFields[4].text!.last == " " {
                                    if lastChar != "#" {
                                        let arrValue = textFields[4].text!.split(separator: "#")
                                        
                                        if arrValue.count > 6 {
                                            textFields[4].text! += "\(String(lastChar!))"
                                        }else {
                                            textFields[4].text! += "#\(String(lastChar!))"
                                        }
                                    }
                                }else {
                                    textFields[4].text! += "\(String(lastChar!))"
                                }
                            }
                        }else {
                            let lastChar = textFields[4].text!.last == nil ? "#" : String(textFields[4].text!).last
                            textFields[4].text! = String(textFields[4].text!.dropLast())
                            
                            if lastChar == " " {
                                if textFields[4].text!.last != "," {
                                    textFields[4].text! += ",\(String(lastChar!))"
                                }else {
                                    if textFields[4].text!.last != "," {
                                        textFields[4].text! += ",\(String(lastChar!))"
                                    }else {
                                        textFields[4].text! += "\(String(lastChar!))"
                                    }
                                }
                            }else if lastChar == "," {
                                if textFields[4].text!.last != " " {
        //                            textFields[4].text! += ",\(String(lastChar!))"
                                }else {
                                    textFields[4].text! += "\(String(lastChar!))"
                                }
                            }else {
                                textFields[4].text! += "\(String(lastChar!))"
                            }
                        }
                    }
                }
            }
            
        
        var value = true
        
        if textFields[0].text?.trimmedString == "" || textFields[4].text?.trimmedString == "" {
            value = false
        }
        
        if value == true {
            btnAdd.backgroundColor = Colors.orange.returnColor()
            btnAdd.isUserInteractionEnabled = true
        } else {
            btnAdd.isUserInteractionEnabled = false
            btnAdd.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 || i == 4 {
                if textFields[i].text == "" {
                    lblError[i == 4 ? 1 : i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblError[i == 4 ? 1 : i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            } else if i < 4 {
                if textFields[i].text == "" {
                    viewBack[i].layer.borderColor = Colors.lightGray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.lightGray.returnColor())
                } else {
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                }
            }
        }
        return value
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            openGallary()
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func checkDiscardValue() -> Bool {
        var value = false
        
        if foodDetailsToEdit != nil {
            if selectedCookImg != nil || (self.textFields[0].text != self.foodDetailsToEdit!["quantity"] as? String) || (selectedFoodType != self.foodDetailsToEdit!["categoryId"] as? Int) || (self.txtViewReceipe.text != self.foodDetailsToEdit!["recipe"] as? String) || (self.textFields[1].text != self.foodDetailsToEdit!["ingredients"] as? String) || (self.textFields[2].text != self.foodDetailsToEdit!["realName"] as? String) || (self.textFields[3].text != self.foodDetailsToEdit!["cookName"] as? String) || (self.textFields[4].text != self.foodDetailsToEdit!["tags"] as? String) {
                value = true
            }
            
            if (self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])!.count == self.costingSheet.count {
                for i in 0..<(self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])!.count {
                    
                    if ((self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["name"] as! String != (self.costingSheet[i]["name"]!)) || ((self.foodDetailsToEdit!["costingSheet"] as? [[String: Any]])![i]["price"]! as! String != (self.costingSheet[i]["price"]! )) {
                        value = true
                        break
                    }
                }
            }else {
                value = true
            }
            
        }else {
             if selectedCookImg != nil || (self.textFields[0].text != "") || (selectedFoodType != 1) || (self.txtViewReceipe.text != "") || (self.textFields[1].text != "") || (self.textFields[2].text != "") || (self.textFields[3].text != "") || (self.textFields[4].text != "") {
                 value = true
            }
            
            for i in 0..<self.costingSheet.count {
                
                if ((self.costingSheet[i]["name"]!) != "") || ((self.costingSheet[i]["price"]!) != "") {
                    value = true
                    break
                }
            }
        }
        
        return value
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        if checkDiscardValue() {
            let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
            confirmPopup.titleString = "Are you sure to discard the changes?"
            confirmPopup.yesString = "Yes"
            confirmPopup.noString = "No"
            
            confirmPopup.tapYes = {
                self.navigationController?.popViewController(animated: true)
            }
            
            confirmPopup.tapNo = {
                
            }
            
            confirmPopup.modalPresentationStyle = .overCurrentContext
            confirmPopup.modalTransitionStyle = .crossDissolve
            
            self.present(confirmPopup, animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onTapFoodType(_ sender: UIButton) {
        selectedFoodType = sender.tag + 1
        for btn in btnFoodTypes {
            if btn.tag == sender.tag {
                btn.backgroundColor = Colors.themeGreen.returnColor()
                btn.setTitleColor(UIColor.white, for: .normal)
                btn.titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
                btn.isSelected = true
            } else {
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(Colors.lightGray.returnColor() , for: .normal)
                btn.titleLabel?.font = Fonts.Regular.returnFont(size: 14.0)
                btn.isSelected = false
            }
        }
    }
    
    @IBAction func updateCookImg(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if fpcOptions == nil {
            fpcOptions = FloatingPanelController()
            fpcOptions.delegate = self
            fpcOptions.surfaceView.cornerRadius = 20.0
            fpcOptions.isRemovalInteractionEnabled = true
            imagePicker.delegate = self
            
            blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
            blurEffect.setValue(2, forKeyPath: "blurRadius")
            blurView.effect = blurEffect
            blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.view.addSubview(blurView)
            blurView.isHidden = true
        }
        
        let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionVC") as? ChooseOptionVC
        chooseOptionVC?.openMediaPicker = { option in
            self.fpcOptions.removePanelFromParent(animated: false)
            self.blurView.isHidden = true

            if option == 0 {
                //"Take Photo/Video"
                self.openCamera()
            } else {
                //"Choose Photo/Video"
                self.openGallary()
            }
        }
        
        chooseOptionVC?.chooseProfile = true
        fpcOptions.set(contentViewController: chooseOptionVC)
        fpcOptions.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
    }
    
    @IBAction func addMoreTapped(_ sender: UIButton) {
        costingSheet.append(["name": "", "price": ""])
        tvCostingSheet.reloadData()
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let valid = checkValidation(to: 0, from: 4)
        if valid {
            //Add Food to Event and redirect back to Add Event Screen
            var dictFood = ["categoryId": selectedFoodType,
                            "quantity": textFields[0].text!,
                            "recipe": txtViewReceipe.text!,
                            "ingredients": textFields[1].text!,
                            "realName": textFields[2].text!,
                            "cookName": textFields[3].text!,
                            "tags": textFields[4].text!,
                            "backgroundImage": personBgImage
                            ] as [String : Any]
            
            var dictCostingSheet = Array<Dictionary<String, Any>>()
            for i in 0..<costingSheet.count {
                if costingSheet[i]["name"]! != "" {
                    dictCostingSheet.append(costingSheet[i])
                }
            }
            
            dictFood.updateValue(dictCostingSheet, forKey: "costingSheet")
            
            if addFoodItem != nil {
                addFoodItem!(dictFood)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // MARK: - Webservices
    
    func uploadPersonImage() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadPersonImage()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.UPLOAD_MEDIA, fileName: "media", image: selectedCookImg!, movieDataURL: nil, params: dictParamsImgUpload) { (status, response, message) in
            self.hideLoading()
            if status {
                if response != nil {
                    self.personBgImage = response!["fileName"] as! String
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
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

extension AddFoodVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costingSheet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddCostSheetTVCell") as! AddCostSheetTVCell
        
        cell.textFields[0].text = "\(costingSheet[indexPath.row]["name"]!)"
        cell.textFields[1].text = costingSheet[indexPath.row]["price"]! == "" ? "" : String(format: "%.2f", (costingSheet[indexPath.row]["price"]!).floatValue)
        
        cell.updateCostingSheet = { tfText, tfTag in
            var dict = self.costingSheet[indexPath.row]
            dict.updateValue(tfText, forKey: tfTag == 0 ? "name" : "price")
            self.costingSheet[indexPath.row] = dict
        }
        
        return cell
    }
    
}

extension AddFoodVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())

        if textField.tag == 0 {
            lblError[0].text = ""
        } else if textField.tag == 4 {
            lblError[1].text = ""
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 4 {
            let arrValue = textFields[4].text!.split(separator: "#")
            
            if arrValue.count > 6 {
                return false
            }
        }
        
        if textField.tag == 0 {
            return newString.length <= MAX_QUANTITY_LENGTH
        }else if textField.tag == 1 || textField.tag == 4 {
            return newString.length <= INGREDIANT_LIMIT
        }else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        switch textField.tag {
            case 0:
                txtViewReceipe.becomeFirstResponder()
                break
            case 1,2,3:
                textFields[textField.tag + 1].becomeFirstResponder()
                break
            default:
                view.endEditing(true)
                break
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        txtViewReceipe.updateColor(Colors.themeGreen.returnColor())
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        
        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmedString
        
        if textView.text == "" {
            txtViewReceipe.updateColor(Colors.lightGray.returnColor())
        } else {
            txtViewReceipe.updateColor(Colors.gray.returnColor())
        }
    }
}

extension AddFoodVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.ivCook.image = image
            self.selectedCookImg = image
            self.dictParamsImgUpload.updateValue("Image", forKey: "mediaType")
            self.uploadPersonImage()
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        
        dismiss(animated: true) {
            let cropViewController = CropViewController(image: image)
            cropViewController.toolbarPosition = .top
            cropViewController.resetButtonHidden = true
            cropViewController.rotateButtonsHidden = true
            cropViewController.aspectRatioPickerButtonHidden = true
            cropViewController.aspectRatioPreset = .presetSquare
            cropViewController.aspectRatioLockEnabled = true

            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddFoodVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}
