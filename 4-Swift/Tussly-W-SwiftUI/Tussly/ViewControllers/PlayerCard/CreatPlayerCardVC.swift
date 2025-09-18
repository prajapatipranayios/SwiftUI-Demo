//
//  CreatPlayerCardVC.swift
//  - User can able to create Player card from this screen.

//  Tussly
//
//  Created by Auxano on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CropViewController

class CreatPlayerCardVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var ivBanner : UIImageView!
    @IBOutlet weak var ivLogo : UIImageView!
    @IBOutlet weak var lblDis1 : UILabel!
    @IBOutlet weak var lblDis2 : UILabel!
    @IBOutlet weak var lblPlayerBioError : UILabel!
    @IBOutlet weak var txtPlayerBio : UITextView!
    @IBOutlet weak var viewBanner : UIView!
    @IBOutlet weak var viewEdit : UIView!
    @IBOutlet weak var viewLogo : UIView!
    @IBOutlet weak var viewTeamVideo : UIView!
    @IBOutlet weak var viewGame : UIView!
    @IBOutlet weak var btnAddGameHere : UIButton!
    @IBOutlet weak var tvGame : UITableView!
    @IBOutlet weak var tvGamerTags : UITableView!
    @IBOutlet weak var tvVideo : UITableView!
    @IBOutlet weak var heightTvGame : NSLayoutConstraint!
    @IBOutlet weak var heightTvGamerTag : NSLayoutConstraint!
    @IBOutlet weak var heightTvVideo : NSLayoutConstraint!
    @IBOutlet weak var btnAddVideoHere : UIButton!
    @IBOutlet weak var viewGametag : UIView!
    @IBOutlet weak var btnSaveCard : UIButton!
    @IBOutlet weak var lblNote : UILabel!
    @IBOutlet weak var lblNoteGamerTag: UILabel!
    @IBOutlet weak var btnSelectGametag : UIButton!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var viewLogoContainer: UIView!
    @IBOutlet weak var viewGameContainer: UIView!
    @IBOutlet weak var viewHighlightContainer: UIView!
    @IBOutlet weak var viewshadow: UIView!
    @IBOutlet weak var btnClose : UIButton!
    
    // MARK: - Variables
    var isValid = true
    var isLogo = false
    var selectedLogoImage : UIImage?
    var selectedBannerImage : UIImage?
    let imagePickerController =  UIImagePickerController()
    var playerCardDict = Dictionary<String, Any>()
    var addGameData = [Game]()
    var gamerData = [Objects]()
    var arrGetGamerTags = [GamerTag]()
    var addVideoData = [[String : Any]]()
    var getAllGameData = [Game]()
    var selectedIndex = -1
    var selectedID = 0
    var sectionImage = ""
    
    // By Pranay
    @IBOutlet weak var constraintHeightViewGamingID: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightAddGame: NSLayoutConstraint!
    // .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSelectGametag.setTitle(Messages.selectGamertag, for: .normal)
        let attributedText = NSMutableAttributedString(string: Messages.note, attributes: [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 14.0)])
        attributedText.append(NSMutableAttributedString(string: Messages.allowAddGamerTag, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)]))
        
        let attributedTextGame = NSMutableAttributedString(string: Messages.note, attributes: [NSAttributedString.Key.font: Fonts.Bold.returnFont(size: 14.0)])
        attributedTextGame.append(NSMutableAttributedString(string: Messages.changePlayerCardAnytime, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)]))
        
        // By Pranay
        constraintHeightViewGamingID.constant = 0
        constraintHeightAddGame.constant = 0
        heightTvGamerTag.constant = 0
        // .
        
        btnSaveCard.layer.cornerRadius = 15.0
        btnClose.layer.cornerRadius = 15.0
        viewGametag.layer.cornerRadius = 5.0
        viewGametag.layer.borderWidth = 1.0
        viewGametag.layer.borderColor = Colors.border.returnColor().cgColor
        
        viewBanner.layer.cornerRadius = 8.0
        viewEdit.layer.cornerRadius = 8.0
        
        DispatchQueue.main.async {
            self.viewGameContainer.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMinXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.bottomLeft])
            self.viewHighlightContainer.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner,.layerMinXMaxYCorner], arrCornersBelowiOS11: [.topLeft,.bottomLeft])
            
            self.viewshadow.layer.cornerRadius = self.viewshadow.frame.size.width / 2
            self.viewshadow.layer.shadowColor = UIColor.black.cgColor
            self.viewshadow.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            self.viewshadow.layer.shadowOpacity = 0.2
            self.viewshadow.layer.shadowRadius = 5.0
            self.viewshadow.layer.masksToBounds = false
            
            self.btnUpload.layer.cornerRadius = self.btnUpload.frame.size.width/2
            self.btnUpload.layer.shadowColor = UIColor.black.cgColor
            self.btnUpload.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            self.btnUpload.layer.shadowOpacity = 0.2
            self.btnUpload.layer.shadowRadius = 5.0
            self.btnUpload.layer.masksToBounds = false
            
            self.viewLogo.layer.cornerRadius = self.viewLogo.frame.size.width / 2
            self.viewLogoContainer.layer.cornerRadius = self.viewLogoContainer.frame.size.width / 2
            self.btnAddGameHere.layer.cornerRadius = self.btnAddGameHere.frame.size.height / 2
            self.btnAddVideoHere.layer.cornerRadius = self.btnAddVideoHere.frame.size.height / 2
            
            ////Beta 1 - video &gaming id option disable
            self.btnAddVideoHere.backgroundColor = Colors.disableButton.returnColor()
            self.btnSelectGametag.setTitleColor(Colors.border.returnColor(), for: .normal)
            
            self.viewGame.addDashedBorder()
            self.viewTeamVideo.addDashedBorder()
        }
        
        tvVideo.register(UINib(nibName: "TeamVideoCell", bundle: nil), forCellReuseIdentifier: "TeamVideoCell")
        let headerNib = UINib.init(nibName: "CustomHeader", bundle: Bundle.main)
        tvGamerTags.register(headerNib, forHeaderFooterViewReuseIdentifier: "CustomHeader")
        tvGamerTags.register(UINib(nibName: "GamerTagCell", bundle: nil), forCellReuseIdentifier: "GamerTagCell")
        tvGame.delegate = self
        tvGame.dataSource = self
        tvGamerTags.delegate = self
        tvGamerTags.dataSource = self
        tvVideo.delegate = self
        tvVideo.dataSource = self
        
        tvGame.rowHeight = UITableView.automaticDimension
        tvGame.estimatedRowHeight = 250.0
        tvVideo.rowHeight = UITableView.automaticDimension
        tvVideo.estimatedRowHeight = 250.0
        tvGamerTags.rowHeight = UITableView.automaticDimension
        tvGamerTags.estimatedRowHeight = 250.0
        
        getGame()
        getGamerTags()
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblUserName.text = APIManager.sharedManager.user?.displayName
        txtPlayerBio.text = APIManager.sharedManager.user?.playerDescription
        
        ivLogo.setImage(imageUrl: APIManager.sharedManager.user!.avatarImage)
        if APIManager.sharedManager.user!.bannerImage != "" {
            lblDis1.isHidden = true
            lblDis2.isHidden = true
        }
        ivBanner.setImage(imageUrl: APIManager.sharedManager.user!.bannerImage,placeHolder: "Banner_dummy")
        tvGame.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvGamerTags.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvVideo.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.viewMain.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvGame.removeObserver(self, forKeyPath: "contentSize")
        tvGamerTags.removeObserver(self, forKeyPath: "contentSize")
        tvVideo.removeObserver(self, forKeyPath: "contentSize")
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func updateViewConstraints() {
        heightTvGame.constant = tvGame.contentSize.height
        
        heightTvVideo.constant = tvVideo.contentSize.height
        super.updateViewConstraints()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                heightTvGame.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    // MARK: - UI Methods
    
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
    
    func checkEmptyField(section: Int) -> Bool {
        var value = true
        for i in 0..<gamerData[section].sectionObjects.count {
            if gamerData[section].sectionObjects[i]["value"] == "" {
                value = false
                break
            }
        }
        return value
    }
    
    func checkEmptyGamerTags() {
        for i in 0..<gamerData.count {
            let sectionData = gamerData[i].sectionObjects
            for i in 0..<sectionData.count {
                if sectionData[i]["value"] == "" {
                    isValid = false
                    break
                }
            }
            if !isValid {
                break
            }
        }
    }
    
    // MARK: - Button Click Events
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func ontapEditTeamBanner(_ sender : UIButton) {
        isLogo = false
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
        objVC.titleTxt = Messages.uploadPlayercardBanner
        objVC.option = [Messages.uploadFile,Messages.visitStore]
        objVC.didSelectItem = { index,isImgPicker in
            if isImgPicker == false {
                self.selectedIndex = index
                self.selectedID = self.arrGetGamerTags[index].id
                self.btnSelectGametag.setTitle("\(self.arrGetGamerTags[index].consoleName)", for: .normal)
            } else {
                if index == 0 {
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
                } else {
                    
                }
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
        objVC.titleTxt = Messages.uploadPlayercardLogo
        objVC.option = [Messages.uploadFile,Messages.visitStore]
        objVC.didSelectItem = { index,isImgPicker in
            if isImgPicker == false {
                self.selectedIndex = index
                self.selectedID = self.arrGetGamerTags[index].id
                self.btnSelectGametag.setTitle("\(self.arrGetGamerTags[index].consoleName) Account", for: .normal)
            } else {
                if index == 0 {
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
                } else {
                    
                }
            }
        }
        objVC.isImgPicker = true
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddGameHere(_ sender : UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectGameVC") as! SelectGameVC
        objVC.didSelectItem = { selectedGame in
            self.addGameData = selectedGame
            self.tvGame.reloadData()
        }
        objVC.arrGameList = getAllGameData
        objVC.arrSelected = addGameData
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapClose(_ sender : UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
//        teamTabVC!().selectedIndex = -1
//        teamTabVC!().cvTeamTabs.selectedIndex = -1
//        teamTabVC!().cvTeamTabs.reloadData()
    }
    
    @IBAction func onTapAddVideoHere(_ sender : UIButton) {
        ////Beta 1 - video &gaming id option disable
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
//        objVC.uploadYoutubeVideo = { videoCaption,videoLink,thumbUrl,duration,viewCount in
//            self.addVideoData.append(["link":videoLink,"caption":videoCaption,"thumbUrl": thumbUrl,"duration":duration,"id":-1, "viewCount": viewCount])
//            self.tvVideo.reloadData()
//        }
//        objVC.titleString = "Team Highlight Video"
//        objVC.isEdit = false
//        objVC.modalPresentationStyle = .overCurrentContext
//        objVC.modalTransitionStyle = .crossDissolve
//        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapSavePlayerCard( _ sender : UIButton) {
        isValid = true
        /*if txtPlayerBio.text == "" {
            lblPlayerBioError.setLeftArrow(title: Empty_Player_Bio)
            isValid = false
        }   /// */
        checkEmptyGamerTags()
        if !isValid {
            tvGamerTags.reloadData()
            return
        }
        tvGamerTags.reloadData()
        savePlayerCard()
    }
    
    @IBAction func onTapSelectGametag(_ sender: UIButton) {
        ////Beta 1 - video &gaming id option disable
//        self.view.endEditing(true)
//        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectOption") as! SelectOption
//        objVC.gamerTag = arrGetGamerTags
//        objVC.titleTxt = Messages.selectGamertag
//        objVC.didSelectItem = { index,isImgPicker in
//            if isImgPicker == false {
//                self.selectedIndex = index
//                self.selectedID = self.arrGetGamerTags[index].id
//                self.sectionImage = self.arrGetGamerTags[index].consoleIcon!
//                self.btnSelectGametag.setTitle("\(self.arrGetGamerTags[index].consoleName ?? "")", for: .normal)
//            } else {
//                if index == 0 {
//                    let alert:UIAlertController=UIAlertController(title: Messages.selectAction, message: nil, preferredStyle: UIAlertController.Style.alert)
//                    let cameraAction = UIAlertAction(title: Messages.capturePhotoFromCamera, style: UIAlertAction.Style.default) {
//                        UIAlertAction in
//                        self.openCamera()
//                    }
//
//                    let gallaryAction = UIAlertAction(title: Messages.selectPhotoFromGallery, style: UIAlertAction.Style.default) {
//                        UIAlertAction in
//                        self.openGallary()
//                    }
//
//                    let cancelAction = UIAlertAction(title: Messages.cancel, style: UIAlertAction.Style.cancel) {
//                        UIAlertAction in
//                    }
//                    alert.addAction(cameraAction)
//                    alert.addAction(gallaryAction)
//                    alert.addAction(cancelAction)
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//
//                }
//            }
//        }
//        objVC.selectedIndex = selectedIndex
//        objVC.isImgPicker = false
//        objVC.modalPresentationStyle = .overCurrentContext
//        objVC.modalTransitionStyle = .crossDissolve
//        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapAddGamerTag(_ sender: UIButton) {
        if selectedIndex != -1 {
            if !gamerData.contains(where: { $0.sectionName == btnSelectGametag.titleLabel?.text}) {
                gamerData.append(Objects(id: selectedID, sectionName: btnSelectGametag.titleLabel?.text,sectionImage: sectionImage, sectionObjects: [["value":"","status":"Public"]]))
                if isValid {
                    self.tvGamerTags.reloadData()
                } else {
                    self.tvGamerTags.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.01) {
                        self.isValid = true
                        self.tvGamerTags.reloadSections([self.gamerData.count-1], with: .automatic) // Milan
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                            self.isValid = false
                        }
                    }
                }
                
                //self.tvGamerTag.reloadData()
                
                //Jaimesh
                arrGetGamerTags = arrGetGamerTags.map{
                    var mutGamerTag = $0
                    print((btnSelectGametag.titleLabel?.text)!)
                    if $0.consoleName == (btnSelectGametag.titleLabel?.text)! {
                        mutGamerTag.isSelected = true
                    }
                    return mutGamerTag
                }
                //
                
                btnSelectGametag.setTitle(Messages.selectGamertag, for: .normal)
                selectedIndex = -1
            }
        }
//        if selectedIndex != -1 {
//            if !gamerData.contains(where: { $0.sectionName == btnSelectGametag.titleLabel?.text}) {
//                gamerData.append(Objects(id: selectedID, sectionName: btnSelectGametag.titleLabel?.text, sectionObjects: [["value":"","status":"Public"]]))
//                self.tvGamerTags.reloadData()
//            }
//
//        }
    }
    
    // MARK: APIs
    
    func savePlayerCard() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.savePlayerCard()
                }
            }
            return
        }
        
        var games = [Int]()
        for i in 0..<addGameData.count {
            games.append(addGameData[i].id!)
        }
        
        var selectedTag = [[String: Any]]()
        for i in 0..<gamerData.count {
            let id = gamerData[i].id
            let numberOfTags = gamerData[i].sectionObjects
            for j in 0..<numberOfTags.count {
                selectedTag.append(["gameConsoleId":id,"gameTags":numberOfTags[j]["value"]!,"isPublic":numberOfTags[j]["status"] == "Public" ? 1 : 0])
            }
        }
        
        var videoLinks = [[String: Any]]()
        for i in 0..<addVideoData.count {
            if addVideoData[i]["id"] as! Int == -1 {
                videoLinks.append(["videoLink": addVideoData[i]["link"] ?? "","videoCaption":addVideoData[i]["caption"] ?? "","thumbnail":addVideoData[i]["thumbUrl"] ?? "","duration":addVideoData[i]["duration"] ?? ""])
            }
            
        }
        
        playerCardDict = ["playerDescription": txtPlayerBio.text.trimmedString,
                          "games": games,
                          "gamerTags": selectedTag,
                          "videoLinks": videoLinks
        ]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SAVE_PLAYER_CARD, parameters: playerCardDict) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    APIManager.sharedManager.user?.playerDescription = self.txtPlayerBio.text
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getPlayerCard() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayerCard()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_PLAYER_CARD, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.addGameData = (response?.result?.playerCard?.userGames)!
//                    self.arrGetGamerTags = (response?.result?.playerCard?.userGameTags)!
                    self.tvGame.reloadData()
                    
                    for j in 0..<(response?.result?.playerCard?.userGameTags)!.count {
                        for i in 0..<(self.arrGetGamerTags).count {
                            if self.arrGetGamerTags[i].consoleName == response?.result?.playerCard?.userGameTags![j].consoleName {
                                if !self.gamerData.contains(where: { $0.sectionName == self.arrGetGamerTags[i].consoleName}) {
                                    self.gamerData.append(Objects(id: self.arrGetGamerTags[i].id, sectionName: self.arrGetGamerTags[i].consoleName,sectionImage: self.arrGetGamerTags[i].consoleIcon, sectionObjects: [["value":(response?.result?.playerCard?.userGameTags![j].gameTags)!,"status": response?.result?.playerCard?.userGameTags![j].isPublic == 1 ? "Public" : "Private"]]))
                                }else {
                                    for k in 0..<self.gamerData.count {
                                        if self.gamerData[k].sectionName == self.arrGetGamerTags[i].consoleName {
                                            self.gamerData[k].sectionObjects.append(["value":(response?.result?.playerCard?.userGameTags![j].gameTags)!,"status": response?.result?.playerCard?.userGameTags![j].isPublic == 1 ? "Public" : "Private"])
                                        }
                                    }
                                }
                                break
                            }
                        }
                    }
                    
                    self.tvGamerTags.reloadData()
                }
            } else {
                //Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getGame() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGame()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.getAllGameData = (response?.result?.games)!
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getGamerTags() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGamerTags()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMER_TAGS, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            self.getPlayerCard()
            self.getPlayerVideo()
            if response?.status == 1 {
                self.arrGetGamerTags = (response?.result?.gameTags)!
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getPlayerVideo() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPlayerVideo()
                }
            }
            return
        }
        
            let params = ["moduleId": nil,"moduleType":"PLAYER"] as [String : Any]
            APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    DispatchQueue.main.async {
                        for i in 0..<(response?.result?.videos)!.count {
                            self.addVideoData.append(["link":(response?.result?.videos)![i].videoLink,"caption":(response?.result?.videos)![i].videoCaption,"thumbUrl": (response?.result?.videos)![i].thumbnail,"duration":(response?.result?.videos)![i].duration,"id":(response?.result?.videos)![i].id])
                        }
                        self.tvVideo.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        Utilities.showPopup(title: response?.message ?? "", type: .error)
                    }
                }
            }
        }
    
    func editPlayerVideo(videoId: Int,caption : String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.editPlayerVideo(videoId: videoId, caption: caption)
                }
            }
            return
        }
        
        self.showLoading()
        let params = ["videoId": videoId,"videoCaption" :caption] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.EDIT_VIDEO, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
            }
            if response?.status == 1 {
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func deleteTeamVideo(videoId: Int,index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.deleteTeamVideo(videoId: videoId, index: index)
                }
            }
            return
        }
        
        self.showLoading()
        let params = ["videoId": videoId]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.addVideoData.remove(at: index)
                    self.tvVideo.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadImage(type : String,image: UIImage) {
        showLoading()
        APIManager.sharedManager.uploadImage(url: APIManager.sharedManager.UPLOAD_IMAGE, fileName: "image", image: image, type: type, id: APIManager.sharedManager.user!.id) { (success, response, message) in
            self.hideLoading()
            if success {
                DispatchQueue.main.async {
                    if type == "AvatarImage" {
                        APIManager.sharedManager.user?.avatarImage = response!["filePath"] as! String
                        //self.btnUpload.setTitle("Edit", for: .normal)
                    } else {
                        APIManager.sharedManager.user?.bannerImage = response!["filePath"] as! String
                        self.lblDis1.isHidden = true
                        self.lblDis2.isHidden = true
                    }
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CreatPlayerCardVC: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tvGamerTags {
            return gamerData.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tvGame {
            return addGameData.count
        } else if tableView == tvGamerTags {
            return gamerData.count == 0 ? 0 : gamerData[section].sectionObjects.count
        } else {
            return addVideoData.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tvGame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddGamesCell", for: indexPath) as! AddGamesCell
            cell.lblGameName.text = addGameData[indexPath.row].gameName
            cell.ivLogo.setImage(imageUrl: addGameData[indexPath.row].gameLogo ?? "")
            cell.index = indexPath.row
            cell.onTapRemoveGame = { index in
                self.addGameData.remove(at: index)
                self.tvGame.reloadData()
            }
            return cell
        } else if tableView == tvGamerTags {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GamerTagCell", for: indexPath) as! GamerTagCell
            cell.index = indexPath.row
            cell.section = indexPath.section
            cell.btnStatus.isSelected = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"] == "Public" ? false : true
            cell.txtPlaystation.placeholder = "Enter \(gamerData[indexPath.section].sectionName.replacingOccurrences(of: "Account", with: "")) Name"
            cell.txtPlaystation.text = gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"]
            cell.lblSwitchStatus.text = gamerData[indexPath.section].sectionObjects[indexPath.row]["status"]
            
            if isValid {
                cell.lblError.text = ""
            } else {
                if gamerData[indexPath.section].sectionObjects[indexPath.row][ "value"] == "" {
                    cell.lblError.setLeftArrow(title: "Please enter \(gamerData[indexPath.section].sectionName ?? "") Name")
                } else {
                    cell.lblError.text = ""
                }
            }
            
            cell.getPlaystationName = { playStationName,index,section in
                self.gamerData[section].sectionObjects[index]["value"] = playStationName
                for i in 0..<self.gamerData.count {
                    let sectionData = self.gamerData[i].sectionObjects
                    for i in 0..<sectionData.count {
                        if sectionData[i]["value"] == "" {
                            self.isValid = false
                            break
                        } else {
                            self.isValid = true
                        }
                    }
                    if !self.isValid {
                        self.tvGamerTags.reloadSections([section], with: .automatic)
                        //                    self.tvGamerTag.reloadData() - Jaimesh
                        return
                    }
                }
                //            self.tvGamerTag.reloadData() - Jaimesh
                self.tvGamerTags.reloadSections([section], with: .automatic)
            }
            
            cell.onTapRemovePlaystation = { index, section in
                self.view.endEditing(true)
                self.gamerData[section].sectionObjects.remove(at: index)
                if self.gamerData[section].sectionObjects.count == 0 {
                    //Jaimesh
                    self.arrGetGamerTags = self.arrGetGamerTags.map{
                        var mutGamerTag = $0
                        if $0.consoleName == self.gamerData[section].sectionName {
                            mutGamerTag.isSelected = false
                        }
                        return mutGamerTag
                    }
                    //
                    self.gamerData.remove(at: section)
                }
                self.tvGamerTags.reloadData()
//                self.view.endEditing(true)
//                self.gamerData[section].sectionObjects.remove(at: index)
//                if self.gamerData[section].sectionObjects.count == 0 {
//                    self.gamerData.remove(at: section)
//                }
//                self.tvGamerTags.reloadData()
            }
            
            cell.onTapSwitch = { status,index,section in
                self.gamerData[section].sectionObjects[index]["status"] = status
                self.tvGamerTags.reloadSections([section], with: .automatic)
                //self.tvGamerTags.reloadData()
            }
            
            return cell
        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "AddVideoCell", for: indexPath) as! AddVideoCell
//            cell.index = indexPath.row
//            cell.lblCaption.text = addVideoData[indexPath.row]["caption"] as? String
//            cell.imgCaption.setImage(imageUrl: addVideoData[indexPath.row]["thumbUrl"] as! String)
//
//            cell.onTapEdit = { index in
//                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
//                objVC.EditYoutubeVideo = { videoCaption,duration,index in
//                    self.addVideoData[index]["caption"] = videoCaption
//                    self.addVideoData[index]["duration"] = duration
//                    self.tvVideo.reloadData()
//                    if self.addVideoData[index]["id"] as! Int != -1 {
//                        self.editPlayerVideo(videoId: self.addVideoData[index]["id"] as! Int, caption: videoCaption)
//                    }
//                }
//                objVC.titleString = "Team Highlight Video"
//                objVC.isEdit = true
//                objVC.index = index
//                objVC.videoUrl = self.addVideoData[index]["link"] as! String
//                objVC.videoCaption = self.addVideoData[index]["caption"] as! String
//                objVC.duration = self.addVideoData[index]["duration"] as! String
//                objVC.modalPresentationStyle = .overCurrentContext
//                objVC.modalTransitionStyle = .crossDissolve
//                self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
//            }
//
//            cell.onTapRemove = { index in
//                if self.addVideoData[index]["id"] as! Int == -1 {
//                    self.addVideoData.remove(at: index)
//                    self.tvVideo.reloadData()
//                } else {
//                    self.deleteTeamVideo(videoId: self.addVideoData[index]["id"] as! Int, index: index)
//                }
//            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoCell", for: indexPath) as! TeamVideoCell
            cell.ivVideo.setImage(imageUrl: self.addVideoData[indexPath.row]["thumbUrl"] as! String)
            cell.lblDuration.text = self.addVideoData[indexPath.row]["duration"] as! String
            cell.lblTitle.text = self.addVideoData[indexPath.row]["caption"] as! String
            cell.lblUserName.isHidden = true
            cell.btnEdit.tag = indexPath.row
            cell.btnDelete.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(editVideo(btn:)), for: .touchUpInside)
            cell.btnDelete.addTarget(self, action: #selector(deleteVideo(btn:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tvGamerTags {
            if gamerData.count != 0 {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeader") as! CustomHeader
                headerView.customLabel.text = "\(gamerData[section].sectionName ?? "") Account"
                //headerView.customImage.image = UIImage.init(named: gamerData[section].sectionName + ".png")
                headerView.customImage.setImage(imageUrl: gamerData[section].sectionImage)
                headerView.sectionNumber = section
                headerView.onTapAddAccount = { section in
                    if self.self.checkEmptyField(section: section) {
                        self.isValid = true
                        //self.gamerData[section].sectionObjects.append(["value":"","status":"Public"])
                        self.gamerData[section].sectionObjects.insert(["value":"","status":"Public"], at: 0)
                    } else {
                        self.isValid = false
                    }
                    self.tvGamerTags.reloadSections([section], with: .automatic)
                    //self.tvGamerTags.reloadData()
                }
                return headerView
            }
            return nil
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tvGamerTags {
            if gamerData.count != 0 {
                return 66
            }
            return 0
        }
        return 0
    }
    
    @objc func deleteVideo(btn: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.removeVideo
        
        var caption : String = (self.addVideoData[btn.tag]["caption"] ?? "") as! String
        dialog.message = "Do you want to remove the video with title '\(caption)' from this team?"
        dialog.highlightString = self.addVideoData[btn.tag]["caption"] as! String
        dialog.tapOK = {
            if self.addVideoData[btn.tag]["id"] as! Int == -1 {
                self.addVideoData.remove(at: btn.tag)
                                self.tvVideo.reloadData()
                            } else {
                                self.deleteTeamVideo(videoId: self.addVideoData[btn.tag]["id"] as! Int, index: btn.tag)
                            }
                    }
        dialog.btnYesText = Messages.remove
        dialog.btnNoText = Messages.cancel
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @objc func editVideo(btn: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
        objVC.EditYoutubeVideo = { videoCaption,duration,index in
            self.addVideoData[btn.tag]["caption"] = videoCaption
            self.addVideoData[btn.tag]["duration"] = duration
            self.tvVideo.reloadData()
            if self.addVideoData[btn.tag]["id"] as! Int != -1 {
                self.editPlayerVideo(videoId: self.addVideoData[btn.tag]["id"] as! Int, caption: videoCaption)
            }
        }
        objVC.titleString = "Team Highlight Video"
        objVC.isEdit = true
        objVC.index = btn.tag
        objVC.videoUrl = self.addVideoData[btn.tag]["link"] as! String
        objVC.videoCaption = self.addVideoData[btn.tag]["caption"] as! String
        objVC.duration = self.addVideoData[btn.tag]["duration"] as! String
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension CreatPlayerCardVC: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            lblPlayerBioError.setLeftArrow(title: Empty_Player_Bio)
        } else {
            lblPlayerBioError.text = ""
        }
    }
    
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 175    // 100 Limit Value
    }
}

// MARK: - UIImagePickerControllerDelegate

extension CreatPlayerCardVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate, CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            if self.isLogo {
                self.ivLogo.contentMode = .scaleAspectFill
                self.ivLogo.image = image
                self.uploadImage(type: "AvatarImage", image: image)
            } else {
                self.lblDis1.isHidden = true
                self.lblDis2.isHidden = true
                self.ivBanner.image = image
                self.uploadImage(type: "BannerImage", image: image)
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
