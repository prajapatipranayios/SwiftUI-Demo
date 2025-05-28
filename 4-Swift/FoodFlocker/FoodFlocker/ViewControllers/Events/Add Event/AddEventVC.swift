//
//  AddEventVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CropViewController
import FloatingPanel
import AVFoundation

class AddEventVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var btnCreate: UIButton!
    
    @IBOutlet weak var lblMediaTitle: UILabel!
    @IBOutlet weak var cvMedias: UICollectionView!

    @IBOutlet var viewBack: [UIView]!
    @IBOutlet var textFields: [FFTextField]!
    @IBOutlet var lblError : [UILabel]!

    @IBOutlet weak var tvEventDesc: FFTextView!
    @IBOutlet weak var lblEventError: UILabel!
    
    @IBOutlet weak var lblAddFood: UILabel!

    @IBOutlet weak var tvFoodItems: UITableView!
    @IBOutlet weak var heightTVFoodItems: NSLayoutConstraint!
    
    @IBOutlet weak var btnLimitedTicket: UIButton!
    @IBOutlet weak var heightTFTicket: NSLayoutConstraint!

    
    var eventDetails: PostEventDetail?

    var tmpTextField = FFTextField()

    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    let imagePicker =  UIImagePickerController()
    
    var selectedImgs = [Any]()
    
    var dictParams = Dictionary<String, Any>()
    var foodDetails = Array<Dictionary<String, Any>>()
    var uploadedMedias = Array<Dictionary<String, String>>()

    var selectedAddress: GoogleAddress?
    
    var imgToUpload: UIImage?
    var dictParamsUpload = Dictionary<String, Any>()
    
    var dictParamsGetEvent = Dictionary<String, Any>()
    var eventId: Int = -1

    var isComeForUpdate = false
    var isComeForDuplicate = false

