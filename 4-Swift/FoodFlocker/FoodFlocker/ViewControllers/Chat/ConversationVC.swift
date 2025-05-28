//
//  ConversationVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import CropViewController
import FloatingPanel
import AVFoundation

class ConversationVC: UIViewController {

    //Outlets
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!

    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var tvChats: UITableView!
    
    @IBOutlet weak var viewTFContainer: UIView!
//    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var tvMessage: UITextView!
//    @IBOutlet weak var heightTVContainer: NSLayoutConstraint!

    
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSendMessage: UIButton!

    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    var userId: Int!
    var profilePic: String!
    var userName: String!
    var conversationId: String!

    var arrData: [ChatMessage] = []
    var arrSectionTitle: [String] = []
    var arrSection: [[ChatMessage]] = []
    
    let imagePicker =  UIImagePickerController()
    
    var imgToUpload: UIImage?
    var dictParamsUpload = Dictionary<String, Any>()
    var fileToUpload: String?
    var fileToUploadType: String?

    var isTableReload = false
    var isApiCalling = false
    var lastIndex = 0
    var chatTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.dictParamsUpload.updateValue("Chat", forKey: "module")

        tvChats.register(UINib(nibName: "ConversationSecHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ConversationSecHeaderView")
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        imagePicker.mediaTypes = ["public.image", "public.movie"]
        
        tvMessage.delegate = self
        ivUser.setImage(imageUrl: profilePic)
        lblUserName.text = userName
        
        self.tvMessage.text = "Type a message..."
        self.tvMessage.textColor = .lightGray
        
        getChats(indexId: lastIndex, isGreater: 1, index: 0, sectionIndex: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.chatTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                self.getChats(indexId: self.lastIndex, isGreater: 1, index: 0, sectionIndex: 0, isBackground: true)
            }
        }
        
        btnSendMessage.isEnabled = false
        btnSendMessage.setImage(UIImage(named: "SendInactive"), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        chatTimer?.invalidate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
    }
    
