//
//  ChatVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import CometChatSDK


class ChatVC: UIViewController, ChatMessageVCDelegate {
    
    
    // MARK: - Outlet
    
    @IBOutlet weak var tvChatList: UITableView!
    @IBOutlet weak var viewSearchBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - Variables
    
    var isFromPlayerCard = false
    var isFromTournament = false
    var playerTabVC: (()->PlayerCardTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    
    var arrConversation: [Conversation] = []
    var conversationRequest: ConversationRequest?
    var isLoading = false
    var isFetchingMore = false
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var intUsersUnreadCount: Int = 0
    var intGroupsUnreadCount: Int = 0
    
    var isNewMessage: Bool = false
    var strReceiverId: String = ""
    var isBackFromMessage: Bool = false
    var isPlayerCardChatTap: Bool = false
    var isLoadMore: Bool = false
    let maxConversationLimit = 30
    
    
    // MARK: - Pull to Refresh
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshConversations), for: .valueChanged)
        return control
    }()
    
//    @objc func refreshConversations() {
//        self.setupConversationRequest()
//        self.arrConversation.removeAll()
//        //self.tvChatList.reloadData()
//        self.fetchConversations()
//        self.refreshControl.endRefreshing()
//    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tvChatList.delegate = self
        self.tvChatList.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        self.tvChatList.register(UINib(nibName: "ChatListTVCell", bundle: nil), forCellReuseIdentifier: "ChatListTVCell")
        
        //self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.hideLoading()
        
        super.viewWillAppear(animated)
        if self.isFromPlayerCard {
            if self.playerTabVC!().selectedIndex == 1 {
                self.playerTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.playerTabVC!().cvPlayerTabs.frame.origin.y),animate: true)
            }
        }
        
        if self.isBackFromMessage || self.isFromPlayerCard {
            print("Call from view will appear")
            self.isBackFromMessage = false
            self.isFetchingMore = false
            self.isNewMessage = true
            self.isLoadMore = false
            self.reloadMessagesOnResume()
        }
        else {
            print("No reload while open...")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("Navigation Controller:", self.navigationController ?? "❌ Not inside a Navigation Controller")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CometChat.removeMessageListener("chatListListener")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //CometChat.removeMessageListener("chatListListener")
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
        self.setupUI()
    }
    
    // MARK: - IB Actions
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
    }
    
}

// For Comet Chat
extension ChatVC: CometChatMessageDelegate, CometChatGroupDelegate {
    
    func setupUI() {
        self.isBackFromMessage = false
        self.isFetchingMore = false
        self.isNewMessage = true
        self.isLoadMore = false
        
        self.setupConversationRequest()
        //self.arrConversation.removeAll()
        
        self.showLoading()
        self.fetchConversations()
        self.addMessageListener()
    }
    
