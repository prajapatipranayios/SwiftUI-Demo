//
//  ThreadReplyVC.swift
//  Tussly
//
//  Created by Auxano on 25/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK

class ThreadReplyVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlet
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewParentMsg: UIView! {
        didSet {
            self.viewParentMsg.backgroundColor = UIColor(hexString: "#FAF9F6", alpha: 1.0)
        }
    }
    @IBOutlet weak var ivParentMsgBG: UIImageView!
    @IBOutlet weak var viewParentMsgHeader: UIView! {
        didSet {
            self.viewParentMsgHeader.backgroundColor = .white
        }
    }
    @IBOutlet weak var lblParentMsgTitle: UILabel! {
       didSet {
           self.lblParentMsgTitle.textColor = Colors.black.returnColor()
       }
   }
    @IBOutlet weak var btnDone: UIButton! {
        didSet {
            self.btnDone.setTitleColor(Colors.black.returnColor(), for: .normal)
        }
    }
    @IBAction func btnDoneTap(_ sender: UIButton) {
        //self.dismiss(animated: true)
        
        /*// Check if closure is set and call it
        if let getMessageVC = self.chatMessageVC {
            //guard let parentMsgId = self.parentId else { return }
            let replyCount = self.arrMessages.count
            let messageVC = getMessageVC()
            messageVC.updateMessageWithReplyCount(parentMessageId: self.parentId, replyCount: self.arrMessages.count)
        }
        ///    */
        self.isBackPress = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var viewReplyMessage: UIView!
    @IBOutlet weak var tvReplyMessage: UITableView!
    
    
    @IBOutlet weak var viewThreadReply: UIView! {
        didSet {
            self.viewThreadReply.backgroundColor = UIColor(hexString: "#FAF9F6", alpha: 1.0)
        }
    }
    @IBOutlet weak var ivChatBG: UIImageView!
    
    @IBOutlet weak var viewHeader: UIView! {
        didSet {
            self.viewHeader.backgroundColor = Colors.disableButton.returnColor()
        }
    }
    @IBOutlet weak var lblReplyTitle: UILabel! {
        didSet {
            self.lblReplyTitle.textColor = .white
        }
    }
    
    
    @IBOutlet weak var viewMessageList: UIView!
    @IBOutlet weak var tvMessageList: UITableView!
    
    
    @IBOutlet weak var viewComposer: UIView!
    @IBOutlet weak var viewComposerInner: UIView! {
        didSet {
            self.viewComposerInner.roundCornersWithShadow(cornerRadius: 9.0,
                                                           shadowColor: .clear,
                                                           shadowOffset: .zero,
                                                           shadowOpacity: 0,
                                                           shadowRadius: 0,
                                                           borderWidth: 1.0,
                                                           borderColor: .black.withAlphaComponent(0.2))
        }
    }
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnSendMessage: UIButton! {
        didSet {
            self.btnSendMessage.tintColor = Colors.theme.returnColor()
            self.btnSendMessage.isEnabled = true
        }
    }
    @IBAction func btnSendMessageTap(_ sender: UIButton) {
        
        self.btnSendMessage.isEnabled = false
        if self.isAttachMedia {
            // Open photo.
            print("Attachment Button ...")
            self.view.endEditing(true)
            self.attachmentOption(isCamera: true, isPhotoLibrary: true, isPhotoVideoLibrary: false, isDocument: true)
        }
        else if self.isEditMessage {
            guard let text = txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }
            
            let tempMessage = self.objLongPressedMessage! as! TextMessage
            if tempMessage.text != text {
                tempMessage.text = text
                self.editMessage(tempMessage, at: self.selectedCellIndex ?? IndexPath(row: 0, section: 0))
            }
            else {
                DispatchQueue.main.async {
                    self.viewEdit.isHidden = true
                    self.isEditMessage = false
                    self.constraintTopTxtMessageToSuper.priority = .required
                    
                    self.txtMessage.text = ""
                    self.isAttachMedia = true
                    self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                    
                    self.txtMessage.becomeFirstResponder()
                    self.btnSendMessage.isEnabled = true
                }
            }
        }
        else {
            guard let text = txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }
            
            let textMessage = TextMessage(receiverUid: receiverId ?? "", text: text, receiverType: isGroup ? .group : .user)
            textMessage.parentMessageId = self.parentId
            
            CometChat.sendTextMessage(message: textMessage, onSuccess: { sentMessage in
                print("✅ Sent:", sentMessage)
                
                self.arrMessages.append(sentMessage)
                
                DispatchQueue.main.async {
                    self.txtMessage.text = ""
                    
                    self.isAttachMedia = true
                    self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                    
                    self.tvMessageList.reloadData()
                    self.shouldAutoScroll = true
                    self.scrollToBottom()
                    
                    self.updateReplyCount()
                    self.txtMessage.becomeFirstResponder()
                    self.btnSendMessage.isEnabled = true
                }
            }, onError: { error in
                DispatchQueue.main.async {
                    self.btnSendMessage.isEnabled = true
                    print("❌ Error sending message:", error?.errorDescription ?? "")
                }
            })
        }
    }
    
    @IBOutlet weak var viewEdit: UIView! {
        didSet {
            self.viewEdit.clipsToBounds = true
            self.viewEdit.layer.cornerRadius = 9.0
            self.viewEdit.backgroundColor = .lightGray.withAlphaComponent(6.0)
        }
    }
    @IBOutlet weak var lblEditTitle: UILabel!
    @IBOutlet weak var lblEditMessage: UILabel!
    @IBOutlet weak var btnCloseEditMessage: UIButton!
    @IBAction func btnCloseEditMessageTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.viewEdit.isHidden = true
            self.isEditMessage = false
            self.constraintTopTxtMessageToSuper.priority = .required
            
            self.txtMessage.text = ""
            
            self.btnSendMessage.isEnabled = true
            self.btnSendMessage.tintColor = Colors.theme.returnColor()
            self.isAttachMedia = true
            self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
        }
    }
    @IBOutlet weak var constraintTopTxtMessageToSuper: NSLayoutConstraint!
    
    
    // MARK: - Variable
    
    //var chatMessageVC: (() -> ChatMessageVC)?
    
    var delegate: ChatMessageVCDelegate?
    var isPresent: Bool = false
    var user: CometChatSDK.User?
    var group: CometChatSDK.Group?
    var isGroup: Bool = false
    var receiverId: String?
    var senderId: String?
    var messageRequest: MessagesRequest?
    
    var arrMessages: [BaseMessage] = []
    var isFetchingOlderMessages = true
    var strUserStatus: String = "offline"
    
    var delayedTask: DispatchWorkItem?
    
    var objLongPressedMessage: BaseMessage?
    var selectedCellIndex: IndexPath?
    var isEditMessage: Bool = false
    let lblStickyDate = UILabel()
    var isAttachMedia: Bool = true
    
    let imagePickerController =  UIImagePickerController()
    
    //let replyObject: BaseMessage? = nil
    var replyMessage: BaseMessage?
    var parentId: Int = 0
    var isChatEnabled: Bool = true
    let maxMessaageLimit = 100
    var shouldAutoScroll = false
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    var isBackPress: Bool = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewDLoad()
        
        self.parentId = self.replyMessage?.id ?? 0
        
        DispatchQueue.main.async {
            self.tvReplyMessage.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func updateReplyCount() {
        let msg = self.arrMessages.count > 1 ? "Replies" : "Reply"
        self.lblReplyTitle.text = "\(self.arrMessages.count) \(msg)"
    }
    
    func viewDLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.txtMessage.delegate = self
        
        self.btnSendMessage.isEnabled = true
        self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
        
        self.viewEdit.isHidden = true
        self.constraintTopTxtMessageToSuper.priority = .required
        
        //self.setUpStickyDate()
        
        self.imagePickerController.delegate = self
        self.imagePickerController.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewWAppear()
    }
    
    func viewWAppear() {
        
        self.tvReplyMessage.delegate = self
        self.tvReplyMessage.dataSource = self
        
        self.tvMessageList.delegate = self
        self.tvMessageList.dataSource = self
        
        //self.tvMessageList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        /// For Parent Msg
        // Sender
        self.tvReplyMessage.register(UINib(nibName: "SenderMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderMessageBubbleTVCell")
        self.tvReplyMessage.register(UINib(nibName: "SenderImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderImageMessageBubbleTVCell")
        self.tvReplyMessage.register(UINib(nibName: "ReceiverDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverDocumentMessageBubbleTVCell")
        
        // Receiver
        self.tvReplyMessage.register(UINib(nibName: "ReceiverMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverMessageBubbleTVCell")
        self.tvReplyMessage.register(UINib(nibName: "ReceiverImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageBubbleTVCell")
        self.tvReplyMessage.register(UINib(nibName: "SenderDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderDocumentMessageBubbleTVCell")
        
        
        /// For Reply
        // Sender
        self.tvMessageList.register(UINib(nibName: "SenderMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "SenderImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderImageMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "ReceiverDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverDocumentMessageBubbleTVCell")
        
        // Receiver
        self.tvMessageList.register(UINib(nibName: "ReceiverMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "ReceiverImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "SenderDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderDocumentMessageBubbleTVCell")
        
        //self.tvMessageList.keyboardDismissMode = .onDrag
        self.setupKeyboardDismissGesture()
        
        self.setupMessageRequest()
        self.loadMessages()
        
        DispatchQueue.main.async {
            if self.isChatEnabled {
                //CometChat.addMessageListener("threadChatMessageListener", self)
                //CometChat.addUserListener("threadUserPresenceListener", self)
                //print("ThreadVC Message Listener Active")
                
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = false
            }
            else {
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = true
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tvMessageList.reloadData()
            
            if self.isChatEnabled {
                CometChat.addMessageListener("threadChatMessageListener", self)
                CometChat.addUserListener("threadUserPresenceListener", self)
                
                print("Thread Message Listener Active")
            }
            else {
            }
        }
    }
    
    func setupKeyboardDismissGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.tvMessageList.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        self.tvMessageList.addGestureRecognizer(longPressGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTableViewTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.tvMessageList)
        
        if self.tvMessageList.indexPathForRow(at: location) != nil {
            //self.view.endEditing(true)
        }
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CometChat.removeMessageListener("threadChatMessageListener")
        CometChat.removeUserListener("threadUserPresenceListener")
        print("ThreadVC Message Listener DeActive")
        
        if !self.isBackPress {
            print("Message Listener DeActive -- popToRoot")
            self.isBackPress = false
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //CometChat.removeMessageListener("threadChatMessageListener")
        //CometChat.removeUserListener("threadUserPresenceListener")
        //print("ThreadVC Message Listener DeActive")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appDidBecomeActive() {
        // Optional: check if view is visible and should reload
        if self.isViewLoaded && self.view.window != nil {
            self.reloadMessagesOnResume()
        }
    }
    
    func reloadMessagesOnResume() {
        self.setupMessageRequest()
        self.loadMessages()
    }
}


/// Chat message retrive and send
extension ThreadReplyVC {
    
    func setupMessageRequest() {
        guard let receiverId = receiverId else { return }
        let builder = MessagesRequest.MessageRequestBuilder()
        if isGroup { builder.set(guid: receiverId) }
        else { builder.set(uid: receiverId) }
        messageRequest = builder.hideReplies(hide: true).setParentMessageId(parentMessageId: replyMessage?.id ?? 0).set(limit: self.maxMessaageLimit).build()
    }
    
    func loadMessages() {
        self.showLoading()
        messageRequest?.fetchPrevious(onSuccess: { messages in
            // Handle & show messages
            
            print(messages)
            let arrTemp = (messages ?? []).filter({ $0 is TextMessage || $0 is MediaMessage })
            
            print("==========================================")
            print(arrTemp)
            
            self.arrMessages = arrTemp
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
                
                //if let count = arrTemp?.count, count > 0 {
                if arrTemp.count > 0 {
                    let indexPath = IndexPath(row: arrTemp.count - 1, section: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tvMessageList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        let msg = self.arrMessages[arrTemp.count - 1]
                        CometChat.markAsRead(baseMessage: msg) {
                            self.getChatUnreadCount()
                        } onError: { error in
                            print("Get Error in markAsRead")
                        }
                    }
                    
                    self.isFetchingOlderMessages = (messages ?? []).count >= self.maxMessaageLimit ? true : false
                }
                else {
                    self.isFetchingOlderMessages = false
                }
                self.updateReplyCount()
                self.hideLoading()
            }
        }, onError: { error in
            print("Error loading messages: \(String(describing: error?.errorDescription))")
        })
    }
    
    func fetchPreviousMessage() {
        print("fetchPreviousMessage() -- called")
        if self.isFetchingOlderMessages {
            print("fetchPreviousMessage() -- called --- success")
            self.showLoading()
            messageRequest?.fetchPrevious(onSuccess: { messages in
                guard !(messages!.isEmpty) else {
                    self.isFetchingOlderMessages = false
                    self.hideLoading()
                    return
                }
                
                let arrTemp = (messages ?? []).filter({ $0 is TextMessage || $0 is MediaMessage })
                self.arrMessages.insert(contentsOf: arrTemp, at: 0)
                
                DispatchQueue.main.async {
                    self.tvMessageList.reloadData()
                    
                    //if let count = messages?.count, count > 0 {
                    if arrTemp.count > 0 {
                        let indexPath = IndexPath(row: arrTemp.count - 1, section: 0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.tvMessageList.scrollToRow(at: indexPath, at: .top, animated: false)
                        }
                        
                        self.isFetchingOlderMessages = (messages ?? []).count >= self.maxMessaageLimit ? true : false
                    }
                    else {
                        self.isFetchingOlderMessages = false
                    }
                }
                self.hideLoading()
                
            }, onError: { error in
                print("Error loading older messages: \(String(describing: error?.errorDescription))")
                self.isFetchingOlderMessages = false
                self.hideLoading()
            })
        }
    }
    
    func attachmentOption(isCamera: Bool = true,
                          isPhotoLibrary: Bool = true,
                          isPhotoVideoLibrary: Bool = false,
                          isDocument: Bool = true) {
        DispatchQueue.main.async {
            self.btnSendMessage.isEnabled = true
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if isCamera {
            alert.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { _ in
                // Handle Camera
                self.openCamera()
            }))
        }
        if isPhotoLibrary {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                // Handle Photo Library
                self.openGallary()
            }))
        }
        if isPhotoVideoLibrary {
            alert.addAction(UIAlertAction(title: "Photo & Video Library", style: .default, handler: { _ in
                // Handle Photo & Video Library
            }))
        }
        if isDocument {
            alert.addAction(UIAlertAction(title: "Document", style: .default, handler: { _ in
                // Handle Document
                self.openDocumentPicker()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ThreadReplyVC: CometChatMessageDelegate, CometChatUserDelegate {

    // 🔤 Text Messages
    func onTextMessageReceived(textMessage: TextMessage) {
        print("📩 Text message received: \(textMessage.stringValue())")
        
        if textMessage.parentMessageId == self.parentId {
            self.loadNewMessage(message: textMessage)
        }
    }
    
    // 🖼️ Media Messages
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        
        if mediaMessage.parentMessageId == self.parentId {
            self.loadNewMessage(message: mediaMessage)
        }
    }

    // ✅ Optional: Handle custom messages too
    func onCustomMessageReceived(customMessage: CustomMessage) {
        print("🧩 Custom message: \(customMessage.customData ?? [:])")
    }
    
    // ✅ Optional: Handle edit messages too
    func onMessageEdited(message: BaseMessage) {
        if let (index, msg) = self.arrMessages.enumerated().first(where: {
            if let textMsg = $0.element as? TextMessage {
                return textMsg.id == message.id
            }
            return false
        }) {
            self.arrMessages[index] = message
            self.tvMessageList.reloadData()
        } else {
            print("TextMessage not found")
        }
    }
    
    // ✅ Optional: Handle deleted messages too
    func onMessageDeleted(message: BaseMessage) {
        if let (index, msg) = self.arrMessages.enumerated().first(where: {
            if let textMsg = $0.element as? TextMessage {
                return textMsg.id == message.id
            }
            if let mediaMsg = $0.element as? MediaMessage {
                return mediaMsg.id == message.id
            }
            return false
        }) {
            self.arrMessages[index] = message
            self.tvMessageList.reloadData()
        } else {
            print("TextMessage not found")
        }
    }
    
    func onMessagesDelivered(receipt: MessageReceipt) {
        print("onMessagesDelivered \(receipt.stringValue())")
        if !self.isGroup {
            for (_, value) in self.arrMessages.enumerated() {
                if value.readAt <= 0 {
                    value.deliveredAt = receipt.deliveredAt
                }
            }
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
            }
        }
    }
    
    func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        print("onMessagesDeliveredToAll \(receipt.stringValue())")
        if self.isGroup {
            for (_, value) in self.arrMessages.enumerated() {
                if value.readAt <= 0 {
                    value.deliveredAt = receipt.deliveredAt
                }
            }
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
            }
        }
    }
    
    func onMessagesRead(receipt: MessageReceipt) {
        print("onMessagesRead \(receipt.stringValue())")
        if !self.isGroup {
            for (_, value) in self.arrMessages.enumerated() {
                value.readAt = receipt.readAt
            }
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
            }
        }
    }
    
    func onMessagesReadByAll(receipt: MessageReceipt) {
        print("onMessagesReadByAll \(receipt.stringValue())")
        if self.isGroup {
            for (_, value) in self.arrMessages.enumerated() {
                value.readAt = receipt.readAt
            }
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
            }
        }
    }
    
    func loadNewMessage(message: BaseMessage) {
        self.arrMessages.append(message)
        CometChat.markAsRead(baseMessage: message)
        DispatchQueue.main.async {
            self.tvMessageList.reloadData()
            self.shouldAutoScroll = true
            self.scrollToBottom()
            self.updateReplyCount()
        }
    }
    
    func getChatUnreadCount() {
        CometChat.getUnreadMessageCountForAllUsers { dictUnreadCount in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intUsersUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
        
        CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount in
            if let tempUreadCount = dictUnreadCount as? [String: Int] {
                self.intGroupsUnreadCount = tempUreadCount.keys.count
                
                self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
            }
        } onError: { error in
            print("\(error?.errorCode ?? "")")
        }
    }
}

extension ThreadReplyVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let trimmedText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.isEditMessage {
            self.btnSendMessage.isEnabled = !trimmedText.isEmpty
            self.btnSendMessage.tintColor = self.btnSendMessage.isEnabled ? Colors.theme.returnColor() : Colors.disable.returnColor()
        }
        else {
            self.isAttachMedia = trimmedText.isEmpty
            self.btnSendMessage.setImage(trimmedText.isEmpty ? UIImage(named: "imgAttach") : UIImage(named: "send"), for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
}