    func setupUI() {
        ivUser.layer.cornerRadius = ivUser.frame.size.height / 2
        ivUser.layer.borderColor = UIColor.white.cgColor
        ivUser.layer.borderWidth = 1.0
        
        viewTFContainer.layer.cornerRadius = viewTFContainer.frame.size.height / 2
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapClear(_ sender: UIButton) {
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
        chooseOptionVC?.removePanel = { option in
            self.fpcOptions.removePanelFromParent(animated: false)
            self.blurView.isHidden = true

            if option == 0 {
                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.userId = self.userId
                self.view.ffTabVC.navigationController?.pushViewController(profileVC, animated: true)
            } else {
                self.clearConversation(conversationId: self.conversationId)
            }
        }
        
        chooseOptionVC?.isFromChat = true
        fpcOptions.set(contentViewController: chooseOptionVC)
        fpcOptions.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
        
        
    }
    
    @IBAction func onTapAttachment(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func onTapSendMessage(_ sender: UIButton) {
        if tvMessage.text != "Type a message..." {
            sendMessage()
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
    
    func setDictionary(isGreater: Int, index: Int, sectionIndex: Int, isBackground: Bool) {
        
        self.arrSection.removeAll()
        self.arrSectionTitle.removeAll()
        
        var tmpArrData = self.arrData
        tmpArrData = arrData.sorted(by: { $0.messageTime < $1.messageTime })
//        print("arrData: \(self.arrData)")
        if (tmpArrData.count > 0) {
            let sortedArray = Utilities.sortArrayDictDescendingForWinner(dict: tmpArrData)
            let array: [ChatMessage] = Utilities.noDuplicates(sortedArray)
            
            for i in array {
                let strDate1 = "\(i.messageDate ?? "")"
                
                var arrayData : [ChatMessage] = []
                for j in sortedArray {
                    let strDate2 = "\(j.messageDate ?? "")"
                    if (strDate1 == strDate2) {
                        arrayData.append(j)
                    }
                }
                
                self.arrSectionTitle.append("\(i.messageDate ?? "")")
                self.arrSection.append(arrayData)
            }
            
            print("arrSectionTitle: \(self.arrSectionTitle)")
            print("arrSection: \(self.arrSection)")
                            
            self.lastIndex = self.arrSection[arrSectionTitle.count-1][arrSection[arrSectionTitle.count-1].count-1].id
        }
        
        self.isTableReload = true
        self.tvChats.dataSource = self
        self.tvChats.delegate = self
        self.tvChats.reloadData()
        
        if tmpArrData.count > 0 {
            if !isBackground {
                if isGreater == 1 {
                    self.tvChats.scrollToRow(at: IndexPath(row: arrSection[arrSectionTitle.count-1].count-1, section: arrSectionTitle.count-1), at: .bottom, animated: false)
                }else {
                    self.tvChats.scrollToRow(at: IndexPath(row: self.arrSection[(arrSectionTitle.count-1) - sectionIndex].count - index, section: (arrSectionTitle.count-1) - sectionIndex), at: .bottom, animated: false)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTableReload = false
        }
    }
    
    // MARK: - Webservices
    func getChats(indexId: Int, isGreater: Int, index: Int, sectionIndex: Int, isBackground: Bool = false) {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getChats(indexId: indexId, isGreater: isGreater, index: index, sectionIndex: sectionIndex, isBackground: isBackground)
                }
            }
            return
        }
        
        let dictParams = ["timeZone": "+05:30", "indexId": indexId, "isGreater": isGreater, "otherUserId": userId!] as [String : Any]
        
        if !isBackground {
            showLoading()
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_CHAT_MESSAGES, parameters: dictParams) { (response: ApiResponse?, error) in
            if !isBackground {
                self.hideLoading()
            }
            
            DispatchQueue.main.async {
                if response?.status == 1 {
                    let arrInfo = (response?.result?.data)!
                    if arrInfo.count > 0 {
                        for index in 0..<arrInfo.count {
                            self.arrData.append(ChatMessage(id: arrInfo[index].id, message: arrInfo[index].message, messageUrl: arrInfo[index].messageUrl, isRead: arrInfo[index].isRead, senderId: arrInfo[index].senderId, receiverId: arrInfo[index].receiverId, messageType: arrInfo[index].messageType, messageDate: arrInfo[index].messageDate, messageTime: arrInfo[index].messageTime, createdAt: arrInfo[index].createdAt))
                        }
                        
                        self.setDictionary(isGreater: isGreater, index: index, sectionIndex: sectionIndex, isBackground: isBackground)
                    }else {
//                        if isGreater == 1 {
//                            self.setDictionary(isGreater: isGreater, index: index, sectionIndex: sectionIndex)
//                        }
                    }
                    
                    self.isApiCalling = false
                    
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func sendMessage() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendMessage()
                }
            }
            return
        }
        
        var dictParams: [String : Any]!
        if fileToUpload != nil {
            dictParams = ["message": fileToUpload!, "receiverId": userId!, "messageType": fileToUploadType ?? "Image", "timeZone": "+05:30"] as [String : Any]
            if dictParamsUpload["mediaType"] as! String == "Video" {
                dictParams.updateValue("VIDEO", forKey: "messageType")
            } else {
                dictParams.updateValue("IMAGE", forKey: "messageType")
            }
        } else {
            dictParams = ["message": tvMessage.text!.trimmedString.encodeEmoji, "receiverId": userId!, "messageType": "MESSAGE", "timeZone": "+05:30"] as [String : Any]
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEND_MESSAGE, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                
                if response?.status == 1 {
                    self.tvMessage.text = ""
                    self.btnSendMessage.isEnabled = false
                    self.btnSendMessage.setImage(UIImage(named: "SendInactive"), for: .normal)
                    self.tvMessage.resignFirstResponder()
                    if self.tvMessage.text == "" {
                        self.tvMessage.text = "Type a message..."
                        self.tvMessage.textColor = .lightGray
                    }
                    self.fileToUpload = nil
                    self.fileToUploadType = ""
                    self.arrData.append((response?.result?.lastMessage)!)
                    self.setDictionary(isGreater: 1, index: 0, sectionIndex: 0, isBackground: false)
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func clearConversation(conversationId: String) {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.clearConversation(conversationId: conversationId)
                }
            }
            return
        }
        
        let dictParams = ["identifiers": [conversationId]] as [String : Any]
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_CONVERSATION, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.arrData.removeAll()
                    self.arrSection.removeAll()
                    self.arrSectionTitle.removeAll()
                    self.tvChats.reloadData()
                    
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
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
                    self.fileToUpload = response!["fileName"] as? String
                    self.fileToUploadType = "Image"
                    self.sendMessage()
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

extension ConversationVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSection[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ConversationSecHeaderView") as! ConversationSecHeaderView
        
        header.lblDate.text = arrSectionTitle[section]

        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatObj = arrSection[indexPath.section][indexPath.row]
        var cell: ConversationTVCell!
        if chatObj.senderId == APIManager.sharedManager.user!.id && (chatObj.messageType == "IMAGE" || chatObj.messageType == "VIDEO") {
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationMediaRightTVCell", for: indexPath) as? ConversationTVCell
            cell.viewMessage.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner], arrCornersBelowiOS11: [.topLeft, .bottomLeft , .topRight])
            cell.btnVideoPlay.tag = indexPath.row
            cell.btnVideoPlay.accessibilityLabel = "\(indexPath.section)"
            cell.btnVideoPlay.addTarget(self, action: #selector(onMediaTapped(_:)), for: .touchUpInside)
        } else if chatObj.senderId == APIManager.sharedManager.user!.id {
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationRightTVCell", for: indexPath) as? ConversationTVCell
            cell.viewMessage.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner], arrCornersBelowiOS11: [.topLeft, .bottomLeft , .topRight])
        }else if (chatObj.messageType == "IMAGE" || chatObj.messageType == "VIDEO") {
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationMediaLeftTVCell", for: indexPath) as? ConversationTVCell
            cell.viewMessage.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.topLeft, .bottomRight , .topRight])
            cell.btnVideoPlay.tag = indexPath.row
            cell.btnVideoPlay.accessibilityLabel = "\(indexPath.section)"
            cell.btnVideoPlay.addTarget(self, action: #selector(onMediaTapped(_:)), for: .touchUpInside)
        }else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ConversationLeftTVCell", for: indexPath) as? ConversationTVCell
            cell.viewMessage.roundCorners(radius: 5.0, arrCornersiOS11: [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.topLeft, .bottomRight , .topRight])
        }
        
