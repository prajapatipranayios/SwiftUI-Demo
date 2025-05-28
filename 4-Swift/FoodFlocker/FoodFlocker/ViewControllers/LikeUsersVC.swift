//
//  LikeUsersVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class LikeUsersVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var tvRequests: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!
    @IBOutlet weak var lblTitle: UILabel!

    var likeUsersList: [UserRequest]?
    var hasMore = -1
    var pageNumber = 1
    
    var indexToUpdate = -1
    
    var moduleId = -1
    var module = ""
    var likesCount = 0
    
    var followUserParams = Dictionary<String, Any>()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        getLikeUserList()
        
    }

    func setupUI() {
        self.lblTitle.text = "Likes (\(likesCount))"
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - WebServices
    
    func getLikeUserList() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLikeUserList()
                }
            }
            return
        }
        
        let params = ["page": pageNumber, "moduleId": moduleId, "module": module] as [String : Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LIKE_USERS_LIST, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.likeUsersList != nil {
                    self.likeUsersList?.append(contentsOf: (response?.result?.userList)!)
                } else {
                    self.likeUsersList = (response?.result?.userList)!
                }
                if self.likeUsersList!.count > 0 {
                    self.pageNumber += 1
                    self.hasMore = (response?.result?.hasMore)!
                    DispatchQueue.main.async {
                        self.viewEmptyData.isHidden = true
                        self.tvRequests.isHidden = false
                        self.tvRequests.dataSource = self
                        self.tvRequests.delegate = self
                        self.tvRequests.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tvRequests.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func followUser() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.followUser()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: followUserParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.likeUsersList![self.indexToUpdate].isFollowing = 1 - self.likeUsersList![self.indexToUpdate].isFollowing!
                    self.tvRequests.reloadRows(at: [IndexPath(row: self.indexToUpdate, section: 0)], with: .automatic)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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

extension LikeUsersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likeUsersList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestCell", for: indexPath) as! FollowRequestCell
        
        let request = likeUsersList![indexPath.row]
        
        cell.ivUser.setImage(imageUrl: request.profilePic)
        cell.lblUserName.text = request.name
        cell.lblUserType.text = request.userName
        
        cell.btnApprove.tag = indexPath.row
        cell.btnApprove.addTarget(self, action: #selector(btnApproveTapped(_:)), for: .touchUpInside)
        
        cell.btnApprove.layer.borderWidth = 1.0
        
        if request.id == APIManager.sharedManager.user?.id {
            cell.btnApprove.isHidden = true
            cell.widthBtnFollow.constant = 0.0
        }else if request.isFollowing == 1 {
            cell.widthBtnFollow.constant = 90
            if request.followingStatus == "Accepted" {
                cell.btnApprove.setTitle("Following", for: .normal)
                cell.btnApprove.backgroundColor = Colors.themeGreen.returnColor()
                cell.btnApprove.setTitleColor(UIColor.white, for: .normal)
                cell.btnApprove.layer.borderColor = Colors.themeGreen.returnColor().cgColor
                cell.btnApprove.isEnabled = true
            } else {
                cell.btnApprove.setTitle("Requested", for: .normal)
                cell.btnApprove.backgroundColor = UIColor.white
                cell.btnApprove.setTitleColor(UIColor.black, for: .normal)
                cell.btnApprove.layer.borderColor = UIColor.black.cgColor
                cell.btnApprove.isEnabled = false
            }
        } else {
            cell.btnApprove.isEnabled = true
            cell.widthBtnFollow.constant = 65
            cell.btnApprove.setTitle("Follow", for: .normal)
            cell.btnApprove.backgroundColor = UIColor.clear
            cell.btnApprove.setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            cell.btnApprove.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == likeUsersList!.count - 1 {
            if hasMore == 1 {
                getLikeUserList()
            }
        }
    }
    
    @objc func btnApproveTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        let request = likeUsersList![sender.tag]
        followUserParams.updateValue(request.id, forKey: "toUserId")
        followUser()
    }
}