    // MARK: - Setup
    func getChatUnreadCount() {
        DispatchQueue.main.async {
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
    
    func setupConversationRequest() {
        conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: self.maxConversationLimit).build()
    }
    
    func setupSearchConversationRequest(searchText: String) {
        conversationRequest = ConversationRequest
            .ConversationRequestBuilder(limit: self.maxConversationLimit)
            .set(searchKeyword: searchText)
            .build()
        
        self.isFetchingMore = false
        self.isLoadMore = false
        
        self.fetchConversations()
    }
    
    func ReloadChatListVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupConversationRequest()
            self.arrConversation.removeAll()
            self.fetchConversations()
            self.addMessageListener()
        }
    }
    
    func fetchConversations() {
        guard !isFetchingMore else {
            print("fetchConversations -- skipped, already fetching")
            DispatchQueue.main.async {
                self.hideLoading()
            }
            return
        }
        self.isFetchingMore = true
        
        if !Network.reachability.isReachable {
            DispatchQueue.main.async {
                self.hideLoading()
            }
            print("No Internet connection detected")
            self.isRetryInternet { isRetry in
                if isRetry == true {
                    print("Retrying after no internet")
                }
            }
            return
        }
        
        print("fetchConversations -- initiated")
        print("conversationRequest is nil? \(conversationRequest == nil)")
        
        conversationRequest?.fetchNext(onSuccess: { conversations in
            print("fetchNext -- onSuccess triggered")
            defer { self.isFetchingMore = false }
            
            if conversations.isEmpty {
                print("fetchNext -- conversations empty")
                if self.arrConversation.isEmpty {
                    self.showNoConversationsLabel()
                }
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.isLoadMore = false
                }
                return
            }
            
            print("fetchConversations -- call -- success")
            
            if self.isNewMessage {
                print("Clearing old conversations")
                self.arrConversation.removeAll()
            }
            print("Appending \(conversations.count) new conversations")
            self.arrConversation.append(contentsOf: conversations)
            
            if self.arrConversation.count > 0 {
                self.removeNoDataLabels()
            }
            
            self.isLoadMore = false
            if conversations.count >= self.maxConversationLimit {
                self.isLoadMore = true
            }
            
            DispatchQueue.main.async {
                print("Reloading table view with \(self.arrConversation.count) conversations")
                self.tvChatList.reloadData()
                self.hideLoading()
                self.getChatUnreadCount()
            }
            
        }, onError: { error in
            print("fetchNext -- onError triggered: \(String(describing: error?.errorDescription))")
            defer { self.isFetchingMore = false }
            DispatchQueue.main.async {
                self.hideLoading()
            }
            self.showNoConversationsLabel()
            if (error?.errorCode ?? "") == "ERROR_USER_NOT_LOGGED_IN" {
                self.removeNoDataLabels()
                //self.showNoConversationsLabel(msg: "User not register with chat.")
                self.showNoConversationsLabel(msg: "CometChat login failed. Messaging features will be unavailable, but the rest of the application is unaffected.")
            }
            else if (error?.errorCode ?? "") == "AUTH_ERR_AUTH_TOKEN_NOT_FOUND" {
                print("Get error from CometChat auth token --> AUTH_ERR_AUTH_TOKEN_NOT_FOUND")
                self.cometChatUnregisterPushToken()
            }
            else if (error?.errorCode ?? "") == "ERR_CONVERSATION_SEARCH_RESTRICTION" {
                print("Get error --> \(error?.errorDescription ?? "")")
                Utilities.showPopup(title: (error?.errorDescription ?? ""), type: .warning)
                self.removeNoDataLabels()
            }
        })
        
        // Safety timeout if fetchNext never calls back
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            if self.isFetchingMore {
                print("fetchNext timeout — no response in 10s")
                self.isFetchingMore = false
                self.hideLoading()
                if self.arrConversation.isEmpty {
                    self.reloadMessagesOnResume()
                }
            }
        }
    }
    
    func fetchNextConversations() {
        guard !isFetchingMore else {
            print("fetchConversations -- skipped, already fetching")
            DispatchQueue.main.async {
                self.hideLoading()
            }
            return
        }
        isFetchingMore = true
        
        if !Network.reachability.isReachable {
            DispatchQueue.main.async {
                self.hideLoading()
            }
            print("No Internet connection detected")
            self.isRetryInternet { isRetry in
                if isRetry == true {
                    print("Retrying after no internet")
                }
            }
            return
        }
        
        print("fetchConversations -- initiated")
        print("conversationRequest is nil? \(conversationRequest == nil)")
        
        conversationRequest?.fetchNext(onSuccess: { conversations in
            print("fetchNext -- onSuccess triggered")
            defer { self.isFetchingMore = false }
            
            if conversations.isEmpty {
                print("fetchNext -- conversations empty")
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.isLoadMore = false
                }
                return
            }
            print("fetchConversations -- call -- success")
            
            print("Appending \(conversations.count) new conversations")
            self.arrConversation.append(contentsOf: conversations)
            
            self.isLoadMore = false
            if conversations.count >= self.maxConversationLimit {
                self.isLoadMore = true
            }
            
            DispatchQueue.main.async {
                print("Reloading table view with \(self.arrConversation.count) conversations")
                self.tvChatList.reloadData()
                self.hideLoading()
                self.getChatUnreadCount()
            }
            
        }, onError: { error in
            defer { self.isFetchingMore = false }
            DispatchQueue.main.async {
                self.hideLoading()
            }
        })
        
        // Safety timeout if fetchNext never calls back
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            if self.isFetchingMore {
                print("fetchNext timeout — no response in 10s")
                self.isFetchingMore = false
                self.hideLoading()
                if self.arrConversation.isEmpty {
                    //self.reloadMessagesOnResume()
                }
            }
        }
    }
    
    func addMessageListener() {
        //CometChat.removeMessageListener("chatListListener")
        CometChat.addMessageListener("chatListListener", self)
        CometChat.addGroupListener("groupChatListListener", self)
    }
    
    // MARK: - Message Delegate Methods
    
    @objc func refreshConversations(for message: BaseMessage? = nil) {
        guard let message = message else {
            // fallback to full reload if no specific message provided
            self.setupConversationRequest()
            //self.arrConversation.removeAll()
            self.fetchConversations()
            print("Else part.")
            return
        }

        // Fetch updated conversation for the given message's conversationId
        let conversationType: CometChat.ConversationType = (message.receiverType == .user ? .user : .group)
        
        CometChat.getConversation(conversationWith: self.strReceiverId, conversationType: conversationType, onSuccess: { [weak self] (updatedConversation) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Remove old conversation if it exists
                if let index = self.arrConversation.firstIndex(where: { $0.conversationId == updatedConversation?.conversationId }) {
                    self.arrConversation.remove(at: index)
                    self.tvChatList.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }

                // Insert updated conversation at top
                if let updated = updatedConversation {
                    self.arrConversation.insert(updated, at: 0)
                    self.tvChatList.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                
                self.getChatUnreadCount()
            }
        }, onError: { error in
            print("Error fetching updated conversation:", error?.errorDescription ?? "")
        })
    }
    
    func onTextMessageReceived(textMessage: TextMessage) {
        print("Text message received: \(textMessage.text)")
        print("Text message received: \(textMessage.senderUid)")
        print("Text message received: \(textMessage.conversationId)")
        
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: textMessage)
    }
    
    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        print("Media message received")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: mediaMessage)
    }
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        print("onGroupMemberJoined >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        print("onGroupMemberLeft >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        print("onGroupMemberKicked >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.findConectionWith(for: action)
    }
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        print("onGroupMemberBanned >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        print("onGroupMemberUnbanned >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        print("onGroupMemberScopeChanged >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy addedby: CometChatSDK.User, addedUser userAdded: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        print("onMemberAddedToGroup >>>> ", action.message ?? "")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: action)
    }
    
    func onCustomMessageReceived(customMessage: CustomMessage) {
        print("Custom message received")
        self.isNewMessage = true
        self.isLoadMore = false
        self.findConectionWith(for: customMessage)
    }
    
    func findConectionWith(for message: BaseMessage?) {
        self.strReceiverId = message?.senderUid ?? ""
        if message?.receiverType == .group {
            self.strReceiverId = (message?.conversationId ?? "").replacingOccurrences(of: "group_", with: "")
        }
        //self.refreshConversations(for: message)
        self.refreshConversations()
    }
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    func showNoConversationsLabel(msg: String = "Start chatting now!\nConnect with friends, teammates, or organizers.") {
        DispatchQueue.main.async {
            let noDataLabel = UILabel()
            //noDataLabel.text = msg
            noDataLabel.attributedText = Utilities.attributedTextWithImage(text: msg, image: UIImage(named: "") ?? UIImage())
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .gray
            noDataLabel.numberOfLines = 0
            noDataLabel.font = UIFont.systemFont(ofSize: 16)
            noDataLabel.translatesAutoresizingMaskIntoConstraints = false
            noDataLabel.tag = 990
            
            self.view.addSubview(noDataLabel)
            
            NSLayoutConstraint.activate([
                noDataLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                noDataLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                noDataLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
            ])
        }
    }
    
    func removeNoDataLabels() {
        DispatchQueue.main.async {
            for subview in self.view.subviews {
                if let label = subview as? UILabel, label.text?.contains("Start chatting now") == true {
                    label.removeFromSuperview()
                }
                else if let label = subview as? UILabel, label.text?.contains("User not register") == true {
                    label.removeFromSuperview()
                }
            }
        }
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrConversation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListTVCell", for: indexPath) as! ChatListTVCell
        let conversation = self.arrConversation[indexPath.row]
        var isGroup: Bool = false
        
        if let user = conversation.conversationWith as? CometChatSDK.User {
            cell.configure(user.name ?? "", user.avatar ?? "", "text", isGroup: false)
            print(user.name ?? "")
            print(conversation.conversationId ?? "")
            isGroup = false
        }
        else if let group = conversation.conversationWith as? CometChatSDK.Group {
            cell.configure(group.name ?? "", group.icon ?? "", "text", isGroup: true)
            print(group.name ?? "")
            print(conversation.conversationId ?? "")
            isGroup = true
        }
        
        // Last msg date and time
        cell.lblMsgDateTime.text = ""
        if let lastMessage = conversation.lastMessage {
            let timestamp = lastMessage.sentAt
            cell.lblMsgDateTime.text = Utilities.convertTimestampToLastMsgDateTimeString(timestamp: "\(timestamp)")
        }
        
        if let lastMessage = conversation.lastMessage as? TextMessage {
            
            CometChat.markAsDelivered(baseMessage : lastMessage, onSuccess: {
                print("markAsDelivered Succces")
            }, onError: {(error) in
                print("markAsDelivered error message",error?.errorDescription)
            })
            
            let name = NSAttributedString(string: (APIManager.sharedManager.strChatUserId == (lastMessage.senderUid)) ? "You: " : "\(lastMessage.sender!.name ?? ""): ")
            
            let msg = NSAttributedString(string: lastMessage.text)
            
            var isReplyMsg: Bool = false
            if lastMessage.parentMessageId > 0 {
                isReplyMsg = true
            }
            
            cell.lblLastMsg.text = lastMessage.text
            
            if isGroup {
                let msg1 = NSAttributedString(string: lastMessage.text)
                let combined = NSMutableAttributedString()
                combined.append(name)
                combined.append(msg1)
                cell.lblLastMsg.attributedText = combined
            }
            
            if isReplyMsg {
                let replyMsg = Utilities.attributedTextWithImage(
                    text: lastMessage.text,
                    image: UIImage(named: "replyLtoR") ?? UIImage(),
                    imageSize: CGSize(width: 16, height: 16),
                    imagePosition: .left,
                    imageColor: Colors.theme.returnColor(),
                    textStyle: .regular)
                
                cell.lblLastMsg.attributedText = replyMsg
                
                if isGroup {
                    let combined = NSMutableAttributedString()
                    combined.append(name)
                    combined.append(replyMsg)
                    cell.lblLastMsg.attributedText = combined
                }
            }
            
            if lastMessage.deletedAt > 0 {
                cell.lblLastMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banBlack") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
            }
        }
        else if let mediaMessage = conversation.lastMessage as? MediaMessage {
            
            CometChat.markAsDelivered(baseMessage : mediaMessage, onSuccess: {
                print("markAsDelivered Succces")
            }, onError: {(error) in
                print("markAsDelivered error message",error?.errorDescription)
            })
            
            let name = NSAttributedString(string: (APIManager.sharedManager.strChatUserId == (mediaMessage.senderUid)) ? "You: " : "\(mediaMessage.sender!.name ?? ""): ")
            
            var isReplyMsg: Bool = false
            if mediaMessage.parentMessageId > 0 {
                isReplyMsg = true
            }
            
            var msg = ""
            if mediaMessage.messageType == .image {
                msg = "Image"
            }
            else if mediaMessage.messageType == .file {
                msg = "Document"
            }
            
            cell.lblLastMsg.text = msg
            if isGroup {
                let msg1 = NSAttributedString(string: msg)
                let combined = NSMutableAttributedString()
                combined.append(name)
                combined.append(msg1)
                cell.lblLastMsg.attributedText = combined
            }
            
            if isReplyMsg {
                let replyMsg = Utilities.attributedTextWithImage(
                    text: msg,
                    image: UIImage(named: "replyLtoR") ?? UIImage(),
                    imageSize: CGSize(width: 16, height: 16),
                    imagePosition: .left,
                    imageColor: Colors.theme.returnColor(),
                    textStyle: .regular)
                
                cell.lblLastMsg.attributedText = replyMsg
                
                if isGroup {
                    let combined = NSMutableAttributedString()
                    combined.append(name)
                    combined.append(replyMsg)
                    cell.lblLastMsg.attributedText = combined
                }
            }
            
            if mediaMessage.deletedAt > 0 {
                cell.lblLastMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banBlack") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
            }
        }
        else if let actionMessage = conversation.lastMessage as? ActionMessage {
            cell.lblLastMsg.text = actionMessage.message ?? ""
        }
        else {
            cell.lblLastMsg.text = "Start your conversation."
        }
        
        let unreadCount = conversation.unreadMessageCount
        print("Unread message count -- \(conversation.unreadMessageCount)")
        // You can use this to show a badge or highlight the conversation
        if unreadCount > 0 {
            cell.lblUnreadMsgCount.text = "\(unreadCount)"
            cell.lblUnreadMsgCount.isHidden = false
        } else {
            cell.lblUnreadMsgCount.isHidden = true
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let conversation = self.arrConversation[indexPath.row]
        
        let messagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatMessageVC") as! ChatMessageVC
        
        messagesVC.objConversation = conversation
        messagesVC.senderId = APIManager.sharedManager.strChatUserId
        messagesVC.receiverId = (conversation.conversationWith as? CometChatSDK.User)?.uid ?? ""
        //(conversation.conversationWith as? CometChatSDK.User)?.tags
        
        messagesVC.shouldAutoScroll = true
        messagesVC.delegate = self
        messagesVC.tusslyTabVC = self.tusslyTabVC
        messagesVC.isFromPlayerCard = self.isFromPlayerCard
        messagesVC.isPlayerCardChatTap = self.isPlayerCardChatTap
        
        self.isFetchingMore = false
        self.isBackFromMessage = true
        self.navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        if offsetY > contentHeight - frameHeight - 100 {
            if self.isLoadMore {
                self.isLoadMore = false
                self.isFetchingMore = false
                //fetchConversations()
                self.fetchNextConversations()
            }
        }
    }
}

extension ChatVC {
    func cometChatUnregisterPushToken() {
        self.showLoading()
        CometChatNotifications.unregisterPushToken { success in
            print("unregisterPushToken: \(success)")
            self.cometChatLogout()
        } onError: { error in
            print("unregisterPushToken: \(error.errorCode) \(error.errorDescription)")
            self.cometChatLogout()
        }
    }
    
    func cometChatLogout(count: Int = 1)  {
        print("Logout tapped...")
        if CometChat.getLoggedInUser() != nil {
            CometChat.logout { Response in
                print("CometChat Logout successful.")
                self.cometChatLogin(count: 1)
            } onError: { (error) in
                print("CometChat Logout failed with error: " + error.errorDescription);
                let temp = count + 1
                if temp < 3 {
                    self.cometChatLogin(count: 1)
                }
                else {
                    Utilities.showPopup(title: "Chat service is temporarily unavailable.", type: .error)
                    self.cometChatLogin(count: 1)
                }
            }
        }
        else {
            self.cometChatLogin(count: 1)
        }
    }
    
    func cometChatLogin(count: Int = 1)  {
        CometChat.login(UID: APIManager.sharedManager.strChatUserId, authKey: CometAppConstants.AUTH_KEY, onSuccess: { (user) in
            print("CometChat Login successful : " + user.stringValue())
            
            self.hideLoading()
            self.setupUI()
            
            let fcmToken = UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any
            CometChatNotifications.registerPushToken(pushToken: fcmToken as! String, platform: CometChatNotifications.PushPlatforms.FCM_IOS, providerId: CometAppConstants.PROVIDER_ID, onSuccess: { (success) in
              print("Comet chat register PushToken: \(success)")
            }) { (error) in
              print("Comet chat register PushToken: \(error.errorCode) \(error.errorDescription)")
            }
            
        }) { (error) in
            print("CometChat Login failed with error: " + error.errorDescription);
            let temp = count + 1
            if temp < 3 {
                self.cometChatLogin(count: temp)
            }
            else {
                //Utilities.showPopup(title: "Chat service is temporarily unavailable.", type: .error)
                self.hideLoading()
                print("Login Error --> \(error.errorCode)")
                print("Login Error --> \(error.errorDescription)")
            }
        }
    }
}

extension ChatVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        if !((searchBar.text)!.lowercased()).isEmpty {
            print((searchBar.text)!.lowercased())
            
            self.setupSearchConversationRequest(searchText: (searchBar.text)!.lowercased())
        }
        else {
            self.setupConversationRequest()
            self.fetchConversations()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText != "" {
//            self.tempValue = self.value.filter {
//                ($0.lowercased()).contains(searchText.lowercased())
//            }
            print(searchText.lowercased())
        }
        else {
            self.searchBar.text = ""
            print("No Search Data...")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
        self.searchBar.text = ""
        print("Cancel Button Clicked...")
        
        self.setupConversationRequest()
        self.fetchConversations()
    }
}
