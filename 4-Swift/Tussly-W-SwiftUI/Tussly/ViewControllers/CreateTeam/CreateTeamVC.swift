//
//  CreateTeamVC.swift
//  Tussly
//
//  Created by Auxano on 06/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CropViewController

class CreateTeamVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var ivBanner : UIImageView!
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblDis1 : UILabel!
    @IBOutlet weak var lblDis2 : UILabel!
    @IBOutlet weak var lblTeamNameError : UILabel!
    @IBOutlet weak var lblTeamBioError : UILabel!
    @IBOutlet weak var txtTeamName : UITextField!
    @IBOutlet weak var txtTeamBio : TLTextView!
    @IBOutlet weak var lblNote : UILabel!
    @IBOutlet weak var viewBanner : UIView!
    @IBOutlet weak var viewEdit : UIView!
    @IBOutlet weak var viewLogo : UIView!
    @IBOutlet weak var viewLogoContainer : UIView!
    @IBOutlet weak var btnUpload : UIButton!
    @IBOutlet weak var viewStore : UIView!
    @IBOutlet weak var viewFriends : UIView!
    @IBOutlet weak var viewSearchPlayer : UIView!
    @IBOutlet weak var viewTeamVideo : UIView!
    @IBOutlet weak var ivProfile : UIImageView!
    @IBOutlet weak var btnVisitStore : UIButton!
    @IBOutlet weak var btnAddFriend : UIButton!
    @IBOutlet weak var btnAddPlayer : UIButton!
    @IBOutlet weak var btnAddHere : UIButton!
    @IBOutlet weak var btnCreateTeam : UIButton!
    @IBOutlet weak var tvAddFriend : UITableView!
    @IBOutlet weak var tvAddPlayer : UITableView!
    @IBOutlet weak var tvAddFriendByEmail : UITableView!
    @IBOutlet weak var tvTeamVideo : UITableView!
    @IBOutlet weak var heightTvAddFriend : NSLayoutConstraint!
    @IBOutlet weak var heightTvAddPlayer : NSLayoutConstraint!
    @IBOutlet weak var heightTvAddFriendByEmail : NSLayoutConstraint!
    @IBOutlet weak var heightTvTeamVideo : NSLayoutConstraint!
    @IBOutlet weak var addGameContainer: UIView!
    @IBOutlet weak var viewshadow: UIView!
    @IBOutlet weak var viewAddEmail: UIView!
    @IBOutlet weak var btnAddByEmail : UIButton!
    
    @IBOutlet weak var viewScrollInside: UIView!
    
    
    // MARK: - Variables
    
    var isValid = true
    var isLogo = false
    var selectedLogoImage : UIImage?
    var selectedBannerImage : UIImage?
    let imagePickerController =  UIImagePickerController()
    var teamId = -1
    var teamDict = Dictionary<String, Any>()
    var addFriendData = [Player]()
    var addPlayerData = [PlayerData]()
    var addFriendByEmailData = [String]()
    var addVideoData = [[String : Any]]()
    var getAllFriendData = [Player]()
    
    /// 112 By Pranay
    /// If you want to enable visit store that time you need to set this as high.
    @IBOutlet weak var constraintTopInviteFriend: NSLayoutConstraint!
    /// If you want to enable visit store that time you need to remove this constraint.
    @IBOutlet weak var constraintTopInviteFriendToTopVisitStore: NSLayoutConstraint!
    @IBOutlet weak var viewAddTeamVideo: UIView!
    @IBOutlet weak var constraintTopCreateTeamToInviteFriend: NSLayoutConstraint!
    /// 112 .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        getFriend()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvAddFriend.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddPlayer.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvAddFriendByEmail.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvTeamVideo.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewScrollInside.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvAddFriend.removeObserver(self, forKeyPath: "contentSize")
        tvAddFriendByEmail.removeObserver(self, forKeyPath: "contentSize")
        tvTeamVideo.removeObserver(self, forKeyPath: "contentSize")
        tvAddPlayer.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func updateViewConstraints() {
        heightTvAddFriendByEmail.constant = tvAddFriendByEmail.contentSize.height
        heightTvTeamVideo.constant = tvTeamVideo.contentSize.height
        heightTvAddFriend.constant = tvAddFriend.contentSize.height
        heightTvAddPlayer.constant = tvAddPlayer.contentSize.height
        super.updateViewConstraints()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTvAddFriend.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    // MARK: - UI Methods
    
    func setUI () {
        let attributedText = NSMutableAttributedString(string: Messages.note, attributes: [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 14.0)])
        attributedText.append(NSMutableAttributedString(string: Messages.founderAndCaptainCanChanged, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)]))
        lblNote.attributedText = attributedText
        viewBanner.layer.cornerRadius = 8.0
        //viewEdit.roundCorners(radius: 8.0, arrCornersiOS11: [.layerMaxXMinYCorner], arrCornersBelowiOS11: [.topLeft])
        viewEdit.layer.cornerRadius = 8.0
        viewStore.layer.cornerRadius = 5.0
        viewStore.layer.borderWidth = 1.0
        viewStore.layer.borderColor = Colors.border.returnColor().cgColor
        
        /// 323 By Pranay
        viewStore.isHidden = true
        btnVisitStore.isHidden = true
        constraintTopInviteFriendToTopVisitStore.priority = .required
        
        viewSearchPlayer.isHidden = true
        viewAddEmail.isHidden = true
        viewAddTeamVideo.isHidden = true
        viewTeamVideo.isHidden = true
        
        constraintTopCreateTeamToInviteFriend.priority = .required
        /// 323 .
        
        btnCreateTeam.layer.cornerRadius = 15.0
        DispatchQueue.main.async {
            self.viewLogo.layer.cornerRadius = self.viewLogo.frame.size.width / 2
            self.viewLogoContainer.layer.cornerRadius = self.viewLogoContainer.frame.size.height / 2.0
            
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
            
            self.ivProfile.layer.cornerRadius = self.ivProfile.frame.size.width / 2
            self.btnVisitStore.layer.cornerRadius = self.btnVisitStore.frame.size.height / 2
            self.btnAddFriend.layer.cornerRadius = self.btnAddFriend.frame.size.height / 2
            self.btnAddHere.layer.cornerRadius = self.btnAddHere.frame.size.height / 2
            self.btnAddPlayer.layer.cornerRadius = self.btnAddPlayer.frame.size.height / 2
            self.btnAddByEmail.layer.cornerRadius = self.btnAddByEmail.frame.size.height / 2
            self.viewFriends.addDashedBorder()
            self.viewAddEmail.addDashedBorder()
            self.viewTeamVideo.addDashedBorder()
            self.viewSearchPlayer.addDashedBorder()
            
            //Beta 1 - disable options
            self.btnVisitStore.backgroundColor = Colors.disableButton.returnColor()
            //self.btnAddFriend.backgroundColor = Colors.disableButton.returnColor()    //  Comment By Pranay
            self.btnAddHere.backgroundColor = Colors.disableButton.returnColor()
            self.btnAddPlayer.backgroundColor = Colors.disableButton.returnColor()
            self.btnAddByEmail.backgroundColor = Colors.disableButton.returnColor()
            
            self.addGameContainer.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMinXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.bottomLeft])
        }
        tvAddFriend.delegate = self
        tvAddFriend.dataSource = self
        tvAddPlayer.delegate = self
        tvAddPlayer.dataSource = self
        tvAddFriendByEmail.delegate = self
        tvAddFriendByEmail.dataSource = self
        tvTeamVideo.delegate = self
        tvTeamVideo.dataSource = self
        
        tvAddPlayer.rowHeight = UITableView.automaticDimension
        tvAddPlayer.estimatedRowHeight = 250.0
        tvAddFriend.rowHeight = UITableView.automaticDimension
        tvAddFriend.estimatedRowHeight = 250.0
        tvTeamVideo.rowHeight = UITableView.automaticDimension
        tvTeamVideo.estimatedRowHeight = 250.0
        tvAddFriendByEmail.rowHeight = UITableView.automaticDimension
        tvAddFriendByEmail.estimatedRowHeight = 250.0
        
        if APIManager.sharedManager.user != nil {
            lblUserName.text = APIManager.sharedManager.user?.displayName
            ivProfile.setImage(imageUrl: APIManager.sharedManager.user!.avatarImage)
        }
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
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
    
    func checkValidation() -> Bool {
        var value = true
        for i in 0..<addFriendByEmailData.count {
            if addFriendByEmailData[i] == "" {
                value = false
                break
            }else {
                if (addFriendByEmailData[i].isNumber) {
                    if !((addFriendByEmailData[i].count) >= MIN_MOBILE_LENGTH) {
                        value = false
                        break
                    }
                }else {
                    if !(addFriendByEmailData[i].isValidEmail()) {
                        value = false
                        break
                    }
                }
            }
        }
        return value
    }
    
    // MARK: - Button Click Events
    
    @IBAction func ontapEditTeamBanner(_ sender : UIButton) {
        isLogo = false
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = Messages.uploadTeamBanner
        objVC.option = [Messages.uploadFile,Messages.visitStore]
        objVC.didSelectItem = { index,isImgpicker in
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
        objVC.didSelectItem = { index,isImgpicker in
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
    
    @IBAction func onTapAddFriend(_ sender : UIButton) {
        /// By Pranay - Uncomment this button code for invite friend.
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "FriendListVC") as! FriendListVC
        objVC.didSelectItem = { selectedFriend in
            self.addFriendData = selectedFriend
            self.tvAddFriend.reloadData()
        }
        objVC.titleString = Messages.inviteFriend
        objVC.buttontitle = Messages.invite
        objVC.arrFriendsList = getAllFriendData
        objVC.arrSelected = addFriendData
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddPlayers(_ sender: UIButton) {
        ////Beta 1 - disable options
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlayerVC") as! AddPlayerVC
//        objVC.didSelectOtherPlayer = { selectedPlayer in
//            self.addPlayerData = selectedPlayer
//            self.tvAddPlayer.reloadData()
//        }
//        objVC.titleString = "Search Users"
//        objVC.arrOtherSelected = addPlayerData
//        objVC.titleButton = Messages.invite
//        objVC.isFromTeam = true
//        objVC.modalPresentationStyle = .overCurrentContext
//        objVC.modalTransitionStyle = .crossDissolve
//        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddUserByEmail(_ sender : UIButton) {
        ////Beta 1 - disable options
//        if checkValidation() {
//            isValid = true
//            //addFriendByEmailData.append("")
//            addFriendByEmailData.insert("", at: 0)
//        }else {
//            isValid = false
//        }
//        tvAddFriendByEmail.reloadData()
    }
    
    @IBAction func onTapAddHere(_ sender : UIButton) {
        ////Beta 1 - disable options
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
//        objVC.uploadYoutubeVideo = { videoCaption,videoLink,thumbUrl,duration,viewCount in
//            self.addVideoData.append(["link":videoLink,"caption":videoCaption,"thumbUrl": thumbUrl,"duration":duration,"viewCount":viewCount])
//            self.tvTeamVideo.reloadData()
//        }
//        objVC.titleString = "Team Highlight Video"
//        objVC.isEdit = false
//        objVC.modalPresentationStyle = .overCurrentContext
//        objVC.modalTransitionStyle = .crossDissolve
//        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapCreatTeam(_ sender : UIButton) {
        //if txtTeamName.text != "" && txtTeamBio.text != "" {
        if txtTeamName.text != "" {    //  By Pranay - condition change
            if checkValidation() {
                isValid = true
                tvAddFriendByEmail.reloadData()
                createTeam()
            }else {
                isValid = false
                tvAddFriendByEmail.reloadData()
            }
            lblTeamNameError.text = ""
            lblTeamBioError.text = ""
        } else {
            if txtTeamName.text == "" {
                lblTeamNameError.getEmptyValidationString(txtTeamName.placeholder ?? "")
            }
            if (txtTeamBio.text == "") {
                lblTeamBioError.setLeftArrow(title: Empty_Team_Bio)
            }
        }
    }
    
    // MARK: APIs
    
    func createTeam() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.createTeam()
                }
            }
            return
        }
        
        var teamMember = [[String: Any]]()
        for i in 0..<addFriendData.count {
            teamMember.append(["userId": addFriendData[i].id!,"status": 1])
        }
        
        var teamMemberInvites = [[String: Any]]()
        for i in 0..<addFriendByEmailData.count {
            teamMemberInvites.append(["receiverEmail": addFriendByEmailData[i]])
        }
        
        var videoLinks = [[String: Any]]()
        for i in 0..<addVideoData.count {
            videoLinks.append(["videoLink": addVideoData[i]["link"] ?? "","videoCaption":addVideoData[i]["caption"] ?? "","thumbnail":addVideoData[i]["thumbUrl"] ?? "","duration":addVideoData[i]["duration"] ?? ""])
        }
        
        teamDict = ["teamName": (txtTeamName.text?.trimmedString)!,
                    "teamDescription": txtTeamBio.text.trimmedString,
                    "teamMembers": teamMember,
                    "teamMemberInvites": teamMemberInvites,
                    "videoLinks": videoLinks
            
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CREATE_TEAM, parameters: teamDict) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.teamId = response?.result?.team?.id ?? -1
                if self.selectedLogoImage != nil {
                    self.uploadImage(type: "TeamLogo", image: self.selectedLogoImage!)
                    //self.selectedLogoImage = nil
                }
                if self.selectedBannerImage != nil {
                    self.uploadImage(type: "TeamBanner", image: self.selectedBannerImage!)
                    //self.selectedBannerImage = nil
                }
                if self.selectedLogoImage == nil && self.selectedBannerImage == nil {
                    DispatchQueue.main.async {
                        self.view.tusslyTabVC.selectedIndex = 0
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getFriend() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFriend()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FRIENDS, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.getAllFriendData = (response?.result?.friends)!
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadImage(type : String,image: UIImage) {
        showLoading()
        APIManager.sharedManager.uploadImage(url: APIManager.sharedManager.UPLOAD_IMAGE, fileName: "image", image: image, type: type, id: teamId) { (success, response, message) in
            self.hideLoading()
                if success {
                if type == "TeamLogo" {
                    self.selectedLogoImage = nil
                } else {
                    self.selectedBannerImage = nil
                }
                if self.selectedLogoImage == nil && self.selectedBannerImage == nil {
                    DispatchQueue.main.async {
                        self.view.tusslyTabVC.selectedIndex = 0
                        self.view!.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: true)
                    }
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CreateTeamVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvAddFriend {
            return addFriendData.count
        } else if tableView == tvAddPlayer {
            return addPlayerData.count
        } else if tableView == tvAddFriendByEmail {
            return addFriendByEmailData.count
        } else {
            return addVideoData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvAddFriend {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addFriendData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addFriendData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddFriend
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddFriend {
                    self.addFriendData.remove(at: index)
                    self.tvAddFriend.reloadData()
                } else {
                    self.addPlayerData.remove(at: index)
                    self.tvAddPlayer.reloadData()
                }
            }
            return cell
        } else if tableView == tvAddPlayer {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendCell", for: indexPath) as! AddFriendCell
            cell.lblFriendName.text = addPlayerData[indexPath.row].displayName
            cell.imgLogo.setImage(imageUrl: addPlayerData[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.strTblName = tvAddPlayer
            cell.onTapRemoveFriend = { index,tableName in
                if tableName == self.tvAddFriend {
                    self.addFriendData.remove(at: index)
                    self.tvAddFriend.reloadData()
                } else {
                    self.addPlayerData.remove(at: index)
                    self.tvAddPlayer.reloadData()
                }
            }
            return cell
        } else if tableView == tvAddFriendByEmail {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendByEmailCell", for: indexPath) as! AddFriendByEmailCell
            cell.txtEmailOrPhone.text = addFriendByEmailData[indexPath.row]
            cell.index = indexPath.row
            
            if !isValid {
                cell.checkValidation()
            }else {
                cell.lblEmailOrPhoneError.text = ""
            }
            
            cell.onTapAddFriendByEmail = { emailOrPhone,index in
                self.addFriendByEmailData[index] = emailOrPhone
                if self.checkValidation() {
                    self.tvAddFriendByEmail.reloadData()
                    self.isValid = true
                }else {
                    self.isValid = false
                    self.tvAddFriendByEmail.reloadData()
                }
            }
            
            cell.onTapRemoveFriend = { index in
                self.view.endEditing(true)
                self.addFriendByEmailData.remove(at: index)
                self.tvAddFriendByEmail.reloadData()
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddVideoCell", for: indexPath) as! AddVideoCell
            cell.index = indexPath.row
            cell.lblCaption.text = addVideoData[indexPath.row]["caption"] as? String
            cell.imgCaption.setImage(imageUrl: addVideoData[indexPath.row]["thumbUrl"] as! String)
            cell.onTapEdit = { index in
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
                objVC.EditYoutubeVideo = { videoCaption,duration,index in
                    self.addVideoData[index]["caption"] = videoCaption
                    self.addVideoData[index]["duration"] = duration
                    self.tvTeamVideo.reloadData()
                }
                objVC.titleString = "Team Highlight Video"
                objVC.isEdit = true
                objVC.index = index
                objVC.videoUrl = self.addVideoData[index]["link"] as! String
                objVC.videoCaption = self.addVideoData[index]["caption"] as! String
                objVC.duration = self.addVideoData[index]["duration"] as! String
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
            }
            cell.onTapRemove = { index in
                self.addVideoData.remove(at: index)
                self.tvTeamVideo.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreateTeamVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            if self.isLogo {
                self.ivLogo.contentMode = .scaleAspectFill
                self.ivLogo.image = image
                if self.teamId != -1 {
                    self.uploadImage(type: "TeamLogo", image: image)
                } else {
                    self.selectedLogoImage = image
                }
                //self.btnUpload.setTitle("Edit", for: .normal)
            } else {
                self.lblDis1.isHidden = true
                self.lblDis2.isHidden = true
                self.ivBanner.image = image
                if self.teamId != -1 {
                    self.uploadImage(type: "TeamBanner", image: image)
                } else {
                    self.selectedBannerImage = image
                }
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

// MARK: - UITextFieldDelegate

extension CreateTeamVC : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            lblTeamNameError.getEmptyValidationString(textField.placeholder ?? "")
        } else {
            lblTeamNameError.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = textField.text?.trimmedString
        return true
    }
}

// MARK: - UITextViewDelegate

extension CreateTeamVC : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            lblTeamBioError.setLeftArrow(title: Empty_Team_Bio)
        } else {
            lblTeamBioError.text = ""
        }
    }
}