//    var videoPathToUplo-ad: URL?
    var ontapUpdate: (()->Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        layoutCells()
        DispatchQueue.main.async {
            self.setupUI()
        }
        self.dictParamsUpload.updateValue("Event", forKey: "module")
        tvFoodItems.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        imagePicker.mediaTypes = ["public.image", "public.movie"]

        checkButtonShowValue()
        
        if self.isComeForUpdate {
            lblTitle.text = "Update an event"
            btnCreate.setTitle("Update", for: .normal)
        }else {
            lblTitle.text = "Create an event"
            btnCreate.setTitle("Create", for: .normal)
        }
        
        
        
        if self.isComeForUpdate || self.isComeForDuplicate {
            self.tvEventDesc.text = self.eventDetails?.description
            dictParamsGetEvent.updateValue("Event", forKey: "module")
            dictParamsGetEvent.updateValue(eventId, forKey: "moduleId")
            getEventDetails()
        }
        
//        let datePicker = UIDatePicker()
//        datePicker.datePickerMode = .time
//        datePicker.locale = .current
//        if #available(iOS 14, *) {
//            datePicker.preferredDatePickerStyle = .wheels
//            datePicker.sizeToFit()
//            }
//        textFields[1].inputView = datePicker
//        textFields[2].inputView = datePicker
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        tvFoodItems.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVFoodItems.constant = newsize.height
                self.updateViewConstraints()
                
                if newsize.height > 0 {
                    self.lblAddFood.text = "Food :"
                }
            }
        }
    }
    
    // MARK: - UI Methods
    func setUpdateDuplicateData() {
        
//        if isComeForUpdate {
//            btnLimitedTicket.isUserInteractionEnabled = true
//            textFields[4].isUserInteractionEnabled = true
//        }
        
        textFields[0].text = eventDetails?.title
        
        DispatchQueue.main.async {
            self.tvEventDesc.text = self.eventDetails?.description
        }
        
        if self.isComeForDuplicate {
            textFields[1].text = ""
            textFields[2].text = ""
        }else {
            textFields[1].text = Utilities.convertDateFormater(eventDetails!.startDate!)
            textFields[2].text = Utilities.convertDateFormater(eventDetails!.endDate!)
        }
        
        self.selectedAddress = GoogleAddress(type: "Google", drop_title: "", drop_location: eventDetails?.address ?? "", drop_latitude: eventDetails?.latitude ?? 0.0, drop_longitude: eventDetails?.longitude ?? 0.0)
        
        textFields[3].text = eventDetails?.address
        
        for i in 0..<textFields.count {
            if self.isComeForDuplicate {
                if i == 1 || i == 2 {
                    
                }
                viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                textFields[i].setAttributedTitle(Colors.gray.returnColor())
            }else {
                viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                textFields[i].setAttributedTitle(Colors.gray.returnColor())
            }
            
        }
        
        if ((eventDetails?.isLimitedTicket) != nil) && (eventDetails?.isLimitedTicket)! == 1 {
            
            btnLimitedTicket.isUserInteractionEnabled = false
            textFields[4].isUserInteractionEnabled = false
            
            btnLimitedTicket.isSelected = false
            textFields[4].text = "\(eventDetails?.totalAvailbleTicket ?? 0)"
            onTapLimitedTicket(btnLimitedTicket)
        } else {
            btnLimitedTicket.isUserInteractionEnabled = true
            textFields[4].isUserInteractionEnabled = true
            
            btnLimitedTicket.isSelected = false
            textFields[4].text = ""
            heightTFTicket.constant = 0
            textFields[4].title.isHidden = btnLimitedTicket.isSelected ? false : true
            lblError[4].isHidden = btnLimitedTicket.isSelected ? false : true

            lblError[4].text = ""
        }
        
        dictParams = ["title": textFields[0].text!,
                      "description": tvEventDesc.text!,
                      "startDate": textFields[1].text!,
                      "endDate": textFields[2].text!,
                      "totalAvailbleTicket": textFields[4].text! == "" ? "0" : textFields[4].text!,
                      "address": (selectedAddress?.drop_location)!,
                      "latitude": (selectedAddress?.drop_latitude)!,
                      "longitude": (selectedAddress?.drop_longitude)!]
        
        for i in 0..<(eventDetails?.foodDetails!.count)! {
            var dictFood = ["categoryId": eventDetails?.foodDetails![i].categoryId ?? 0,
                            "foodName": eventDetails?.foodDetails![i].foodName ?? "",
                            "quantity": eventDetails?.foodDetails![i].quantity ?? "",
                            "tags": eventDetails?.foodDetails![i].tags ?? "",
                            "ingredients": eventDetails?.foodDetails![i].ingredients ?? ""] as [String : Any]
            
            var dictCostingSheet = Array<Dictionary<String, Any>>()
            for x in 0..<(eventDetails?.foodDetails![i].costingSheet?.count)! {
                if eventDetails?.foodDetails![i].costingSheet?[x].name != "" {
                    dictCostingSheet.append(["name": eventDetails?.foodDetails![i].costingSheet?[x].name ?? "", "price": "\(eventDetails?.foodDetails![i].costingSheet?[x].price ?? 0.0)"])
                }
            }
            
            dictFood.updateValue(dictCostingSheet, forKey: "costingSheet")
            
            self.foodDetails.append(dictFood)
        }
        
        tvFoodItems.reloadData()
        
        if (eventDetails?.medias?.count)! > 0 {
            for media in eventDetails!.medias! {
                let subStr = media.mediaType == "Video" ? media.videoUrl!.split(separator: "/") : media.mediaImage!.split(separator: "/")
                let dict = ["mediaName": String(subStr[subStr.count - 1]), "mediaType": media.mediaType]
                self.uploadedMedias.append(dict)
                self.selectedImgs.append(media.mediaImage!)
            }
        }
        
        cvMedias.reloadData()
        
        self.checkButtonShowValue()
        
    }
    
    func setupUI() {
        lblMediaTitle.setAttributedRequiredText()
        
        tvEventDesc.setAttributedPlaceholder(Colors.lightGray.returnColor())
        
        self.btnCreate.layer.cornerRadius = self.btnCreate.frame.size.height / 2
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
        
        for i in 0..<textFields.count {
            textFields[i].addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            textFields[i].setAttributedPlaceholder(Colors.lightGray.returnColor())
//            if i != textFields.count - 1 {
//            }
        }


        btnLimitedTicket.isSelected = false
        heightTFTicket.constant = 0.0
        
        heightTVFoodItems.constant = 0

        
        btnCreate.isUserInteractionEnabled = false
        btnCreate.backgroundColor = Colors.inactiveButton.returnColor()
    }
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvMedias.frame.size.height, height: cvMedias.frame.size.height)
        layout.scrollDirection = .horizontal
        self.cvMedias.setCollectionViewLayout(layout, animated: true)
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
    
    //Open Image Picker
    
    func openImagePicker() {
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
        
        chooseOptionVC?.chooseMedia = true
        fpcOptions.set(contentViewController: chooseOptionVC)
        fpcOptions.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
        
    }

    // MARK: - UI Methods
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        checkButtonShowValue()
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i != 4 && i != 5 {
                if textFields[i].text == "" {
                    lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    textFields[i].titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            } else if i == 5 {
                if tvEventDesc.text == "" {
                    lblEventError.getEmptyValidationString(tvEventDesc.hint)
                    value = false
                    //
                    tvEventDesc.titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    lblEventError.text = ""
                    //
                    tvEventDesc.setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            } else {
                if btnLimitedTicket.isSelected {
                    if textFields[i].text == "" {
                        lblError[i].getEmptyValidationString(textFields[i].placeholder ?? "")
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        textFields[i].titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblError[i].text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        textFields[i].setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }else {
                    lblError[i].text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    textFields[i].setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            }
        }
        
        return value
    }
    
    func checkButtonShowValue() {
        var value = true
        
        for i in 0..<textFields.count {
            
            if i != 4 {
                if textFields[i].text?.trimmedString == "" {
                    value = false
                }
            }
        }
        
        if btnLimitedTicket.isSelected {
            if textFields[4].text?.trimmedString == "" {
                value = false
            }
        }
        
        if tvEventDesc.text == "" {
            value = false
        }
        
        if selectedImgs.count == 0 {
            value = false
        }
        
//        if foodDetails.count < 1 {
//            value = false
//        }
        
        if value == true {
            btnCreate.backgroundColor = Colors.orange.returnColor()
            btnCreate.isUserInteractionEnabled = true
        } else {
            btnCreate.isUserInteractionEnabled = false
            btnCreate.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func checkDiscardValue() -> Bool {
        var value = false
        
        
        if ((eventDetails?.isLimitedTicket) != nil) && (eventDetails?.isLimitedTicket)! == 1 {
            btnLimitedTicket.isSelected = false
            textFields[4].text = "\(eventDetails?.totalAvailbleTicket ?? 0)"
            onTapLimitedTicket(btnLimitedTicket)
        } else {
            btnLimitedTicket.isSelected = false
            textFields[4].text = "\(eventDetails?.totalAvailbleTicket ?? 0)"
            heightTFTicket.constant = 0
        }
        
        if self.isComeForUpdate {
            if selectedImgs.count > (eventDetails?.medias?.count)! || (textFields[0].text != eventDetails?.title) || (tvEventDesc.text != eventDetails?.description) || (textFields[1].text != Utilities.convertDateFormater(eventDetails!.startDate!)) || (textFields[2].text != Utilities.convertDateFormater(eventDetails!.endDate!)) || (textFields[3].text != eventDetails?.address) || (eventDetails?.isLimitedTicket)! == 1 ? true : false != btnLimitedTicket.isSelected {
                value = true
            }else {
                if btnLimitedTicket.isSelected {
                    if textFields[4].text != "\(eventDetails?.totalAvailbleTicket ?? 0)" {
                        value = true
                    }
                }
            }
        }else if self.isComeForDuplicate {
            if selectedImgs.count > (eventDetails?.medias?.count)! || (textFields[0].text != eventDetails?.title) || (tvEventDesc.text != eventDetails?.description) || (textFields[1].text != "") || (textFields[2].text != "") || (textFields[3].text != eventDetails?.address) || (eventDetails?.isLimitedTicket)! == 1 ? true : false != btnLimitedTicket.isSelected {
                value = true
            }else {
                if btnLimitedTicket.isSelected {
                    if textFields[4].text != "\(eventDetails?.totalAvailbleTicket ?? 0)" {
                        value = true
                    }
                }
            }
        }else {
            if selectedImgs.count > 0 || (textFields[0].text != "") || (tvEventDesc.text != "") || (textFields[1].text != "") || (textFields[2].text != "") || (textFields[3].text != "") || btnLimitedTicket.isSelected != false {
                value = true
            }else {
                if btnLimitedTicket.isSelected {
                    if textFields[4].text != "" {
                        value = true
                    }
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
                self.tvFoodItems.removeObserver(self, forKeyPath: "contentSize")
                self.navigationController?.popViewController(animated: true)
            }
            confirmPopup.tapNo = {
                
            }
            confirmPopup.modalPresentationStyle = .overCurrentContext
            confirmPopup.modalTransitionStyle = .crossDissolve
            
            self.present(confirmPopup, animated: true, completion: nil)
        }else {
            tvFoodItems.removeObserver(self, forKeyPath: "contentSize")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onTapCreate(_ sender: UIButton) {
        view.endEditing(true)
        let valid = checkValidation(to: 0, from: 4)
        
        if valid {
            if selectedImgs.count > 0 {
                
//                if foodDetails.count > 0 {
                    
                    //Call an API
                dictParams = ["title": textFields[0].text!,
                              "description": tvEventDesc.text!,
                              "startDate": textFields[1].text!,
                              "endDate": textFields[2].text!,
                              "totalAvailbleTicket": textFields[4].text! == "" ? "0" : textFields[4].text!,
                              "address": (selectedAddress?.drop_location)!,
                              "latitude": (selectedAddress?.drop_latitude)!,
                              "longitude": (selectedAddress?.drop_longitude)!]
                
                if self.isComeForUpdate {
                    dictParams.updateValue(eventId, forKey: "eventId")
                }
                
                //categoryId: 1-AllVeg, 2-AllNonVeg, 3-Both,
                dictParams.updateValue(btnLimitedTicket.isSelected ? 1 : 0, forKey: "isLimitedTicket")
                dictParams.updateValue(textFields[4].text! == "" ? 0 : (textFields[4].text!), forKey: "totalAvailbleTicket")
                
                dictParams.updateValue(uploadedMedias, forKey: "uploadedMedias")
                
                if (foodDetails.count > 0) {
                    dictParams.updateValue(foodDetails, forKey: "foodDetails")
                    var categoryIds = [Int]()
                    for i in 0..<foodDetails.count {
                        
                        if !categoryIds.contains((foodDetails[i]["categoryId"] as? Int)!) {
                            categoryIds.append((foodDetails[i]["categoryId"] as? Int)!)
                        }
                    }
                    
                    if categoryIds.count > 1 {
                        dictParams.updateValue(3, forKey: "categoryId")
                    }else {
                        dictParams.updateValue(categoryIds[0], forKey: "categoryId")
                    }
                    
                }
                
                let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
                confirmPopup.titleString = isComeForUpdate ? "The event update will go live." : "The event will go live."
                confirmPopup.yesString = isComeForUpdate ? "Update" : "Create"
                confirmPopup.noString = "Cancel"
                confirmPopup.tapYes = {
                    
                    if (self.foodDetails.count > 0) {
                        self.addEvent()
                    }else {
                        let selectCategoryPopup = self.storyboard?.instantiateViewController(withIdentifier: "SelectCategoryPopupVC") as! SelectCategoryPopupVC
                        selectCategoryPopup.tapYes = { categoryId in
                            self.dictParams.updateValue(categoryId, forKey: "categoryId")
                            self.addEvent()
                        }
                        selectCategoryPopup.modalPresentationStyle = .overCurrentContext
                        selectCategoryPopup.modalTransitionStyle = .crossDissolve
                        
                        self.present(selectCategoryPopup, animated: true, completion: nil)
                    }
                }
                confirmPopup.tapNo = {
                    
                }
                confirmPopup.modalPresentationStyle = .overCurrentContext
                confirmPopup.modalTransitionStyle = .crossDissolve
                
                self.present(confirmPopup, animated: true, completion: nil)
                    
//                } else {
//                    Utilities.showPopup(title: "Add food details to create an event", type: .error)
//                }
            } else {
                Utilities.showPopup(title: "Select medias to upload", type: .error)
            }
        }
    }
    
    @IBAction func onTapLimitedTicket(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        heightTFTicket.constant = sender.isSelected ? 40 : 0
        textFields[4].title.isHidden = sender.isSelected ? false : true
        lblError[4].isHidden = sender.isSelected ? false : true
        
        lblError[4].text = ""
        
        if textFields[4].text == "" {
            viewBack[4].layer.borderColor = Colors.lightGray.returnColor().cgColor
            textFields[4].setAttributedTitle(Colors.lightGray.returnColor())
        }
        
        
        dictParams.updateValue(sender.isSelected ? 1 : 0, forKey: "isExpiringSoon")
        
        checkButtonShowValue()
        
    }
    
    @IBAction func onTapAddFood(_ sender: UIButton) {
        let addFoodVC = self.storyboard?.instantiateViewController(withIdentifier: "AddFoodForEventVC") as! AddFoodForEventVC
        addFoodVC.modalPresentationStyle = .fullScreen
        addFoodVC.addFoodItem = { dictFood in
            self.foodDetails.append(dictFood)
            DispatchQueue.main.async {
                self.tvFoodItems.reloadData()
                self.checkButtonShowValue()
            }
        }
        
        self.navigationController?.pushViewController(addFoodVC, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Webservices
    func uploadImageOrVideo() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadImageOrVideo()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.UPLOAD_MEDIA, fileName: "media", image: imgToUpload!, movieDataURL: nil, params: dictParamsUpload) { (status, response, message) in
            self.hideLoading()
            if status {
                if response != nil {
                    let dict = ["mediaName": response!["fileName"] as! String,"mediaType": "image"]
                    self.uploadedMedias.append(dict)
                    DispatchQueue.main.async {
                        self.cvMedias.reloadData()
                    }
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
    
    func getEventDetails() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getEventDetails()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_POST_EVENT_DETAILS, parameters: dictParamsGetEvent) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.eventDetails = (response?.result?.eventDetail)!
                DispatchQueue.main.async {
                    self.setUpdateDuplicateData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func addEvent() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addEvent()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: isComeForUpdate ? APIManager.sharedManager.UPDATE_EVENT : APIManager.sharedManager.ADD_EVENT, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupVC") as! SuccessPopupVC
                    successPopup.titleString = self.isComeForUpdate ? "Your event has been successfully updated." : "Your event has been successfully created."
                    successPopup.tapDone = {
                        if self.isComeForUpdate || self.isComeForDuplicate {
                            if self.ontapUpdate != nil {
                                self.ontapUpdate!()
                            }
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    successPopup.modalPresentationStyle = .overCurrentContext
                    successPopup.modalTransitionStyle = .crossDissolve
                    
                    self.present(successPopup, animated: true, completion: nil)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension AddEventVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag != 4 {
            lblError[textField.tag].text = ""
        }
        
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor
        textFields[textField.tag].setAttributedTitle(Colors.themeGreen.returnColor())
        if textField.tag == 1 || textField.tag == 2 {
            tmpTextField.resignFirstResponder()
            textField.endEditing(true)
            
            if textField.tag == 2 && self.textFields[1].text! == "" {
                self.lblError[textField.tag].text = "Please select start date first"
                self.viewBack[textField.tag].layer.borderColor = Colors.red.returnColor().cgColor
                self.textFields[textField.tag].titleTextColour = Colors.red.returnColor()
            }else {
//                textField.resignFirstResponder()
                let str = textField.tag == 1 ? "Start" : "End"
                Utilities.displayActionSheetDatePicker(title: "Select \(str) Date & Time", doneBlock: { (picker, selectedDate, origin) in
                    var date = Date()
                    
                    let df = DateFormatter()
                    df.dateFormat = "yyyy-MM-dd hh:mm"
                    
                    if textField.tag == 2 {
                        date = df.date(from: self.textFields[1].text!)!
                    }
                    
                    if (date < selectedDate as! Date && textField.tag == 1) || ( date < selectedDate as! Date && textField.tag == 2) {
                        textField.text = df.string(from: selectedDate as! Date)
                        textField.endEditing(true)
                        self.lblError[textField.tag].text = ""
                        self.viewBack[textField.tag].layer.borderColor = Colors.gray.returnColor().cgColor
                        self.textFields[textField.tag].titleTextColour = Colors.gray.returnColor()
                    }else {
                        self.lblError[textField.tag].getValidationString(self.textFields[textField.tag].placeholder ?? "")
                        self.viewBack[textField.tag].layer.borderColor = Colors.red.returnColor().cgColor
                        self.textFields[textField.tag].titleTextColour = Colors.red.returnColor()
                    }
                    
                }, cancelBlock: { (ActionDateCancelBlock) in
                    textField.text = ""
                    self.lblError[textField.tag].getEmptyValidationString(self.textFields[textField.tag].placeholder ?? "")
                    self.viewBack[textField.tag].layer.borderColor = Colors.red.returnColor().cgColor
                    self.textFields[textField.tag].titleTextColour = Colors.red.returnColor()
                    
                    textField.endEditing(true)
                }, origin: textField)
            }
            
        } else if textField.tag == 3 {
            tmpTextField.resignFirstResponder()
            textField.endEditing(true)
            let selectAddressVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectAddressVC") as! SelectAddressVC
            selectAddressVC.modalPresentationStyle = .fullScreen
            selectAddressVC.getSelectedAddress = { selectedAddress in
                self.selectedAddress = selectedAddress
                self.textFields[textField.tag].text = selectedAddress.drop_location
                self.textFieldDidEndEditing(self.textFields[textField.tag])
            }
            self.present(selectAddressVC, animated: true, completion: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        return newString.length <= TEXTFIELD_LIMIT
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tmpTextField = textField as! FFTextField

        if textField.tag != 1 && textField.tag != 2 {
            textField.text = textField.text?.trimmedString
            if self.checkValidation(to: textField.tag, from: textField.tag+1) {
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        if textField == textFields[0] {
            textFields[1].becomeFirstResponder()
        } else if textField == textFields[1] {
            textFields[2].becomeFirstResponder()
        } else if textField == textFields[2] {
            textFields[3].becomeFirstResponder()
        } else if textField == textFields[3] {
            tvEventDesc.becomeFirstResponder()
//            textFields[4].becomeFirstResponder()
        } else if textField == textFields[4] {
            view.endEditing(true)
        } else {
            view.endEditing(true)
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tvEventDesc.updateColor(Colors.themeGreen.returnColor())
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString

        
        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmedString
        
        if self.checkValidation(to: textView.tag, from: textView.tag+1) {}
        checkButtonShowValue()
    }
    
}

extension AddEventVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedImgs.count >= 10 {
            return selectedImgs.count
        }
        
        return selectedImgs.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMediaCVCell", for: indexPath) as! AddMediaCVCell
        
//        cell.ivMedia.layer.cornerRadius = 10.0
 //       cell.ivMedia.clipsToBounds = true

        if indexPath.item == selectedImgs.count {
            cell.viewContainer.layer.borderColor = Colors.lightGray.returnColor().cgColor
            cell.viewContainer.layer.borderWidth = 1.0
            cell.ivMedia.image = UIImage(named: "Plus")
            cell.ivMedia.contentMode = .center
            
            cell.viewContainer.layer.shadowColor = UIColor.clear.cgColor
            cell.btnVideoIndicator.isHidden = true
            
        } else {
            cell.ivMedia.contentMode = .scaleAspectFill
            
            if selectedImgs[indexPath.item] is String {
                cell.ivMedia.contentMode = .scaleAspectFill
                
                cell.ivMedia.setImage(imageUrl: (eventDetails?.medias![indexPath.item].mediaImage)!)
                if uploadedMedias[indexPath.item]["mediaType"] == "Image" {
                    cell.btnVideoIndicator.isHidden = true
                } else {
                    //Set Video Thumbnail
                    cell.btnVideoIndicator.isHidden = false
                }
            }else if selectedImgs[indexPath.item] is UIImage {
                cell.ivMedia.image = selectedImgs[indexPath.item] as? UIImage
                cell.btnVideoIndicator.isHidden = true
            } else {
                cell.btnVideoIndicator.isHidden = false
                cell.ivMedia.image = Utilities.generateThumbnail(for: AVAsset(url: selectedImgs[indexPath.item] as! URL))
            }

            cell.viewContainer.layer.masksToBounds = false
            cell.viewContainer.layer.shadowColor = Colors.gray.returnColor().cgColor
            cell.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
            cell.viewContainer.layer.shadowOpacity = 0.7
            cell.viewContainer.layer.shadowRadius = 2.0
            
            cell.viewContainer.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedImgs.count >= 10 {
            return
        }
        
        if indexPath.item == selectedImgs.count {
            openImagePicker()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
//    }
    
}

extension AddEventVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.imgToUpload = image
            self.selectedImgs.append(image)
            self.cvMedias.reloadData()
//            self.textFieldDidChange(textField: self.textFields)
            self.dictParamsUpload.updateValue("Image", forKey: "mediaType")
            self.uploadImageOrVideo()
            
            self.checkButtonShowValue()
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
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
        } else if let videoUrl = info[.mediaURL] as? URL {
//            self.videoPathToUpload = videoUrl
            self.dictParamsUpload.updateValue("Video", forKey: "mediaType")
            dismiss(animated: true) {
                DispatchQueue.main.async {
    //                    self.uploadImageOrVideo() - Jaimesh
                    let videoCropVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCropVC") as! VideoCropVC
                    videoCropVc.modalPresentationStyle = .fullScreen
                    videoCropVc.selectedUrl = videoUrl//self.videoPathToUpload
                    videoCropVc.dictParamsVideoUpload = self.dictParamsUpload
                    videoCropVc.module = "Event"
                    videoCropVc.updateVideoParams = { params in
                        self.uploadedMedias.append(params)
                        self.selectedImgs.append(videoUrl)
                        self.cvMedias.reloadData()
                    }
                    self.present(videoCropVc, animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated:true, completion: nil)
            return
        }
        
        
//        guard let image = info[.originalImage] as? UIImage else {
//            dismiss(animated:true, completion: nil)
//            return
//        }
//
//        dismiss(animated: true) {
//            let cropViewController = CropViewController(image: image)
//            cropViewController.toolbarPosition = .top
//            cropViewController.resetButtonHidden = true
//            cropViewController.rotateButtonsHidden = true
//            cropViewController.aspectRatioPickerButtonHidden = true
//            cropViewController.aspectRatioPreset = .presetSquare
//            cropViewController.aspectRatioLockEnabled = true
//
//            cropViewController.delegate = self
//            self.present(cropViewController, animated: true, completion: nil)
//        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddEventVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventFoodTVCell", for: indexPath) as! EventFoodTVCell
        
        let foodDetail = foodDetails[indexPath.row]
        cell.btnEdit.tag = indexPath.row
        cell.lblFoodItem.text = "\(indexPath.row + 1)) \(foodDetail["foodName"]!)"
        cell.btnEdit.addTarget(self, action: #selector(editFoodItem(btn:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func editFoodItem(btn: UIButton) {
        
        let addFoodVC = self.storyboard?.instantiateViewController(withIdentifier: "AddFoodForEventVC") as! AddFoodForEventVC
        addFoodVC.modalPresentationStyle = .fullScreen
        addFoodVC.foodDetailsToEdit = foodDetails[btn.tag]
        addFoodVC.addFoodItem = { dictFood in
            self.foodDetails[btn.tag] = dictFood
            DispatchQueue.main.async {
                self.tvFoodItems.reloadData()
            }
        }
        self.navigationController?.pushViewController(addFoodVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AddEventVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

