//
//  EditTeamVC.swift
//  - To edit Team related information

//  Tussly
//
//  Created by Auxano on 10/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CropViewController

class EditTeamVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var ivBanner : UIImageView!
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblTeamNameError : UILabel!
    @IBOutlet weak var lblTeamBioError : UILabel!
    @IBOutlet weak var txtTeamName : UITextField!
    @IBOutlet weak var txtTeamBio : UITextView!
    @IBOutlet weak var viewBanner : UIView!
    @IBOutlet weak var viewEdit : UIView!
    @IBOutlet weak var viewLogo : UIView!
    @IBOutlet weak var viewStore : UIView!
    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var btnVisitStore : UIButton!
    @IBOutlet weak var btnCreateTeam : UIButton!
    @IBOutlet weak var viewLogoContainer : UIView!
    @IBOutlet weak var lblRole : UILabel!
    @IBOutlet weak var btnUpload : UIButton!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var viewshadow: UIView!
    @IBOutlet weak var lblDis1 : UILabel!
    @IBOutlet weak var lblDis2 : UILabel!
    
    @IBOutlet weak var viewScrollInside: UIView!
    
    
    // MARK: - Variables
    
    var teamData: Team?
    let imagePickerController =  UIImagePickerController()
    var isLogo = false
    var userRole: UserRole?

    // By Pranay
    @IBOutlet weak var constraintTopSaveTolblErrorBio: NSLayoutConstraint!
    // .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewScrollInside.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI Methods

    func setupUI () {
        viewBanner.layer.cornerRadius = 8.0
        //viewEdit.roundCorners(radius: 8.0, arrCornersiOS11: [.layerMaxXMinYCorner], arrCornersBelowiOS11: [.topLeft])
        viewEdit.layer.cornerRadius = 8.0
        viewStore.layer.cornerRadius = 5.0
        viewStore.layer.borderWidth = 1.0
        viewStore.layer.borderColor = Colors.border.returnColor().cgColor
        
        ////Beta 1 - disable option
        btnVisitStore.backgroundColor = Colors.disableButton.returnColor()
        
        // By Pranay
        constraintTopSaveTolblErrorBio.priority = .required
        // .
        
        btnCreateTeam.layer.cornerRadius = 15.0
        btnClose.layer.cornerRadius = 15.0
        DispatchQueue.main.async {
            self.viewLogo.layer.cornerRadius = self.viewLogo.frame.size.height / 2.0
            self.viewLogoContainer.layer.cornerRadius = self.viewLogoContainer.frame.size.height / 2.0
            self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.height / 2.0
            self.btnVisitStore.layer.cornerRadius = self.btnVisitStore.frame.size.height / 2
            
            self.btnUpload.layer.cornerRadius = self.btnUpload.frame.size.width/2
            self.btnUpload.layer.shadowColor = UIColor.black.cgColor
            self.btnUpload.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            self.btnUpload.layer.shadowOpacity = 0.2
            self.btnUpload.layer.shadowRadius = 5.0
            self.btnUpload.layer.masksToBounds = false
            
            self.viewshadow.layer.cornerRadius = self.viewshadow.frame.size.width / 2
            self.viewshadow.layer.shadowColor = UIColor.black.cgColor
            self.viewshadow.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            self.viewshadow.layer.shadowOpacity = 0.2
            self.viewshadow.layer.shadowRadius = 5.0
            self.viewshadow.layer.masksToBounds = false
            
            self.txtTeamBio.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
            
        }
        if APIManager.sharedManager.user != nil {
            lblUserName.text = APIManager.sharedManager.user?.displayName
            ivProfile.setImage(imageUrl: APIManager.sharedManager.user!.avatarImage)
            lblRole.text = userRole?.role?.capitalizingFirstLetter()
        }
        if(teamData?.teamBanner != "") {
            self.lblDis1.isHidden = true
            self.lblDis2.isHidden = true
        } else {
            self.lblDis1.isHidden = false
            self.lblDis2.isHidden = false
        }
        //ivBanner.setImage(imageUrl: teamData!.teamBanner!,placeHolder: "Banner_dummy")    //  By Pranay - comment by pranay
        ivBanner.setImage(imageUrl: teamData!.teamBanner!,placeHolder: "Banner_dummy")    //  By Pranay
        ivLogo.setImage(imageUrl: teamData!.teamLogo!)
        txtTeamName.text = teamData?.teamName
        txtTeamBio.text = teamData?.teamDescription
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
//        if teamData!.teamLogo == "" {
//            self.btnUpload.setTitle("Upload", for: .normal)
//        } else {
//            ivLogo.contentMode = .scaleAspectFill
//            self.btnUpload.setTitle("Edit", for: .normal)
//        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            self .present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ontapEditTeamBanner(_ sender : UIButton) {
        isLogo = false
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = Messages.uploadTeamBanner
        objVC.option = [Messages.uploadFile,Messages.visitStore]
        objVC.didSelectItem = { index,isImgPicker in
            switch index {
                case 0:
                    let alert:UIAlertController=UIAlertController(title: Messages.selectAction, message: nil, preferredStyle: UIAlertController.Style.alert)
                    let cameraAction = UIAlertAction(title: Messages.capturePhotoFromCamera, style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openCamera()
                    }
                    
                    let gallaryAction = UIAlertAction(title: Messages.selectPhotoFromGallery, style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openGallary()
                    }
                    
                    let cancelAction = UIAlertAction(title: Messages.cancel, style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                    }
                    alert.addAction(cameraAction)
                    alert.addAction(gallaryAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                default:
                    break
            }
        }
        objVC.isImgPicker = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapEditTeamIcon(_ sender : UIButton) {
        isLogo = true
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = Messages.uploadTeamLogo
        objVC.option = [Messages.uploadFile,Messages.visitStore]
        objVC.didSelectItem = { index,isImgPicker in
            switch index {
                case 0:
                    let alert:UIAlertController=UIAlertController(title: Messages.selectAction, message: nil, preferredStyle: UIAlertController.Style.alert)
                    let cameraAction = UIAlertAction(title: Messages.capturePhotoFromCamera, style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openCamera()
                    }
                    
                    let gallaryAction = UIAlertAction(title: Messages.selectPhotoFromGallery, style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.openGallary()
                    }
                    
                    let cancelAction = UIAlertAction(title: Messages.cancel, style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                    }
                    alert.addAction(cameraAction)
                    alert.addAction(gallaryAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    break
                default:
                    break
            }
        }
        objVC.isImgPicker = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapVisitStore(_ sender : UIButton) {
        
    }
    
    @IBAction func ontapSave(_ sender : UIButton) {
        if txtTeamName.text != "" && txtTeamBio.text != "" {
            lblTeamNameError.text = ""
            lblTeamBioError.text = ""
            saveTeamDetail()
        } else {
            if txtTeamName.text == "" {
                lblTeamNameError.getEmptyValidationString(txtTeamName.placeholder ?? "")
            }
            if (txtTeamBio.text == "") {
                lblTeamBioError.setLeftArrow(title: Empty_Team_Bio)
            }
        }
    }
    
    // MARK: - Webservices
    
    func saveTeamDetail() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.saveTeamDetail()
                }
            }
            return
        }
        
        showLoading()
        let params = ["teamId": teamData?.id as Any,"teamName" :txtTeamName.text?.trimmedString as Any,"teamDescription":txtTeamBio.text.trimmedString] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.EDIT_TEAM, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadImage(type : String,image: UIImage) {
        showLoading()
        APIManager.sharedManager.uploadImage(url: APIManager.sharedManager.UPLOAD_IMAGE, fileName: "image", image: image, type: type, id: teamData!.id ?? 0) { (success, response, message) in //teamId
            self.hideLoading()
            if success {
                print(response!["filePath"] as Any)
            } else {
               Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
}

// MARK:- UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditTeamVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            if self.isLogo {
                self.ivLogo.contentMode = .scaleAspectFill
                self.ivLogo.image = image
                self.uploadImage(type: "TeamLogo", image: image)
                //self.btnUpload.setTitle("Edit", for: .normal)
            } else {
                self.lblDis1.isHidden = true
                self.lblDis2.isHidden = true
                self.ivBanner.image = image
                self.uploadImage(type: "TeamBanner", image: image)
            }
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
            if self.isLogo == false {
                cropViewController.aspectRatioPreset = .preset4x3
                cropViewController.aspectRatioLockEnabled = true
            }
            cropViewController.delegate = self
            let navController = UINavigationController(rootViewController: cropViewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:- UITextFieldDelegate

extension EditTeamVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            lblTeamNameError.getEmptyValidationString(textField.placeholder ?? "")
        } else {
            lblTeamNameError.text = ""
        }
    }
}

// MARK:- UITextViewDelegate

extension EditTeamVC : UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            lblTeamBioError.setLeftArrow(title: Empty_Team_Bio)
        } else {
            lblTeamBioError.text = ""
        }
    }
}
