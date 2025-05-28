//
//  AddPostVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 04/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CropViewController
import FloatingPanel
import AVFoundation

class AddPostVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    @IBOutlet weak var btnPost: UIButton!

    @IBOutlet weak var lblMediaTitle: UILabel!

    @IBOutlet weak var cvMedias: UICollectionView!

    @IBOutlet weak var tfTitle: FFTextField!
    @IBOutlet weak var lblTitleError: UILabel!

    @IBOutlet weak var lblPostTypeTitle: UILabel!
    
    @IBOutlet weak var viewBtnContainer: UIView!
    @IBOutlet var btnPostTypes: [UIButton]!
    
    @IBOutlet weak var btnExpireSoon: UIButton!
    
    @IBOutlet weak var tfDays: FFTextField!
    @IBOutlet weak var lblDaysError: UILabel!

    @IBOutlet weak var tfHours: FFTextField!
    @IBOutlet weak var lblHoursError: UILabel!
    @IBOutlet weak var heightTFHours: NSLayoutConstraint!

    
    @IBOutlet weak var tvPostDesc: FFTextView!
    @IBOutlet weak var lblPostError: UILabel!

    
    @IBOutlet weak var tfAddress: FFTextField!
    @IBOutlet weak var lblAddressError: UILabel!
    
    @IBOutlet weak var lblPostStatusTitle: UILabel!
    
    @IBOutlet weak var viewPostStatusContainer: UIView!
    @IBOutlet var btnPostStatus: [UIButton]!

    @IBOutlet weak var tfAmount: FFTextField!
    @IBOutlet weak var lblAmountError: UILabel!

    @IBOutlet weak var lblAddFood: UILabel!

    @IBOutlet var viewBack: [UIView]!
    
    @IBOutlet weak var btnAddFood: UIButton!

    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    var tmpTextField = FFTextField()
    
    var ontapUpdate: (()->Void)?

    //Food Details
    @IBOutlet weak var viewFoodDetails: UIView!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblRecipe: UILabel!
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblPersonBg: UILabel!
    @IBOutlet weak var topLblPersonBg: NSLayoutConstraint!
    @IBOutlet weak var bottomLblPersonBg: NSLayoutConstraint!

    @IBOutlet weak var ivPerson: UIImageView!
    @IBOutlet weak var widthIVPerson: NSLayoutConstraint!
    @IBOutlet weak var lblRealName: UILabel!
    @IBOutlet weak var lblCookName: UILabel!
    @IBOutlet weak var lblTag: UILabel!
    @IBOutlet weak var tvCostingSheet: UITableView!
    @IBOutlet weak var heightTVCostingSheet: NSLayoutConstraint!


    var selectedPostType: Int = -1
    var selectedPostStatus: Int = -1

    let imagePicker =  UIImagePickerController()

    var selectedImgs = [Any]()
    
    var selectedAddress: GoogleAddress?
    
    var dictParams = Dictionary<String, Any>()
    var foodDetails = Array<Dictionary<String, Any>>()
    var uploadedMedias = Array<Dictionary<String, String>>()
    
    var imgToUpload: UIImage?
    var dictParamsUpload = Dictionary<String, Any>()

    var heightViewFoodDetails: NSLayoutConstraint?
    