        if chatObj.messageType == "IMAGE" {
            cell.ivMedia.isHidden = false
            cell.ivMediaVideo.isHidden = true
            cell.ivMedia.layoutIfNeeded()
            cell.ivMedia.setImage(imageUrl: chatObj.messageUrl)
        } else if chatObj.messageType == "VIDEO" {
            cell.ivMedia.isHidden = false
            cell.ivMediaVideo.isHidden = false
            cell.ivMedia.layoutIfNeeded()
            cell.ivMedia.setImage(imageUrl: chatObj.thumbnailImage ?? "")
        } else {
            cell.lblMessage.text = chatObj.message.decodeEmoji
        }
        
        cell.lblDateTime.text = chatObj.messageTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !isApiCalling {
            if !isTableReload {
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        isApiCalling = true
                        self.getChats(indexId: arrSection[indexPath.section][indexPath.row].id, isGreater: 0, index: arrSection[indexPath.section].count-1, sectionIndex: arrSection.count-1)
                    }
                }
                
                if indexPath.section == arrSection.count-1 {
                    if indexPath.row == arrSection[indexPath.section].count-1 {
                        isApiCalling = true
                        self.getChats(indexId: arrSection[indexPath.section][indexPath.row].id, isGreater: 1, index: arrSection[indexPath.section].count-1, sectionIndex: arrSection.count-1)
                    }
                }
            }
        }
    }
    
    @objc func onMediaTapped(_ sender: UIButton) {
        let chatObj = arrSection[Int("\(sender.accessibilityLabel ?? "0")")!][sender.tag]
        
        let viewMedia = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVideoVC") as! ViewImageVideoVC
        viewMedia.isViewPost = true
        viewMedia.isComeFromChat = true
        viewMedia.modalPresentationStyle = .overCurrentContext
        viewMedia.modalTransitionStyle = .crossDissolve
        viewMedia.chat = chatObj
        self.present(viewMedia, animated: true, completion: nil)
    }
    
}

extension ConversationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString != "" {
            btnSendMessage.isEnabled = true
            btnSendMessage.isSelected = true
        } else {
            btnSendMessage.isEnabled = false
            btnSendMessage.isSelected = false
        }
        
        return true
    }
}

extension ConversationVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            self.imgToUpload = image
            self.dictParamsUpload.updateValue("Image", forKey: "mediaType")
            self.dictParamsUpload.updateValue("Chat", forKey: "module")
            self.fileToUploadType = "Image"
            self.uploadImageOrVideo()
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
            self.dictParamsUpload.updateValue("Chat", forKey: "module")
            self.fileToUploadType = "Video"
            dismiss(animated: true) {
                DispatchQueue.main.async {
//                    self.uploadImageOrVideo() - Jaimesh
                    let videoCropVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCropVC") as! VideoCropVC
                    videoCropVc.modalPresentationStyle = .fullScreen
                    videoCropVc.selectedUrl = videoUrl//self.videoPathToUpload
                    videoCropVc.dictParamsVideoUpload = self.dictParamsUpload
                    videoCropVc.module = "Chat"
                    videoCropVc.updateVideoParams = { params in
                        print(params)
                        self.fileToUpload = params["mediaImage"]
                        self.fileToUploadType = "Video"
                        self.sendMessage()
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

extension ConversationVC: UITextViewDelegate {
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type a message..." {
            textView.text = ""
            textView.textColor = .black
        }
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Type a message..."
            textView.textColor = .lightGray
        }
    }
   
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        
        if newString != "" {
            btnSendMessage.isEnabled = true
            btnSendMessage.setImage(UIImage(named: "SendActive"), for: .normal)
        }else {
            btnSendMessage.isEnabled = false
            btnSendMessage.setImage(UIImage(named: "SendInactive"), for: .normal)
        }
        
        if textView.contentSize.height < 80 {
            textView.isScrollEnabled = false
        }else {
            textView.isScrollEnabled = true
        }
//        heightTVContainer.constant = textView.frame.size.height
        return true
    }
}

extension ConversationVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

extension String {
    var encodeEmoji: String{
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }
    
    var decodeEmoji: String{
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
}
