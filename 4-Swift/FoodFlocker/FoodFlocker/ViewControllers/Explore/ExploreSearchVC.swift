//
//  ExploreSearchVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ExploreSearchVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewTFBack: UIView!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tvResults: UITableView!
    
    @IBOutlet weak var viewEmptyData: UIView!

    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
       
    var selectedTabIndex = 0
    
    var hasMoreAcc = -1
    var pageNoAcc = 1
    
    var hasMoreTags = -1
    var pageNoTags = 1
    
    var userList: [UserRequest]?
    var tags: [Tag]?
    
    var indexToUpdate = -1
    
    var strSearch = ""
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        tfSearch.delegate = self
        onTapOptions(btnOptions[0])
        viewEmptyData.isHidden = true
        tvResults.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
        }
    }
    
    func setupUI() {
        viewTopContainer.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomRight , .bottomLeft])
        viewTopContainer.layer.masksToBounds = false
        viewTopContainer.layer.shadowRadius = 3.0
        viewTopContainer.layer.shadowOpacity = 0.3
        viewTopContainer.layer.shadowColor = UIColor.gray.cgColor
        viewTopContainer.layer.shadowOffset = CGSize(width: 0 , height:3)
        
        viewTFBack.layer.borderColor = UIColor.lightGray.cgColor
        viewTFBack.layer.borderWidth = 1.0
        viewTFBack.layer.cornerRadius = viewTFBack.frame.size.height / 2
        
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
        strSearch = ""
        tvResults.reloadData()
        viewEmptyData.isHidden = false
        tvResults.isHidden = true
        pageNoAcc = 1
        pageNoTags = 1
    }
    
    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            
            if tfSearch.text?.trimmedString != "" {
                self.userList?.removeAll()
                pageNoAcc = 1
                searchFoodFlocker()
            }
        } else {
            btnOptions[1].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            if tfSearch.text?.trimmedString != "" {
                self.tags?.removeAll()
                pageNoTags = 1
                
                searchFoodFlocker()
            }
        }
    }
    
    // MARK: - Webservices

    func searchFoodFlocker() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.searchFoodFlocker()
                }
            }
            return
        }
        
        let dictParams = ["type": selectedTabIndex == 0 ? "User" : "Tag", "page": selectedTabIndex == 0 ? pageNoAcc : pageNoTags, "search": strSearch] as [String : Any]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEARCH_FOOD_FLOCKER, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.selectedTabIndex == 0 {
                    if self.userList != nil {
                        self.userList?.append(contentsOf: (response?.result?.userList)!)
                    } else {
                        self.userList = (response?.result?.userList)!
                    }
                    if self.userList!.count > 0 {
                        self.pageNoAcc += 1
                        self.hasMoreAcc = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvResults.isHidden = false
                            self.tvResults.dataSource = self
                            self.tvResults.delegate = self
                            self.tvResults.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvResults.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                } else {
                    if self.tags != nil {
                        self.tags?.append(contentsOf: (response?.result?.tagList)!)
                    } else {
                        self.tags = (response?.result?.tagList)!
                    }
                    if self.tags!.count > 0 {
                        self.pageNoTags += 1
                        self.hasMoreTags = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvResults.isHidden = false
                            self.tvResults.dataSource = self
                            self.tvResults.delegate = self
                            self.tvResults.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvResults.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
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
        
        let params = ["toUserId": userList![indexToUpdate].id]
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                
                DispatchQueue.main.async {
//                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    self.userList![self.indexToUpdate].isFollowing = 1 - self.userList![self.indexToUpdate].isFollowing!
                    
//                    if let isFollow : Int = self.userList![self.indexToUpdate].isFollowing! {
//                        self.userList![self.indexToUpdate].isFollowing = 1 - isFollow
//                    }
                    
                    let value: String = (self.userList![self.indexToUpdate].isFollowing == 0) ? "" : ((self.userList![self.indexToUpdate].isFollowing == 1 && self.userList![self.indexToUpdate].accountType == "Private") ? "Pending" : "Following")
                    self.userList![self.indexToUpdate].followingStatus = value
                    
                    self.tvResults.reloadData()
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

extension ExploreSearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTabIndex == 0 {
            return self.userList!.count
        } else {
            return self.tags!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTabIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestCell", for: indexPath) as! FollowRequestCell
            let user = userList![indexPath.row]
            
            cell.ivUser.setImage(imageUrl: user.profilePic)
            cell.lblUserName.text = user.name
            cell.lblUserType.text = user.userName
            
            cell.widthBtnFollow.constant = user.isFollowing == 1 ? 80 : 62
            
            if user.id == APIManager.sharedManager.user?.id {
                cell.btnApprove.isHidden = true
                cell.widthBtnFollow.constant = 0.0
            }else {
                cell.btnApprove.setTitle((user.followingStatus)! == "" ? "Follow" : ((user.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                cell.btnApprove.layer.borderColor = (user.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((user.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                cell.btnApprove.setTitleColor((user.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((user.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                cell.btnApprove.backgroundColor = (user.followingStatus)! == "" ? UIColor.clear : ((user.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
            }
            
            cell.btnApprove.layer.borderWidth = 1.0
            
            cell.btnApprove.tag = indexPath.row
            cell.btnApprove.addTarget(self, action: #selector(btnFollowTapped(_:)), for: .touchUpInside)

            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(onTapUser(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagTVCell", for: indexPath) as! TagTVCell
            let tag = tags![indexPath.row]
            cell.lblTag.text = tag.tag

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTabIndex == 0 {
            if indexPath.row == userList!.count - 1 {
                if hasMoreAcc == 1 {
                    searchFoodFlocker()
                }
            }
        } else {
            if indexPath.row == tags!.count - 1 {
                if hasMoreTags == 1 {
                    searchFoodFlocker()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedTabIndex == 0 {
            
        } else {
            let tagDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "TagDetailsVC") as! TagDetailsVC
            let tag = tags![indexPath.row]
            tagDetailsVC.tagToSearch = tag.tag
            self.navigationController?.pushViewController(tagDetailsVC, animated: true)
        }
    }
    
    @objc func btnFollowTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        followUnFollowUser()
    }
    
    @objc func onTapUser(_ sender: UIButton) {
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.userId = userList![sender.tag].id
        self.view.ffTabVC.navigationController?.pushViewController(profileVC, animated: true)
    }
    
}

extension ExploreSearchVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        strSearch = newString as String

        if strSearch.trimmedString != "" {
            if !isSearching {
                isSearching = true
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    self.isSearching = false
                    self.userList?.removeAll()
                    self.tags?.removeAll()
                    self.pageNoAcc = 1
                    self.pageNoTags = 1
                    
                    self.tvResults.reloadData()
                    if self.strSearch.trimmedString != "" {
                        self.searchFoodFlocker()
                    }
                }
            }
            
        } else {
            if selectedTabIndex == 0 {
                userList?.removeAll()
            } else {
                tags?.removeAll()
            }
            
            tvResults.reloadData()
            viewEmptyData.isHidden = true
            tvResults.isHidden = true
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        userList?.removeAll()
//        tags?.removeAll()
//        pageNoAcc = 0
//        pageNoTags = 0
//        
//        if tfSearch.text != "" {
//            self.searchFoodFlocker()
//        }
    }
}
