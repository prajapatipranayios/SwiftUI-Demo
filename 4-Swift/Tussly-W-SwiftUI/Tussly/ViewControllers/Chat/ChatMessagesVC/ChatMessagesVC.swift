//
//  ChatMessagesVC.swift
//  Tussly
//
//  Created by Auxano on 07/03/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK
//import CometChatUIKitSwift
import IQKeyboardManagerSwift

protocol ChatMessageVCDelegate: AnyObject {
    func ReloadChatListVC()
}

class ChatMessageVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlet
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewMainBackground: UIView! {
        didSet {
            self.viewMainBackground.backgroundColor = UIColor(hexString: "#FAF9F6", alpha: 1.0)
        }
    }
    @IBOutlet weak var constraintBottomViewMainBackgroundToSuper: NSLayoutConstraint!
    @IBOutlet weak var ivChatBG: UIImageView!
    
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBAction func btnBackTap(_ sender: UIButton) {
        if self.isPresent {
            print("View dismiss")
        }
        else {
            self.isBackPress = true
            if self.isFromTeamCard {
                DispatchQueue.main.async {
                    print("Back press from Team Tab.")
                    self.teamTabVC!().selectedIndex = -1
                    self.teamTabVC!().cvTeamTabs.selectedIndex = -1
                    self.teamTabVC!().cvTeamTabs.reloadData()
                    self.teamTabVC!().updateTab(at: -1)
                }
            }
            else if self.isFromArena {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBOutlet weak var ivAvatar: UIImageView! {
        didSet {
            self.ivAvatar.layer.cornerRadius = self.ivAvatar.frame.width / 2
        }
    }
    @IBOutlet weak var constraintLeadingIvAvatarToSuper: NSLayoutConstraint!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var constraintVCenterLblUserNameToSuper: NSLayoutConstraint!
    @IBOutlet weak var lblUserStatus: UILabel!
    @IBOutlet weak var btnContactAdmin: UIButton! {
        didSet {
            self.btnContactAdmin.tintColor = Colors.theme.returnColor()
        }
    }
    @IBAction func btnContactAdminTap(_ sender: UIButton) {
        if !self.isAddAdminTap {
            self.isAddAdminTap = true
            //self.addAdminToGroup()
            let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
            dialog.modalPresentationStyle = .overCurrentContext
            dialog.modalTransitionStyle = .crossDissolve
            dialog.titleText = Messages.addAdminTitle
            dialog.message = Messages.addAdminMsg
            dialog.btnYesText = Messages.yes
            dialog.btnNoText = Messages.cancel
            dialog.tapOK = {
                self.addAdminToGroup()
            }
            dialog.tapCancel = {
                self.isAddAdminTap = false
            }
            self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil) //  */
        }
    }
    
    @IBOutlet weak var viewMessageList: UIView!
    @IBOutlet weak var tvMessageList: UITableView!
    @IBOutlet weak var constraintBottomViewMessageListToSuper: NSLayoutConstraint!
    
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
                self.viewEdit.isHidden = true
                self.isEditMessage = false
                self.constraintTopTxtMessageToSuper.priority = .required
                
                self.txtMessage.text = ""
                self.isAttachMedia = true
                self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                
                self.txtMessage.becomeFirstResponder()
                
                DispatchQueue.main.async {
                    self.btnSendMessage.isEnabled = true
                }
            }
        }
        else {
            guard let text = txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }
            
            let textMessage = TextMessage(receiverUid: receiverId ?? "", text: text, receiverType: isGroup ? .group : .user)
            
            CometChat.sendTextMessage(message: textMessage, onSuccess: { sentMessage in
                print("✅ Sent:", sentMessage)
                
                if self.arrMessages.isEmpty && !self.isGroup {
                    self.getConvorsation(id: self.receiverId ?? "", type: .user)
                }
                
                self.arrMessages.append(sentMessage)
                
                DispatchQueue.main.async {
                    self.txtMessage.text = ""
                    
                    self.isAttachMedia = true
                    self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                    
                    self.tvMessageList.reloadData()
                    
                    self.shouldAutoScroll = true
                    self.scrollToBottom()
                    
                    self.removeNoDataLabels()
                    
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
    
    var isFromPlayerCard: Bool = false
    var isFromTeamCard: Bool = false
    var isFromTournament: Bool = false
    var isFromArena: Bool = false
    var playerTabVC: (()->PlayerCardTabVC)?
    var teamTabVC: (()->TeamTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    
    var delegate: ChatMessageVCDelegate?
    var isPresent: Bool = false
    var user: CometChatSDK.User?
    var group: CometChatSDK.Group?
    var isGroup: Bool = false
    var receiverId: String?
    var senderId: String?
    var conversationId: String?
    var messageRequest: MessagesRequest?
    
    var objConversation: Conversation?
    var arrMessages: [BaseMessage] = []
    var isFetchingOlderMessages = true
    var strUserStatus: String = "offline"
    
    //var delayedTask: DispatchWorkItem?
    var typingDebounceTimer: Timer?
    
    var objLongPressedMessage: BaseMessage?
    var selectedCellIndex: IndexPath?
    var isEditMessage: Bool = false
    var lblStickyDate: UILabel?
    var isAttachMedia: Bool = true
    
    var strUserName: String = ""
    var strUserAvatar: String = ""
    
    var isChatEnabled: Bool = true
    var strOrganizerId: Int = 0
    
    var isFromThreadReply: Bool = false
    let maxMessaageLimit = 100
    var shouldAutoScroll = false
    var isBackPress: Bool = false
    var isReplyPress: Bool = false
    var isAddAdminTap: Bool = false
    var isPlayerCardChatTap: Bool = false
    var isTyping: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.txtMessage.delegate = self
        
        self.hideLoading()
        
        self.lblUserName.text = self.strUserName
        self.ivAvatar.setImage(imageUrl: self.strUserAvatar)
        
        if let conversation = self.objConversation,
           let user = conversation.conversationWith as? CometChatSDK.User {
            print("Call get data from user -- \(user.name ?? "")")
            self.lblUserName.text = user.name ?? ""
            self.ivAvatar.setImage(imageUrl: user.avatar ?? "")
            self.lblUserStatus.isHidden = false
            
            if self.objConversation!.unreadMessageCount > 0 {
                if self.tusslyTabVC != nil {
                    self.tusslyTabVC!().chatNotificationCount(count: 1)
                }
            }
            
            self.getConvorsation(id: self.receiverId ?? "", type: .user)
        }
        else if let conversation = self.objConversation,
                let group = conversation.conversationWith as? CometChatSDK.Group {
            print("Call get data from group -- \(group.name ?? "")")
            self.receiverId = group.guid
            self.lblUserName.text = group.name ?? ""
            self.ivAvatar.setImage(imageUrl: group.icon ?? "")
            self.lblUserStatus.isHidden = true
            
            if self.objConversation!.unreadMessageCount > 0 {
                if self.tusslyTabVC != nil {
                    self.tusslyTabVC!().chatNotificationCount(count: 1)
                }
            }
            
            self.getConvorsation(id: self.receiverId ?? "", type: .group)
        }
        else {
            print("Direct set data")
            self.setChatData()
        }
        
        //self.setupMessageRequest()
        //self.loadMessages()
        
        self.viewEdit.isHidden = true
        self.constraintTopTxtMessageToSuper.priority = .required
        
        DispatchQueue.main.async {
            self.btnSendMessage.isEnabled = true
            self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
            
            self.setUpStickyDate()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tvMessageList.delegate = self
        self.tvMessageList.dataSource = self
        //self.tvMessageList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        // Action
        self.tvMessageList.register(UINib(nibName: "ActionMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ActionMessageBubbleTVCell")
        
        // Sender
        self.tvMessageList.register(UINib(nibName: "SenderMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "SenderImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderImageMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "ReceiverDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverDocumentMessageBubbleTVCell")
        
        // Receiver
        self.tvMessageList.register(UINib(nibName: "ReceiverMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "ReceiverImageMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageMessageBubbleTVCell")
        self.tvMessageList.register(UINib(nibName: "SenderDocumentMessageBubbleTVCell", bundle: nil), forCellReuseIdentifier: "SenderDocumentMessageBubbleTVCell")
        
        //self.tvMessageList.keyboardDismissMode = .onDrag
        //self.setupKeyboardDismissGesture()
        
        self.btnContactAdmin.isHidden = true
        self.constraintLeadingIvAvatarToSuper.priority = self.isFromTournament ? .required : .defaultLow
        self.btnBack.isHidden = false
        if self.isFromTeamCard {
            APIManager.sharedManager.isMainTabTap = false
            if (self.teamTabVC!().selectedIndex == 1) || (self.teamTabVC!().selectedIndex == 0) {
                self.teamTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.teamTabVC!().cvTeamTabs.frame.origin.y),animate: true)
            }
        }
        else if self.isFromTournament {
            self.btnBack.isHidden = true
            self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
        }
        else if self.isFromPlayerCard {
            APIManager.sharedManager.isMainTabTap = false
            if self.playerTabVC!().selectedIndex == 1 {
                self.playerTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.playerTabVC!().cvPlayerTabs.frame.origin.y),animate: true)
            }
        }
        
        DispatchQueue.main.async {
            if self.isChatEnabled {
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = false
            }
            else {
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = true
                self.matchFinishedLabel()
            }
        }
        print("View appear will...")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.tvMessageList.reloadData()
            
            print("View appear did...")
            self.setupMessageRequest()
            self.loadMessages()
            
            if self.isFromThreadReply {
                self.isFromThreadReply = false
                print("Come from thread reply...")
                self.setChatData()
            }
            self.isReplyPress = false
        }
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let screenHeight = UIScreen.main.bounds.height
        //let screenHeight = self.view.frame.height
        //let keyboardHeight = max(screenHeight - endFrame.origin.y, 0) - (self.tusslyTabVC!().viewBottom.frame.height)
        let keyboardHeight = max(((screenHeight - endFrame.origin.y) - (self.tusslyTabVC!().viewBottom.frame.height + 25)), 0)
        
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curveValue << 16),
            animations: {
                // Update your view’s bottom constraint or height here
                self.constraintBottomViewMainBackgroundToSuper.constant = keyboardHeight
                self.view.layoutIfNeeded()
                
                if self.arrMessages.isEmpty {
                    self.removeNoDataLabels()
                    self.showNoMessagesLabel()
                }
                else {
                    self.removeNoDataLabels()
                }
            },
            completion: nil
        )
    }
    
    func setupKeyboardDismissGesture() {
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //tapGesture.cancelsTouchesInView = false // So it doesn’t block touches like cell selection
        //view.addGestureRecognizer(tapGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.tvMessageList.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        self.tvMessageList.addGestureRecognizer(longPressGesture)
    }

//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer, otherGestureRecognizer is UILongPressGestureRecognizer {
            return true
        }
        return false
    }
    
    @objc func handleTableViewTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self.tvMessageList)
        
        if self.tvMessageList.indexPathForRow(at: location) != nil {
            //self.view.endEditing(true)
        }
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CometChat.removeMessageListener("chatMessageListener")
        CometChat.removeUserListener("userPresenceListener")
        CometChat.removeGroupListener("chatGroupListener")
        print("Message Listener DeActive")
        
        if !self.isReplyPress {
            APIManager.sharedManager.chatActiveConversationId = ""
        }
        
        IQKeyboardManager.shared.isEnabled = true
        NotificationCenter.default.removeObserver(self)
        
        //if (self.isFromTeamCard || (self.isPlayerCardChatTap && self.isFromPlayerCard)) && !self.isBackPress && !self.isReplyPress {
        //if ((self.isPlayerCardChatTap && self.isFromPlayerCard)) && !self.isBackPress && !self.isReplyPress {
        if (APIManager.sharedManager.isMainTabTap || (self.isPlayerCardChatTap && self.isFromPlayerCard)) && !self.isBackPress && !self.isReplyPress {
            print("Message Listener DeActive -- popToBack -- 2")
            self.isBackPress = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        CometChat.removeMessageListener("chatMessageListener")
//        CometChat.removeUserListener("userPresenceListener")
//
//        print("MessageVC Listener DeActive")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appDidBecomeActive() {
        // Optional: check if view is visible and should reload
        if self.isViewLoaded && self.view.window != nil {
            self.reloadMessagesOnResume()
        }
    }
    
    @objc func appDidEnterBackground() {
        print("Chat MessageVC - App moved to background")
        // Your custom logic here
        let typingIndicator = TypingIndicator(receiverID: self.receiverId!, receiverType: isGroup ? .group : .user)
        print("Typing End...3")
        CometChat.endTyping(indicator: typingIndicator)
        
        // Hide the indicator
        self.lblUserStatus.text = self.isGroup ? "" : self.strUserStatus
        self.lblUserStatus.textColor = .black
        self.lblUserStatus.isHidden = self.isGroup ? true : false
        DispatchQueue.main.async {
            self.constraintVCenterLblUserNameToSuper.priority = self.isGroup ? .required : .defaultLow
        }
    }
    
    func reloadMessagesOnResume() {
        self.setupMessageRequest()
        self.loadMessages()
    }
    
    func getConvorsation(id: String, type: CometChat.ConversationType = .user) {
        self.showLoading()
        CometChat.getConversation(conversationWith: id, conversationType: type) { conversation in
          print("success \(String(describing: conversation?.stringValue()))")
            self.objConversation = conversation
            DispatchQueue.main.async {
                self.hideLoading()
                self.setChatData()
            }
        } onError: { error in
            print("error \((error?.errorDescription)!)")
            self.hideLoading()
            if let cometChatError = error {
                if (error?.errorCode ?? "") == "ERROR_USER_NOT_LOGGED_IN" {
                    //Utilities.showPopup(title: "User not register with chat.", type: .error)
                    Utilities.showPopup(title: "Chat login failed. Messaging features will be unavailable, but the rest of the application is unaffected.", type: .error)
                }
            }
        }
    }
    
    func setChatData() {
        // Set user or  group data
        
        if let tempConversation = self.objConversation {
            self.conversationId = tempConversation.conversationId ?? ""
            APIManager.sharedManager.chatActiveConversationId = self.conversationId ?? ""
            
            self.user = tempConversation.conversationWith as? CometChatSDK.User
            self.group = tempConversation.conversationWith as? CometChatSDK.Group
            
            self.isGroup = false
            if let group = tempConversation.conversationWith as? CometChatSDK.Group {
                self.group = group
                self.isGroup = true
                self.receiverId = group.guid
                
                if let metadata = group.metadata {
                    self.isFromArena = true
                    if let intEnabled = metadata["isEnabled"] as? Int {
                        self.isChatEnabled = (intEnabled == 1) ? true : false
                        self.isFromArena = (intEnabled == 1) ? true : false
                    }
                    if let strOrganizerId = metadata["organizerId"] as? Int {
                        self.strOrganizerId = strOrganizerId
                    }
                }
            }
        }
        
        if !self.isGroup {
            if let tempUser = self.user {
                print("User - \(tempUser.name ?? "") -- \(tempUser.status == .online)")
                self.lblUserName.text = tempUser.name ?? ""
                self.ivAvatar.setImage(imageUrl: tempUser.avatar ?? "")
                self.lblUserStatus.text = (tempUser.status == .online ? "online" : "offline")
                self.strUserStatus = tempUser.status == .online ? "online" : "offline"
                DispatchQueue.main.async {
                    self.lblUserStatus.isHidden = false
                    self.constraintVCenterLblUserNameToSuper.priority = .defaultLow
                }
            }
            else {
                self.lblUserName.text = self.strUserName
                self.ivAvatar.setImage(imageUrl: self.strUserAvatar)
                //self.lblUserStatus.text = (self.user?.status == .online ? "online" : "offline")
                self.strUserStatus = self.user?.status == .online ? "online" : "offline"
                self.lblUserStatus.isHidden = true
                DispatchQueue.main.async {
                    self.constraintVCenterLblUserNameToSuper.priority = .required
                }
            }
        }
        else {
            self.lblUserName.text = self.group?.name ?? ""
            self.ivAvatar.setImage(imageUrl: self.group?.icon ?? "")
            self.lblUserStatus.isHidden = true
            DispatchQueue.main.async {
                self.constraintVCenterLblUserNameToSuper.priority = .required
            }
        }
        
        self.viewHeader.backgroundColor = .white
        
        self.btnContactAdmin.isHidden = !self.isFromArena
        
        DispatchQueue.main.async {
            if self.isChatEnabled {
                
                //CometChat.addMessageListener("chatMessageListener", self)
                //CometChat.addUserListener("userPresenceListener", self)
                //print("MessageVC Listener Active")
                
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = false
                
                CometChat.addMessageListener("chatMessageListener", self)
                CometChat.addUserListener("userPresenceListener", self)
                CometChat.addGroupListener("chatGroupListener", self)
                
                IQKeyboardManager.shared.isEnabled = false
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.keyboardWillChangeFrame(_:)),
                                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                                       object: nil)
                
                self.setupKeyboardDismissGesture()
                
                print("MessageVC Listener Active")
            }
            else {
                self.viewComposer.clipsToBounds = true
                self.viewComposerInner.isHidden = true
                self.matchFinishedLabel()
            }
        }
    }
}