//    var videoPathToUpload: URL?

    var postDetails: PostEventDetail?
    
    var isRenderedPostDetails: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        
        layoutCells()
        DispatchQueue.main.async {
            self.setupUI()
        }
        self.dictParamsUpload.updateValue("Post", forKey: "module")

        heightViewFoodDetails = NSLayoutConstraint(item: viewFoodDetails!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0)
        heightViewFoodDetails?.isActive = true
        viewFoodDetails.isHidden = true
    
        setData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvCostingSheet.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        self.checkButtonShowValue()
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
    
    // MARK: - UI Methods
    func setData() {
        tvCostingSheet.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        if postDetails != nil {
            if isRenderedPostDetails == false {
                lblTitle.text = "Edit Post"
                btnPost.setTitle("Update", for: .normal)
                
                tfTitle.text = postDetails?.title
                
                if postDetails?.type == "Buy" {
                    onTapPostType(btnPostTypes[0])
                } else if postDetails?.type == "Sell" {
                    onTapPostType(btnPostTypes[1])
                } else {
                    onTapPostType(btnPostTypes[2])
                }
                
                if ((postDetails?.isExpiringSoon) != nil) && (postDetails?.isExpiringSoon)! == 1 {
                    dictParams.updateValue(1, forKey: "isExpiringSoon")
                    btnExpireSoon.isSelected = false
                    tfDays.text = "\(postDetails?.days ?? 0)"
                    tfHours.text = "\(postDetails?.hours ?? 0)"
                    onTapExpireSoon(btnExpireSoon)
                } else {
                    dictParams.updateValue(0, forKey: "isExpiringSoon")
                    btnExpireSoon.isSelected = false
                    tfDays.text = ""
                    tfHours.text = ""
                    heightTFHours.constant = 0
                }
                
                tvPostDesc.text = postDetails?.description
                selectedAddress = GoogleAddress(type: "", drop_title: "", drop_location: postDetails!.address, drop_latitude: postDetails!.latitude, drop_longitude: postDetails!.longitude)
                tfAddress.text = selectedAddress?.drop_location
                
                if postDetails?.isActive == 1 {
                    onTapPostStatus(btnPostStatus[0])
                } else {
                    onTapPostStatus(btnPostStatus[1])
                }
                
                let amount = postDetails?.amount!.split(separator: "$")
                tfAmount.text = String(amount![0])
                
                dictParams.updateValue(postDetails!.id, forKey: "postId")
                
                if (postDetails!.foodDetails!.count > 0) {
                    dictParams.updateValue(postDetails!.foodDetails![0].categoryId, forKey: "categoryId")

                    var dictFood = ["categoryId": postDetails!.foodDetails![0].categoryId,
                                    "quantity": postDetails!.foodDetails![0].quantity,
                                    "recipe": postDetails!.foodDetails![0].recipe,
                                    "ingredients": postDetails!.foodDetails![0].ingredients,
                                    "realName": postDetails!.foodDetails![0].realName,
                                    "cookName": postDetails!.foodDetails![0].cookName,
                                    "tags": postDetails!.foodDetails![0].tags,
                                    "backgroundImage": postDetails!.foodDetails![0].backgroundImage
                        ] as [String : Any]
                    
                    var dictCostingSheet = Array<Dictionary<String, Any>>()
                    if postDetails!.foodDetails![0].costingSheet!.count > 0 {
                        
                        for i in 0..<postDetails!.foodDetails![0].costingSheet!.count {
                            let sheet = postDetails!.foodDetails![0].costingSheet![i]
                            dictCostingSheet.append(["name": sheet.name, "price": String(sheet.price)])
                        }
                        
                        dictFood.updateValue(dictCostingSheet, forKey: "costingSheet")
                    } else {
                        dictFood.updateValue(dictCostingSheet, forKey: "costingSheet")
                    }
                    
                    let coockImage = postDetails!.foodDetails![0].backgroundImage.split(separator: "/")
                    dictFood["backgroundImage"] = String(coockImage[coockImage.count - 1])
                    
                    foodDetails.append(dictFood)
                    self.viewFoodDetails.isHidden = false
                    self.heightViewFoodDetails?.isActive = false
                    setupFoodDetails(dictFood: dictFood)
                }
                
                if (postDetails?.medias?.count)! > 0 {
                    for media in postDetails!.medias! {
                        let subStr = media.mediaType == "Video" ? media.videoUrl!.split(separator: "/") : media.mediaImage!.split(separator: "/")
                        let dict = ["mediaName": String(subStr[subStr.count - 1]), "mediaType": media.mediaType]
                        self.uploadedMedias.append(dict)
                        self.selectedImgs.append(media.mediaImage!)
                    }
                }
                cvMedias.reloadData()
                
                isRenderedPostDetails = true
                
                for i in 0..<viewBack.count {
                    if i == 0 {
                        lblTitleError.text = ""

                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        tfTitle.setAttributedTitle(Colors.gray.returnColor())
                    }
                    else if i == 1 {
                        if btnExpireSoon.isSelected {
                            lblDaysError.text = ""
                            //
                            viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                            tfDays.setAttributedTitle(Colors.gray.returnColor())
                            //
                        }
                    } else if i == 2 {
                        if btnExpireSoon.isSelected {
                            lblHoursError.text = ""
                            //
                            viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                            tfHours.setAttributedTitle(Colors.gray.returnColor())
                            //
                        }
                    } else if i == 3 {
                        lblAddressError.text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        tfAddress.setAttributedTitle(Colors.gray.returnColor())
                        //
                    } else if i == 4 {
                       lblAmountError.text = ""
                       //
                       viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                       tfAmount.setAttributedTitle(Colors.gray.returnColor())
                       //
                    } else if i == 5 {
                        lblPostError.text = ""
                        //
                        tvPostDesc.setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            }
        } else {
            selectedPostType = 0
            btnPostTypes[0].isSelected = true
            btnPostTypes[0].backgroundColor = Colors.themeGreen.returnColor()
            btnPostTypes[0].setTitleColor(UIColor.white, for: .normal)
            btnPostTypes[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
            dictParams.updateValue("Buy", forKey: "type")
            
            dictParams.updateValue(0, forKey: "isExpiringSoon")
            
            heightTFHours.constant = 0
            
            selectedPostStatus = 0
            btnPostStatus[0].isSelected = true
            btnPostStatus[0].backgroundColor = Colors.themeGreen.returnColor()
            btnPostStatus[0].setTitleColor(UIColor.white, for: .normal)
            btnPostStatus[0].titleLabel?.font = Fonts.Semibold.returnFont(size: 14.0)
            
            dictParams.updateValue(1, forKey: "isActive")

            //Category: Veg, NonVeg
            dictParams.updateValue(1, forKey: "categoryId")
            
        }
    }
    
    func checkButtonShowValue() {
        var value = true
        
        if tfTitle.text?.trimmedString == "" || tfAddress.text?.trimmedString == "" || (selectedPostType != 2 && tfAmount.text?.trimmedString == "") {
            value = false
        }
        
        if btnExpireSoon.isSelected {
            if tfDays.text?.trimmedString == "" || tfHours.text?.trimmedString == "" {
                value = false
            }
        }
        
        if tvPostDesc.text == "" {
            value = false
        }
        
        if postDetails != nil {
            if uploadedMedias.count == 0 {
                value = false
            }
        } else {
            if selectedImgs.count == 0 {
                value = false
            }
            
        }
        
//        if foodDetails.count < 1 {
//            value = false
//        }
        
        if value == true {
            btnPost.backgroundColor = Colors.orange.returnColor()
            btnPost.isUserInteractionEnabled = true
        } else {
            btnPost.isUserInteractionEnabled = false
            btnPost.backgroundColor = Colors.inactiveButton.returnColor()
        }
    }
    
    func setupUI() {
        ivPerson.layer.cornerRadius = ivPerson.frame.size.height / 2
        ivPerson.clipsToBounds = true
        
        lblMediaTitle.setAttributedRequiredText()
        lblPostTypeTitle.setAttributedRequiredText()
        lblPostStatusTitle.setAttributedRequiredText()

        self.btnPost.layer.cornerRadius = self.btnPost.frame.size.height / 2
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        for view in viewBack {
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = view.frame.size.height / 2
        }
        
        viewBack[1].layer.cornerRadius = 40 / 2
        viewBack[2].layer.cornerRadius = 40 / 2
        
        viewBtnContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewBtnContainer.layer.borderWidth = 1.0
        viewBtnContainer.layer.cornerRadius = viewBtnContainer.frame.size.height / 2
        
        viewPostStatusContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        viewPostStatusContainer.layer.borderWidth = 1.0
        viewPostStatusContainer.layer.cornerRadius = viewBtnContainer.frame.size.height / 2
        
        tfTitle.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tfDays.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tfHours.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tfAddress.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tfAmount.setAttributedPlaceholder(Colors.lightGray.returnColor())
        tvPostDesc.setAttributedPlaceholder(Colors.lightGray.returnColor())

        
        tfTitle.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tfDays.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tfHours.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tfAddress.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        tfAmount.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

//        heightTFHours.constant = 0
        
        for btn in btnPostTypes {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
        
        for btn in btnPostStatus {
            btn.layer.cornerRadius = btn.frame.size.height / 2
        }
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        checkButtonShowValue()
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
        imagePicker.mediaTypes = ["public.image", "public.movie"]

        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func checkValidation(to: Int, from: Int) -> Bool {
        var value = true
        for i in to..<from {
            if i == 0 {
                if tfTitle.text == "" {
                    lblTitleError.getEmptyValidationString(tfTitle.placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    tfTitle.titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblTitleError.text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    tfTitle.setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            }
            else if i == 1 {
                if btnExpireSoon.isSelected {
                    if tfDays.text == "" {
                        lblDaysError.getEmptyValidationString(tfDays.placeholder ?? "")
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        tfDays.titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblDaysError.text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        tfDays.setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            } else if i == 2 {
                if btnExpireSoon.isSelected {
                    if tfHours.text == "" {
                        lblHoursError.getEmptyValidationString(tfHours.placeholder ?? "")
                        value = false
                        //
                        viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                        tfHours.titleTextColour = Colors.red.returnColor()
                        //
                    }else {
                        lblHoursError.text = ""
                        //
                        viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                        tfHours.setAttributedTitle(Colors.gray.returnColor())
                        //
                    }
                }
            } else if i == 3 {
                if tfAddress.text == "" {
                    lblAddressError.getEmptyValidationString(tfAddress.placeholder ?? "")
                    value = false
                    //
                    viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                    tfAddress.titleTextColour = Colors.red.returnColor()
                    //
                }else {
                    lblAddressError.text = ""
                    //
                    viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                    tfAddress.setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            } else if i == 4 {
               if tfAmount.text == "" {
                   
                    if selectedPostType != 2 {
                        lblAmountError.getEmptyValidationString(tfAmount.placeholder ?? "")
                        value = false
                        
                      viewBack[i].layer.borderColor = Colors.red.returnColor().cgColor
                      tfAmount.titleTextColour = Colors.red.returnColor()
                      //
                    }else {
                      lblAmountError.text = ""
                        //
                      viewBack[i].layer.borderColor = Colors.lightGray.returnColor().cgColor
                      tfAmount.titleTextColour = Colors.lightGray.returnColor()
                      //
                    }
                   
               }else {
                   lblAmountError.text = ""
                   //
                   viewBack[i].layer.borderColor = Colors.gray.returnColor().cgColor
                   tfAmount.setAttributedTitle(Colors.gray.returnColor())
                   //
               }
            } else if i == 5 {
                if tvPostDesc.text == "" {
                    lblPostError.getEmptyValidationString(tvPostDesc.hint)
                    value = false
                    //
                    tvPostDesc.titleTextColour = Colors.red.returnColor()
                    //
                } else {
                    lblPostError.text = ""
                    //
                    tvPostDesc.setAttributedTitle(Colors.gray.returnColor())
                    //
                }
            }
        }
        return value
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
    
    func setupFoodDetails(dictFood: Dictionary<String, Any>) {
        lblAddFood.text = "Edit Food"
        btnAddFood.setImage(UIImage(named: "edit_icon"), for: .normal)
        
        lblQty.text = dictFood["quantity"] as? String
        lblCategory.text = dictFood["categoryId"] as! Int == 1 ? "Veg." : "Non Veg."
        lblRecipe.text = dictFood["recipe"] as? String
        lblIngredients.text = dictFood["ingredients"] as? String

        lblPersonBg.text = "Person background with picture (Optional)"
        topLblPersonBg.constant = 16
        bottomLblPersonBg.constant = 16
        widthIVPerson.constant = 60
        if dictFood["backgroundImage"] as! String != "" {
            
            ivPerson.setImage(imageUrl: "\(BASE_IMG_URL)\(dictFood["backgroundImage"] as! String)")
        } else {
            ivPerson.image = UIImage(named: "UserPlaceholder")
            
        }
        
        lblRealName.text = dictFood["realName"] as? String
        lblCookName.text = dictFood["cookName"] as? String
        lblTag.text = dictFood["tags"] as? String

        let costSheet = dictFood["costingSheet"] as! Array<Dictionary<String, Any>>
        if costSheet.count > 0 {
            tvCostingSheet.dataSource = self
            tvCostingSheet.delegate = self
            tvCostingSheet.reloadData()
        } else {
            heightTVCostingSheet.constant = 0
        }
    }
    
    func checkDiscardValue() -> Bool {
        var value = false
        if postDetails != nil {
            if selectedImgs.count > (postDetails?.medias?.count)! || tfTitle.text != postDetails?.title || (dictParams["type"] as! String) != postDetails?.type || (postDetails?.isExpiringSoon)! != (dictParams["isExpiringSoon"] as! Int) || tvPostDesc.text != postDetails?.description || tfAddress.text != postDetails?.address || (postDetails?.isActive)! != (dictParams["isActive"] as! Int) || tfAmount.text != postDetails?.amount {
                value = true
            }else {
                if btnExpireSoon.isSelected {
                    if (postDetails?.days)! != Int(tfDays.text!) || (postDetails?.hours)! != Int(tfHours.text!) {
                        value = true
                    }
                }
            }
        }else {
            if selectedImgs.count > 0 || tfTitle.text != "" || selectedPostType != 0 || btnExpireSoon.isSelected || tvPostDesc.text != "" || tfAddress.text != "" || selectedPostStatus != 0 || tfAmount.text != "" {
                value = true
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
    
    @IBAction func onTapPostType(_ sender: UIButton) {
        selectedPostType = sender.tag
        for btn in btnPostTypes {
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
        switch selectedPostType {
            case 0:
                dictParams.updateValue("Buy", forKey: "type")
            case 1:
                dictParams.updateValue("Sell", forKey: "type")
            default:
                dictParams.updateValue("Donate", forKey: "type")
        }
        
        checkButtonShowValue()
    }
    
    @IBAction func onTapPostStatus(_ sender: UIButton) {
        selectedPostStatus = sender.tag
        for btn in btnPostStatus {
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
        dictParams.updateValue(selectedPostStatus == 0 ? 1 : 0, forKey: "isActive")
        
        checkButtonShowValue()
    }
    
    @IBAction func onTapExpireSoon(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        heightTFHours.constant = sender.isSelected ? 40 : 0
        tfDays.title.isHidden = sender.isSelected ? false : true
        tfHours.title.isHidden = sender.isSelected ? false : true
        lblDaysError.isHidden = sender.isSelected ? false : true
        lblHoursError.isHidden = sender.isSelected ? false : true
        
        lblDaysError.text = ""
        lblHoursError.text = ""
        
        if tfDays.text == "" {
            viewBack[1].layer.borderColor = Colors.lightGray.returnColor().cgColor
            tfDays.setAttributedTitle(Colors.lightGray.returnColor())
        }
        
        if tfHours.text == "" {
            viewBack[2].layer.borderColor = Colors.lightGray.returnColor().cgColor
            tfHours.setAttributedTitle(Colors.lightGray.returnColor())
        }
        
        dictParams.updateValue(sender.isSelected ? 1 : 0, forKey: "isExpiringSoon")
        
        checkButtonShowValue()
        
    }
    
    @IBAction func onTapPost(_ sender: UIButton) {
        if postDetails != nil {
            let valid = checkValidation(to: 0, from: 5)
            if self.uploadedMedias.count == 0 {
                Utilities.showPopup(title: "Select medias to upload", type: .error)
            } else if valid {
                
                //Call an API
                dictParams.updateValue(tfTitle.text!, forKey: "title")
                dictParams.updateValue(tvPostDesc.text!, forKey: "description")
                dictParams.updateValue((selectedAddress?.drop_location)!, forKey: "address")
                dictParams.updateValue((selectedAddress?.drop_latitude)!, forKey: "latitude")
                dictParams.updateValue((selectedAddress?.drop_longitude)!, forKey: "longitude")
                
                //expiringDate
                if btnExpireSoon.isSelected {
                    dictParams.updateValue(tfDays.text!, forKey: "days")
                    dictParams.updateValue(tfHours.text!, forKey: "hours")
                }
                
                if (foodDetails.count > 0) {
                    dictParams.updateValue(foodDetails[0]["categoryId"]!, forKey: "categoryId")
                    dictParams.updateValue(foodDetails, forKey: "foodDetails")
                }
                
                let tmpAmount = (tfAmount!.text)?.floatValue
                dictParams.updateValue(String(format: "%.2f", tmpAmount!), forKey: "amount")
                
                
                dictParams.updateValue(uploadedMedias, forKey: "uploadedMedias")
                
                print(dictParams)
                
                let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
                confirmPopup.titleString = "The post update will go live."
                confirmPopup.yesString = "Post"
                confirmPopup.noString = "Cancel"
                confirmPopup.tapYes = {
                    if (self.foodDetails.count > 0) {
                        self.addPost()
                    }else {
                        let selectCategoryPopup = self.storyboard?.instantiateViewController(withIdentifier: "SelectCategoryPopupVC") as! SelectCategoryPopupVC
                        selectCategoryPopup.isComeFromPost = true
                        selectCategoryPopup.tapYes = { categoryId in
                            self.dictParams.updateValue(categoryId, forKey: "categoryId")
                            self.addPost()
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
                
            }
        } else {
            let valid = checkValidation(to: 0, from: 5)
            if selectedImgs.count == 0 {
                Utilities.showPopup(title: "Select medias to upload", type: .error)
            } else if valid {
//                if foodDetails.count > 0 {
                    //Call an API
                dictParams.updateValue(tfTitle.text!, forKey: "title")
                dictParams.updateValue(tvPostDesc.text!, forKey: "description")
                dictParams.updateValue((selectedAddress?.drop_location)!, forKey: "address")
                dictParams.updateValue((selectedAddress?.drop_latitude)!, forKey: "latitude")
                dictParams.updateValue((selectedAddress?.drop_longitude)!, forKey: "longitude")
                
                //expiringDate
                if btnExpireSoon.isSelected {
                    dictParams.updateValue(tfDays.text!, forKey: "days")
                    dictParams.updateValue(tfHours.text!, forKey: "hours")
                }
                
                
                dictParams.updateValue(uploadedMedias, forKey: "uploadedMedias")
                
                if (foodDetails.count > 0) {
                    dictParams.updateValue(foodDetails[0]["categoryId"]!, forKey: "categoryId")
                    dictParams.updateValue(foodDetails, forKey: "foodDetails")
                }
                
                let tmpAmount = (tfAmount!.text)?.floatValue
                dictParams.updateValue(String(format: "%.2f", tmpAmount!), forKey: "amount")
                
                print(dictParams)
                
                let confirmPopup = self.storyboard?.instantiateViewController(withIdentifier: "CancelTicketPopupVC") as! CancelTicketPopupVC
                confirmPopup.titleString = "The post will go live."
                confirmPopup.yesString = "Post"
                confirmPopup.noString = "Cancel"
                confirmPopup.tapYes = {
                    if (self.foodDetails.count > 0) {
                        self.addPost()
                    }else {
                        let selectCategoryPopup = self.storyboard?.instantiateViewController(withIdentifier: "SelectCategoryPopupVC") as! SelectCategoryPopupVC
                        selectCategoryPopup.isComeFromPost = true
                        selectCategoryPopup.tapYes = { categoryId in
                            self.dictParams.updateValue(categoryId, forKey: "categoryId")
                            self.addPost()
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
                    
//                }
//                else {
//                    Utilities.showPopup(title: "Add food details to create post", type: .error)
//                }
            }
        }
    }
    
    @IBAction func onTapAddFood(_ sender: UIButton) {
        let addFoodVC = self.storyboard?.instantiateViewController(withIdentifier: "AddFoodVC") as! AddFoodVC
//        addFoodVC.modalPresentationStyle = .fullScreen
        if foodDetails.count > 0 {
            addFoodVC.foodDetailsToEdit = foodDetails[0]
        }
        addFoodVC.addFoodItem = { dictFood in
            self.foodDetails.removeAll()
            self.foodDetails.append(dictFood)
            
            self.viewFoodDetails.isHidden = false
            self.heightViewFoodDetails?.isActive = false
            DispatchQueue.main.async {
                self.setupFoodDetails(dictFood: dictFood)
                self.checkButtonShowValue()
            }
        }
        
        addFoodVC.modalPresentationStyle = .overCurrentContext
        addFoodVC.modalTransitionStyle = .crossDissolve
        
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
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.UPLOAD_MEDIA, fileName: "media", image: imgToUpload, movieDataURL: nil, params: dictParamsUpload) { (status, response, message) in
            self.hideLoading()
            if status {
                if response != nil {
                    let dict = ["mediaName": response!["fileName"] as! String, "mediaType": self.imgToUpload != nil ? "image" : "video"]
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
    
    func addPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addPost()
                }
            }
            return
        }
        let url = postDetails != nil ? APIManager.sharedManager.UPDATE_POST : APIManager.sharedManager.ADD_POST
        
        showLoading()
        APIManager.sharedManager.postData(url: url, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
//                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    
                    let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupVC") as! SuccessPopupVC
                    successPopup.titleString = self.postDetails != nil ? "Your post has been successfully updated." : "Your post has been successfully posted."
                    successPopup.tapDone = {
                        if self.ontapUpdate != nil {
                            self.ontapUpdate!()
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

extension AddPostVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        tmpTextField
        viewBack[textField.tag].layer.borderColor = Colors.themeGreen.returnColor().cgColor

        switch textField.tag {
            case 0:
                lblTitleError.text = ""
                tfTitle.setAttributedTitle(Colors.themeGreen.returnColor())
                break
            case 1:
                lblDaysError.text = ""
                tfDays.setAttributedTitle(Colors.themeGreen.returnColor())
                break
            case 2:
                lblHoursError.text = ""
                tfHours.setAttributedTitle(Colors.themeGreen.returnColor())
                break
            case 3:
                tmpTextField.resignFirstResponder()
                DispatchQueue.main.async {
                    self.lblAddressError.text = ""
                    self.tfAddress.setAttributedTitle(Colors.themeGreen.returnColor())
                    textField.endEditing(true)
                    let selectAddressVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectAddressVC") as! SelectAddressVC
                    selectAddressVC.modalPresentationStyle = .fullScreen
                    selectAddressVC.getSelectedAddress = { selectedAddress in
                        self.selectedAddress = selectedAddress
                        self.tfAddress.text = selectedAddress.drop_location
                        self.textFieldDidEndEditing(self.tfAddress)
                    }
                    
                    self.present(selectAddressVC, animated: true, completion: nil)
                }
                
                break
            case 4:
                lblAmountError.text = ""
                tfAmount.setAttributedTitle(Colors.themeGreen.returnColor())
                break
            default:
                break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if textField.tag == 1 {
            return newString.length <= MAX_DAYS_LENGTH
        } else if textField.tag == 2 {
            return newString.length <= MAX_HOURS_LENGTH
        } else if textField.tag == 4 {
            
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }

            let newText = oldText.replacingCharacters(in: r, with: string)
            let isNumeric = newText.isEmpty || (Double(newText) != nil)
            let numberOfDots = newText.components(separatedBy: ".").count - 1

            let numberOfDecimalDigits: Int
            if let dotIndex = newText.firstIndex(of: ".") {
                numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            } else {
                numberOfDecimalDigits = 0
            }

            return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2 && newString.length <= MAX_QUANTITY_LENGTH
        
        } else {
            return newString.length <= TEXTFIELD_LIMIT
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tmpTextField = textField as! FFTextField
        textField.text = textField.text?.trimmedString
        if self.checkValidation(to: textField.tag, from: textField.tag+1) {
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        switch textField.tag {
            case 0:
                if btnExpireSoon.isSelected {
                    tfDays.becomeFirstResponder()
                } else {
                    tvPostDesc.becomeFirstResponder()
                }
                break
            case 1:
                tfHours.becomeFirstResponder()
                break
            case 2:
                tvPostDesc.becomeFirstResponder()
                break
            case 3:
                tfAmount.becomeFirstResponder()
                break
            default:
                view.endEditing(true)
                break
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tvPostDesc.updateColor(Colors.themeGreen.returnColor())
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        
        self.checkButtonShowValue()
        
        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text?.trimmedString
        
        if textView.text == "" {
            lblPostError.getEmptyValidationString(tvPostDesc.hint)
            tvPostDesc.titleTextColour = Colors.red.returnColor()
            //
        } else {
            lblPostError.text = ""
            //
            tvPostDesc.setAttributedTitle(Colors.gray.returnColor())
            //
        }
        
        checkButtonShowValue()
    }
}

extension AddPostVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if selectedImgs.count >= 5 {
            return selectedImgs.count
        }else {
            return selectedImgs.count + 1
        }
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
                cell.ivMedia.setImage(imageUrl: (postDetails?.medias![indexPath.item].mediaImage)!)
                
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
        self.view.endEditing(true)

        if postDetails != nil {
            
            if uploadedMedias.count >= 5 {
                return
            }
            
            if indexPath.item == uploadedMedias.count {
                openImagePicker()
            }
        } else {
            
            if selectedImgs.count >= 5 {
                return
            }
            
            if indexPath.item == selectedImgs.count {
                openImagePicker()
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
//    }
    
}

extension AddPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
//            self.ivUserProfile.image = image
//            self.ivAddProfile.image = UIImage(named: "edit_icon")
            
            self.imgToUpload = image
            self.selectedImgs.append(image)
//            self.cvMedias.reloadData()
//            self.textFieldDidChange(textField: self.tfAmount)
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
                    videoCropVc.module = "Post"
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
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AddPostVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let costSheet = foodDetails[0]["costingSheet"] as! Array<Dictionary<String, Any>>
        return costSheet.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostingSheetCell") as! CostingSheetCell
        let costSheet = foodDetails[0]["costingSheet"] as! Array<Dictionary<String, Any>>

        cell.lblIngr.text = "\(costSheet[indexPath.row]["name"]!)"
        cell.lblCost.text = "$ \(String(format: "%.2f", (costSheet[indexPath.row]["price"]! as! String).floatValue))"
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.white : Colors.light.returnColor()
        
        return cell
    }
}

extension AddPostVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}
