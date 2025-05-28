//
//  EventInterestedVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventInterestedVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblEventName: UILabel!

    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewOptionsContainer: UIView!
    
    @IBOutlet weak var tvContent: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!

    
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    
    var selectedTabIndex = 0
    var userId = 0
    
    var followerCount = 0
    var followingCount = 0
    
    var lblUserText = ""
    
    var eventId: Int?
    var eventName: String?
    var status: String?
    var interestedCount: Int?
    var maybeCount: Int?

    var dictParams = Dictionary<String, Any>()
    var hasMoreInt = -1
    var pageNumberInt = 1
    var hasMoreMayBe = -1
    var pageNumberMayBe = 1
    
    var interested: [UserRequest]?
    var mayBe: [UserRequest]?
    
    var followUserParams = Dictionary<String, Any>()
    var indexToUpdate = -1
    
    var isFollowers: Bool = false
    var followers: [UserRequest]?
    var following: [UserRequest]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        if isFollowers {
            btnOptions[0].setTitle("Followers (\(followerCount))", for: .normal)
            btnOptions[1].setTitle("Followings (\(followingCount))", for: .normal)
            lblEventName.text = lblUserText
            dictParams = ["userId": userId]
        } else {
            btnOptions[0].setTitle("Interested (\(interestedCount!))", for: .normal)
            btnOptions[1].setTitle("Maybe (\(maybeCount!))", for: .normal)
            lblEventName.text = eventName
            dictParams = ["eventId": eventId!, "status": status!]
        }


        if status == "Interested" || status == "Followers" {
            onTapOptions(btnOptions[0])
        } else {
            onTapOptions(btnOptions[1])
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
            lbl.backgroundColor = UIColor.white
        }
    }
    
    func setupUI() {
        viewTopContainer.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomRight , .bottomLeft])
        viewTopContainer.layer.masksToBounds = false
        viewTopContainer.layer.shadowRadius = 3.0
        viewTopContainer.layer.shadowOpacity = 0.3
        viewTopContainer.layer.shadowColor = UIColor.gray.cgColor
        viewTopContainer.layer.shadowOffset = CGSize(width: 0 , height:3)
        
        self.viewOptionsContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: Colors.themeGreen.returnColor())
    }
    
    // MARK: - Button Click Events
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        if sender.tag == 0 {
            status = isFollowers ? "Followers" : "Interested"
            btnOptions[0].setTitleColor(UIColor.white, for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            if interested == nil && followers == nil {
                dictParams.updateValue(pageNumberInt, forKey: "page")
                if isFollowers {
                    dictParams.updateValue("Follower", forKey: "type")
                    getFollowUnfollowUserList()
                } else {
                    dictParams.updateValue(status!, forKey: "status")
                    getUsers()
                }
            } else {
                if !isFollowers {
                    if interested!.count > 0 {
                        tvContent.isHidden = false
                        viewEmptyData.isHidden = true
                    }else {
                        tvContent.isHidden = true
                        viewEmptyData.isHidden = false
                    }
                }else {
                    if followers!.count > 0 {
                        tvContent.isHidden = false
                        viewEmptyData.isHidden = true
                    }else {
                        tvContent.isHidden = true
                        viewEmptyData.isHidden = false
                    }
                }
                
                tvContent.reloadData()
            }
        } else {
            status = isFollowers ? "Following" : "May_be"
            btnOptions[1].setTitleColor(UIColor.white, for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            if mayBe == nil && following == nil {
                dictParams.updateValue(pageNumberMayBe, forKey: "page")
                if isFollowers {
                    dictParams.updateValue("Following", forKey: "type")
                    getFollowUnfollowUserList()
                } else {
                    dictParams.updateValue(status!, forKey: "status")
                    getUsers()
                }
            } else {
                if !isFollowers {
                    if mayBe!.count > 0 {
                        tvContent.isHidden = false
                        viewEmptyData.isHidden = true
                    }else {
                        tvContent.isHidden = true
                        viewEmptyData.isHidden = false
                    }
                }else {
                    if following!.count > 0 {
                        tvContent.isHidden = false
                        viewEmptyData.isHidden = true
                    }else {
                        tvContent.isHidden = true
                        viewEmptyData.isHidden = false
                    }
                }
                tvContent.reloadData()
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
    
    // MARK: - WebServices
    
    func getUsers() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getUsers()
                }
            }
            return
        }
        
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_INTERESTED_MAYBE_USER, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.status == "Interested" {
                    if self.interested != nil {
                        self.interested?.append(contentsOf: (response?.result?.userList)!)
                    } else {
                        self.interested = (response?.result?.userList)!
                    }
                    if self.interested!.count > 0 {
                        self.pageNumberInt += 1
                        self.hasMoreInt = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                } else {
                    if self.mayBe != nil {
                        self.mayBe?.append(contentsOf: (response?.result?.userList)!)
                    } else {
                        self.mayBe = (response?.result?.userList)!
                    }
                    if self.mayBe!.count > 0 {
                        self.pageNumberMayBe += 1
                        self.hasMoreMayBe = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func removeUser() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.followUnFollowUser()
                }
            }
            return
        }

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_USER, parameters: followUserParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                
                DispatchQueue.main.async {
                    self.followers?.remove(at: self.indexToUpdate)
                    self.tvContent.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func followUnFollowUser() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.followUnFollowUser()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: followUserParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                if self.status == "Following" {
                    self.following?.remove(at: self.indexToUpdate)
                    self.followingCount -= 1
                    DispatchQueue.main.async {
                        self.btnOptions[1].setTitle("Followings (\(self.followingCount))", for: .normal)
                    }
                } else if self.status == "Interested" {
                    self.interested![self.indexToUpdate].isFollowing = 1 - self.interested![self.indexToUpdate].isFollowing!
                } else {
                    self.mayBe![self.indexToUpdate].isFollowing = 1 - self.mayBe![self.indexToUpdate].isFollowing!
                }
                DispatchQueue.main.async {
                    self.tvContent.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getFollowUnfollowUserList() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFollowUnfollowUserList()
                }
            }
            return
        }
        
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FOLLOW_UNFOLLOW_USERS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.status == "Followers" {
                    if self.followers != nil {
                        self.followers?.append(contentsOf: (response?.result?.userList)!)
                    } else {
                        self.followers = (response?.result?.userList)!
                    }
                    if self.followers!.count > 0 {
                        self.pageNumberInt += 1
                        self.hasMoreInt = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                } else {
                    if self.following != nil {
                        self.following?.append(contentsOf: (response?.result?.userList)!)
                    } else {
                        self.following = (response?.result?.userList)!
                    }
                    
                    if self.following!.count > 0 {
                        self.pageNumberMayBe += 1
                        self.hasMoreMayBe = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension EventInterestedVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFollowers {
            return self.status == "Followers" ? followers!.count : following!.count
        } else {
            return self.status == "Interested" ? interested!.count : mayBe!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestCell", for: indexPath) as! FollowRequestCell
        
        var request: UserRequest?
        
        if isFollowers {
            request = self.status == "Followers" ? followers![indexPath.row] : following![indexPath.row]
            cell.widthBtnFollow.constant = 80
            cell.btnApprove.layer.borderWidth = 1.0
            
            if userId == APIManager.sharedManager.user?.id && self.status == "Followers" {
                if request?.id == APIManager.sharedManager.user?.id {
                    cell.btnApprove.isHidden = true
                    cell.widthBtnFollow.constant = 0
                }else {
                    cell.btnApprove.isHidden = false
                    cell.widthBtnFollow.constant = 80
                }
                
                cell.btnApprove.setTitle("Remove", for: .normal)
                cell.btnApprove.layer.borderColor = Colors.gray.returnColor().cgColor
                cell.btnApprove.backgroundColor = UIColor.clear
                cell.btnApprove.setTitleColor(Colors.gray.returnColor(), for: .normal)
            } else {
                if request?.id == APIManager.sharedManager.user?.id {
                    cell.btnApprove.isHidden = true
                    cell.widthBtnFollow.constant = 0
                }else {
                    cell.btnApprove.isHidden = false
                    cell.widthBtnFollow.constant = request?.isFollowing == 1 ? 80 : 62
                }
                
                cell.btnApprove.setTitle(request?.isFollowing == 1 ? "Following" : "Follow", for: .normal)
                cell.btnApprove.setTitleColor(request?.isFollowing == 1 ? UIColor.white : Colors.themeGreen.returnColor(), for: .normal)
                cell.btnApprove.backgroundColor = request?.isFollowing == 1 ? Colors.themeGreen.returnColor() : UIColor.clear
                
                cell.btnApprove.layer.borderColor = Colors.themeGreen.returnColor().cgColor
                cell.btnApprove.layer.borderWidth = 1.0
            }
        } else {
            request = self.status == "Interested" ? interested![indexPath.row] : mayBe![indexPath.row]
            
            
            if request?.id == APIManager.sharedManager.user?.id {
                cell.btnApprove.isHidden = true
                cell.widthBtnFollow.constant = 0
            }else {
                cell.btnApprove.isHidden = false
                cell.widthBtnFollow.constant = request?.isFollowing == 1 ? 80 : 62
            }
            
            cell.btnApprove.setTitle(request?.isFollowing == 1 ? "Following" : "Follow", for: .normal)
            cell.btnApprove.setTitleColor(request?.isFollowing == 1 ? UIColor.white : Colors.themeGreen.returnColor(), for: .normal)
            cell.btnApprove.backgroundColor = request?.isFollowing == 1 ? Colors.themeGreen.returnColor() : UIColor.clear
            
            cell.btnApprove.layer.borderColor = Colors.themeGreen.returnColor().cgColor
            cell.btnApprove.layer.borderWidth = 1.0
        }
        cell.btnApprove.addTarget(self, action: #selector(btnApproveTapped(_:)), for: .touchUpInside)

        cell.ivUser.setImage(imageUrl: request!.profilePic)
        cell.lblUserName.text = request?.name
        cell.lblUserType.text = request?.userName
        cell.btnApprove.tag = indexPath.row
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFollowers {
            if self.status == "Followers" {
                if indexPath.row == followers!.count - 1 {
                    if hasMoreInt == 1 {
                        getFollowUnfollowUserList()
                    }
                }
            } else {
                if indexPath.row == following!.count - 1 {
                    if hasMoreMayBe == 1 {
                        getFollowUnfollowUserList()
                    }
                }
            }
        } else {
            if self.status == "Interested" {
                if indexPath.row == interested!.count - 1 {
                    if hasMoreInt == 1 {
                        getUsers()
                    }
                }
            } else {
                if indexPath.row == mayBe!.count - 1 {
                    if hasMoreMayBe == 1 {
                        getUsers()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFollowers {
            let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            let request = self.status == "Followers" ? followers![indexPath.row] : following![indexPath.row]
            profileVC.userId = request.id
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
    }
    
    @objc func btnApproveTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        if isFollowers {
            let request = self.status == "Followers" ? followers![sender.tag] : following![sender.tag]
            if self.status == "Followers" {
                followUserParams.updateValue(request.requestId ?? 0, forKey: "requestId")
                removeUser()
            } else {
                followUserParams.updateValue(request.id, forKey: "toUserId")
                followUnFollowUser()
            }
        } else {
            let request = self.status == "Interested" ? interested![sender.tag] : mayBe![sender.tag]
            followUserParams.updateValue(request.id, forKey: "toUserId")
            followUnFollowUser()
        }
    }
    
}

