//
//  ChatVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tvChats: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!

    var dictParams = ["timeZone": "+05:30"]
    
    var conversations = [Conversation]()
    var filteredConversations = [Conversation]()

    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tfSearch.delegate = self
        
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        getConversations()
    }

    func setupUI() {
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        
        tfSearch.layer.cornerRadius = tfSearch.frame.size.height / 2
        tfSearch.backgroundColor = Colors.light.returnColor()
        tfSearch.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tfSearch.frame.height))
        tfSearch.leftViewMode = .always
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tfSearch.frame.size.height - 10, height: tfSearch.frame.size.height))
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height))
        btn.clipsToBounds = true

        btn.setImage(UIImage(named: "Remove"), for: .normal)
        btn.addTarget(self, action: #selector(closeTFTapped), for: .touchUpInside)
        mainView.addSubview(btn)

        tfSearch.rightViewMode = .whileEditing
        tfSearch.rightView = mainView
    }
    
    @objc func closeTFTapped() {
        tfSearch.text = ""
        //arrAddresses.removeAll()
        //tvAddresses.reloadData()
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Webservices

    func getConversations() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getConversations()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_CONVERSATIONS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.conversations = (response?.result?.conversations)!
                    if self.conversations.count > 0 {
                        self.viewEmptyData.isHidden = true
                        self.tvChats.isHidden = false
                        self.tvChats.dataSource = self
                        self.tvChats.delegate = self
                        self.tvChats.reloadData()
                    } else {
                        self.viewEmptyData.isHidden = false
                        self.tvChats.isHidden = true
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.viewEmptyData.isHidden = false
                    self.tvChats.isHidden = true
                }
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

extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredConversations.count
        } else {
            return conversations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = isSearching ? filteredConversations[indexPath.row] : conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVCell", for: indexPath) as! ChatTVCell
        
        cell.ivProfile.setImage(imageUrl: conversation.profilePic)
        cell.lblUserName.text = conversation.name
        cell.lblDuration.text = conversation.RequestDate
        
        if conversation.unReadCount > 0 {
            cell.lblMsgCount.text = "\(conversation.unReadCount)"
            cell.lblMsgCount.isHidden = false
        }else {
            cell.lblMsgCount.text = ""
            cell.lblMsgCount.isHidden = true
        }
        
        if conversation.messageType == "MESSAGE" {
            cell.lblMessage.text = conversation.message.decodeEmoji
            cell.lblMessage.isHidden = false
            cell.viewPhoto.isHidden = true
        }else if conversation.messageType == "IMAGE" {
            cell.lblPhotoVideo.text = "Photo"
            cell.ivPhotoVideo.image = UIImage(named: "PhotoIcon")
            cell.lblMessage.isHidden = true
            cell.viewPhoto.isHidden = false
        }else {
            cell.lblPhotoVideo.text = "Video"
            cell.ivPhotoVideo.image = UIImage(named: "VideoIcon")
            cell.lblMessage.isHidden = true
            cell.viewPhoto.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            filteredConversations[indexPath.row].unReadCount = 0
        }else {
            conversations[indexPath.row].unReadCount = 0
        }
        
        tvChats.reloadData()
        
        let conversation = isSearching ? filteredConversations[indexPath.row] : conversations[indexPath.row]
        let conversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationVC
        conversationVC?.userId = conversation.userId
        conversationVC?.profilePic = conversation.profilePic
        conversationVC?.userName = conversation.name
        conversationVC?.conversationId = conversation.identifier
        
        self.navigationController?.pushViewController(conversationVC!, animated: true)
    }
}

extension ChatVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString != "" {
            isSearching = true
            self.applyFilter(string: newString as String)
        } else {
            isSearching = false
            if conversations.count > 0 {
                tvChats.isHidden =  false
                viewEmptyData.isHidden = true
            }
            tvChats.reloadData()
        }
        return true
    }
    
    func applyFilter(string: String) {
        filteredConversations = conversations.filter({
            $0.userName.contains(string)
        })
        if filteredConversations.count > 0 {
            tvChats.isHidden = false
            self.viewEmptyData.isHidden = true
        } else {
            tvChats.isHidden = true
            self.viewEmptyData.isHidden = false
        }
        tvChats.reloadData()
    }
}