/// Chat message retrive and send
extension ChatMessageVC {
    
    func setupMessageRequest() {
        //messageRequest = MessagesRequest.MessageRequestBuilder().
        
        guard let receiverId = receiverId else { return }

        let builder = MessagesRequest.MessageRequestBuilder()

        if isGroup {    builder.set(guid: receiverId)   }
        else {  builder.set(uid: receiverId)    }
        
        //messageRequest = builder.hideReplies(hide: true).set(limit: self.maxMessaageLimit).build()
        messageRequest = builder.set(limit: self.maxMessaageLimit).build()
    }
    
    func loadMessages() {
        self.showLoading()
        messageRequest?.fetchPrevious(onSuccess: { messages in
            // Handle & show messages
            
            let arrTemp = (messages ?? []).filter { message in
                if message is TextMessage || message is MediaMessage {
                    if message.parentMessageId > 0 {
                        print("Reply Message parent ID... --- \(message.parentMessageId)")
                        print("Reply Message Read At... --- \(message.readAt)")
                        if (message.readAt) == 0 {
                            print("Unread Reply Message ... --- \(message.parentMessageId)")
                            CometChat.markAsRead(baseMessage: message)
                        }
                        return false
                    }
                    else {
                        return true
                    }
                }
                else if let actionMsg = message as? ActionMessage {
                    
                    switch actionMsg.action {
                    //case .joined, .left, .kicked, .banned, .unbanned, .added, .scopeChanged, .messageEdited, .messageDeleted:
                    case .joined, .left, .kicked, .banned, .unbanned, .added, .scopeChanged:
                        return true
                    default:
                        return false
                    }
                }
                return false
            }
            
            self.arrMessages = arrTemp
            
            DispatchQueue.main.async {
                self.tvMessageList.reloadData()
                
                if arrTemp.count > 0 {
                    self.removeNoDataLabels()
                    let indexPath = IndexPath(row: arrTemp.count - 1, section: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tvMessageList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        let msg = self.arrMessages[arrTemp.count - 1]
                        /*CometChat.markAsRead(baseMessage: msg) {
                            self.getChatUnreadCount()
                        } onError: { error in
                            print("Get Error in markAsRead")
                        }   //  */
                    }
                    
                    self.isFetchingOlderMessages = arrTemp.count >= self.maxMessaageLimit ? true : false
                    
                    if (messages ?? []).count >= self.maxMessaageLimit {
                        self.isFetchingOlderMessages = true
                    }
                }
                else {
                    self.showNoMessagesLabel()
                    self.isFetchingOlderMessages = false
                }
                self.hideLoading()
            }
        }, onError: { error in
            self.hideLoading()
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
                
                //let arrTemp = (messages ?? []).filter({ $0 is TextMessage || $0 is MediaMessage || $0 is ActionMessage })
                
                let arrTemp = (messages ?? []).filter { message in
                    if message is TextMessage || message is MediaMessage {
                        if message.parentMessageId > 0 {
                            print("Reply Message parent ID... --- \(message.parentMessageId)")
                            print("Reply Message Read At... --- \(message.readAt)")
                            if (message.readAt) == 0 {
                                print("Unread Reply Message ... --- \(message.parentMessageId)")
                                CometChat.markAsRead(baseMessage: message)
                            }
                            return false
                        }
                        else {
                            return true
                        }
                    }
                    else if let actionMsg = message as? ActionMessage {
                        
                        switch actionMsg.action {
                        //case .joined, .left, .kicked, .banned, .unbanned, .added, .scopeChanged, .messageEdited, .messageDeleted:
                        case .joined, .left, .kicked, .banned, .unbanned, .added, .scopeChanged:
                            return true
                        default:
                            return false
                        }
                    }
                    return false
                }
                
                self.arrMessages.insert(contentsOf: arrTemp, at: 0)
                
                DispatchQueue.main.async {
                    self.tvMessageList.reloadData()
                    
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

extension ChatMessageVC: CometChatMessageDelegate, CometChatUserDelegate {

    // 🔤 Text Messages
    func onTextMessageReceived(textMessage: TextMessage) {
        print("ChatMsg Text message received: \(textMessage.stringValue())")
        
        if (textMessage.conversationId == self.conversationId ?? "") && (textMessage.parentMessageId <= 0) {
            self.loadNewMessage(message: textMessage)
        }
        else if (textMessage.conversationId == self.conversationId ?? "") && (textMessage.parentMessageId > 0) {
            if let (index, msg) = self.arrMessages.enumerated().first(where: {
                if let textMsg = $0.element as? TextMessage {
                    return textMsg.id == textMessage.parentMessageId
                }
                return false
            }) {
                print("Edit Found MediaMessage at index: \(index)")
                //print("TextMessage: \((message as? TextMessage)?.text ?? "")")
                var count = msg.replyCount + 1
                msg.replyCount = count
                self.arrMessages[index] = msg
                self.tvMessageList.reloadData()
                CometChat.markAsRead(baseMessage: textMessage)
                self.shouldAutoScroll = true
                self.scrollToBottom()
            } else {
                print("TextMessage not found")
            }
        }
        else if !self.isGroup {
            if ((self.conversationId == nil || self.conversationId == "") && ((textMessage.sender?.name ?? "" == self.strUserName) && (textMessage.sender?.uid ?? "" == self.receiverId) && (textMessage.senderUid == self.receiverId))) {
                self.loadNewMessage(message: textMessage)
            }
        }
    }
    
    // 🖼️ Media Messages
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        print("ChatMsg Media message received: \(mediaMessage.stringValue())")
        
        if (mediaMessage.conversationId == self.conversationId ?? "") && (mediaMessage.parentMessageId <= 0) {
            self.loadNewMessage(message: mediaMessage)
        }
        else if (mediaMessage.conversationId == self.conversationId ?? "") && (mediaMessage.parentMessageId >= 0) {
            if let (index, msg) = self.arrMessages.enumerated().first(where: {
                if let textMsg = $0.element as? MediaMessage {
                    return textMsg.id == mediaMessage.parentMessageId
                }
                return false
            }) {
                print("Edit Found MediaMessage at index: \(index)")
                //print("TextMessage: \((message as? TextMessage)?.text ?? "")")
                var count = msg.replyCount + 1
                msg.replyCount = count
                self.arrMessages[index] = msg
                self.tvMessageList.reloadData()
                CometChat.markAsRead(baseMessage: mediaMessage)
                self.shouldAutoScroll = true
                self.scrollToBottom()
            } else {
                print("MediaMessage not found")
            }
        }
        else if !self.isGroup {
            if ((self.conversationId == nil || self.conversationId == "") && ((mediaMessage.sender?.name ?? "" == self.strUserName) && (mediaMessage.sender?.uid ?? "" == self.receiverId))) {
                self.loadNewMessage(message: mediaMessage)
                //self.getConvorsation(id: self.receiverId ?? "", type: .user)
            }
        }
    }

    // ✅ Optional: Handle custom messages too
    func onCustomMessageReceived(customMessage: CustomMessage) {
        print("ChatMsg Custom message: \(customMessage.customData ?? [:])")
    }
    
    // ✅ Optional: Handle edit messages too
    func onMessageEdited(message: BaseMessage) {
        // Optional: Update your local messages array
        if let (index, msg) = self.arrMessages.enumerated().first(where: {
            if let textMsg = $0.element as? TextMessage {
                return textMsg.id == message.id
            }
            return false
        }) {
            print("Edit Found TextMessage at index: \(index)")
            print("TextMessage: \((message as? TextMessage)?.text ?? "")")
            self.arrMessages[index] = message
            self.tvMessageList.reloadData()
        } else {
            print("TextMessage not found")
        }
    }
    
    // ✅ Optional: Handle deleted messages too
    func onMessageDeleted(message: BaseMessage) {
        if let (index, _) = self.arrMessages.enumerated().first(where: {
            if let textMsg = $0.element as? TextMessage {
                return textMsg.id == message.id
            }
            if let mediaMsg = $0.element as? MediaMessage {
                return mediaMsg.id == message.id
            }
            return false
        }) {
            print("Delete Found TextMessage at index: \(index)")
            print("TextMessage: \((message as? TextMessage)?.text ?? "")")
            self.arrMessages[index] = message
            self.tvMessageList.reloadData()
        } else {
            print("TextMessage not found")
        }
    }
    
    func userTyping(_ typing: Bool, timer: Bool) {
        let typingIndicator = TypingIndicator(receiverID: self.receiverId!, receiverType: isGroup ? .group : .user)
        
        if typing {
            print("Typing Start...")
            CometChat.startTyping(indicator: typingIndicator)
            
            if timer {
                self.typingDebounceTimer?.invalidate()
                self.typingDebounceTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    print("Typing End...debounced")
                    self.isTyping = false
                    CometChat.endTyping(indicator: typingIndicator)
                }
            }
        }
        else {
            self.typingDebounceTimer?.invalidate()
            print("Typing End...manual")
            self.isTyping = false
            CometChat.endTyping(indicator: typingIndicator)
        }
    }
    
//    func cancelScheduledTask() {
//        delayedTask?.cancel()
//    }
    
    func onTypingStarted(_ typingDetails : TypingIndicator) {
        print("✏️ Typing started from: \(typingDetails.sender?.name ?? "Unknown")")
        
        print(typingDetails.sender?.uid ?? "")
        print(typingDetails.receiverID)
        
        if (self.conversationId != nil) && (self.conversationId != "") {
            if (typingDetails.sender?.uid == self.receiverId) && (typingDetails.receiverType == .user) {
                
                self.lblUserStatus.text = "typing..."
            }
            else if (typingDetails.receiverID == self.receiverId) && (typingDetails.receiverType == .group) {
                self.lblUserStatus.text = "@\(typingDetails.sender?.name ?? "") is typing..."
                DispatchQueue.main.async {
                    self.constraintVCenterLblUserNameToSuper.priority = .defaultLow
                }
                
            }
            self.lblUserStatus.textColor = .systemGreen
            self.lblUserStatus.isHidden = false
        }
    }

    func onTypingEnded(_ typingDetails : TypingIndicator) {
        print("✏️ Typing ended from: \(typingDetails.sender?.name ?? "Unknown")")
        
        if (self.conversationId != nil) && (self.conversationId != "") {
            // Hide the indicator
            self.lblUserStatus.text = self.isGroup ? "" : self.strUserStatus
            self.lblUserStatus.textColor = .black
            self.lblUserStatus.isHidden = self.isGroup ? true : false
            DispatchQueue.main.async {
                self.constraintVCenterLblUserNameToSuper.priority = self.isGroup ? .required : .defaultLow
            }
        }
    }
    
    func onUserOnline(user: CometChatSDK.User) {
        print("🟢 User online: \(user.name ?? "")")
        
        if user.uid == receiverId {
            self.strUserStatus = "online"
            self.lblUserStatus.text = "online"
            self.lblUserStatus.textColor = .black
        }
    }
    
    func onUserOffline(user: CometChatSDK.User) {
        print("🔴 User offline: \(user.name ?? "")")
        
        if user.uid == receiverId {
            self.strUserStatus = "offline"
            self.lblUserStatus.text = "offline"
            self.lblUserStatus.textColor = .black
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
        if self.arrMessages.count < 1 {
            if !self.isGroup {
                self.getConvorsation(id: self.receiverId ?? "", type: .user)
            }
            self.removeNoDataLabels()
        }
//        if self.arrMessages.count < 1 {
//            self.removeNoDataLabels()
//        }
        self.arrMessages.append(message)
        //CometChat.markAsRead(baseMessage: message)
        DispatchQueue.main.async {
            self.tvMessageList.reloadData()
            self.shouldAutoScroll = true
            self.scrollToBottom()
        }
    }
    
    /*func getChatUnreadCount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            CometChat.getUnreadMessageCountForAllUsers { dictUnreadCount in
                if let tempUreadCount = dictUnreadCount as? [String: Int] {
                    self.intUsersUnreadCount = tempUreadCount.keys.count
                    
                    if self.tusslyTabVC != nil {
                        self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                    }
                }
            } onError: { error in
                print("\(error?.errorCode ?? "")")
            }
            
            CometChat.getUnreadMessageCountForAllGroups { dictUnreadCount in
                if let tempUreadCount = dictUnreadCount as? [String: Int] {
                    self.intGroupsUnreadCount = tempUreadCount.keys.count
                    
                    if self.tusslyTabVC != nil {
                        self.tusslyTabVC!().chatNotificationCount(usersCount: self.intUsersUnreadCount, groupsCount: self.intGroupsUnreadCount)
                    }
                }
            } onError: { error in
                print("\(error?.errorCode ?? "")")
            }
        }
    }   //  */
}

extension ChatMessageVC: CometChatGroupDelegate {
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy addedby: CometChatSDK.User, addedUser userAdded: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        print(action.message ?? "")
        if (action.conversationId == self.conversationId ?? "") {
            self.loadNewMessage(message: action)
        }
    }
}

extension ChatMessageVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let trimmedText = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        DispatchQueue.main.async {
            if self.isEditMessage {
                self.btnSendMessage.isEnabled = !trimmedText.isEmpty
                self.btnSendMessage.tintColor = self.btnSendMessage.isEnabled ? Colors.theme.returnColor() : Colors.disable.returnColor()
            }
            else {
                self.isAttachMedia = trimmedText.isEmpty
                self.btnSendMessage.setImage(trimmedText.isEmpty ? UIImage(named: "imgAttach") : UIImage(named: "send"), for: .normal)
            }
            
            if !self.isTyping {
                self.isTyping = true
                self.userTyping(!(textField.text!.isEmpty), timer: !(textField.text!.isEmpty))
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
}
