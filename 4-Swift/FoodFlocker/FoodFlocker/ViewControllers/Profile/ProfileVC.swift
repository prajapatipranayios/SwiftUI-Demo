//
//  ProfileVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnChat: UIButton!

    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var widthBtnBack: NSLayoutConstraint!

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var viewRatings: UIView!
    @IBOutlet weak var lblRatings: UILabel!

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var lblContactNo: UILabel!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblUserLink: UILabel!
    
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    @IBOutlet weak var lblEventsCount: UILabel!

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewBackContainer: UIView!
    
    @IBOutlet weak var viewEmptyData: UIView!

    @IBOutlet weak var viewPrivateAccount: UIView!
    @IBOutlet weak var lblPrivateMessage: UILabel!

    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    
    @IBOutlet weak var tvPostReviews: UITableView!
    @IBOutlet weak var cvMedias: UICollectionView!
    
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var heightOfReadmore: NSLayoutConstraint!
    @IBOutlet weak var heightOfAbout: NSLayoutConstraint!

    var isLabelAtMaxHeight = false
    
    var selectedTab = 0
    
    var pageNoPosts = 1
    var hasMorePosts = -1
    var isGoToOtherPage = false

    var postList: [PostEventDetail]?
    
    var pageNoMedias = 1
    var hasMoreMedias = -1

    var mediasList: [Media]?
    
    var pageNoReviews = 1
    var hasMoreReviews = -1
    var reviewList: [UserReview]?
    
    var userId: Int?
    var anotherUserDetails: User?
    var indexToUpdate = -1
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
    .font: Fonts.Regular.returnFont(size: 14.0),
    .foregroundColor: Colors.themeGreen.returnColor(),
    .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        layoutCells()
        DispatchQueue.main.async {
            self.setupUI()
        }
        tvPostReviews.register(UINib(nibName: "PostTVCell", bundle: nil), forCellReuseIdentifier: "PostTVCell")
        tvPostReviews.register(UINib(nibName: "ReviewTVCell", bundle: nil), forCellReuseIdentifier: "ReviewTVCell")
        tvPostReviews.estimatedRowHeight = 150.0//139.0
        tvPostReviews.rowHeight = UITableView.automaticDimension
        
        cvMedias.isHidden = true
        tvPostReviews.isHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isGoToOtherPage {
            isGoToOtherPage = false
        }else {
            getAnotherUserDetails(userId: (userId != nil ? userId : APIManager.sharedManager.user?.id)!)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
        }
    }

    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layout.itemSize = CGSize(width: (cvMedias.frame.size.width - 16)/3, height: (cvMedias.frame.size.width - 16)/3)
        layout.scrollDirection = .vertical
        self.cvMedias.setCollectionViewLayout(layout, animated: true)
    }
    
    func setupUI() {
        
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft, .bottomRight], radius: 20.0, bgColor: UIColor.white)
        
        viewContainer.roundCorners(corners: [.topLeft,.topRight], radius: 20.0)
        viewBackContainer.addShadow(offset: CGSize(width: 2.0, height: 1.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
         
        ivUser.layer.cornerRadius = ivUser.frame.size.width / 2
        ivUser.clipsToBounds = true
        
        viewRatings.layer.cornerRadius = viewRatings.frame.size.width / 2
        viewRatings.clipsToBounds = true

        btnOptions[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
        lblDots[0].isHidden = false
        lblDots[1].isHidden = true
        lblDots[2].isHidden = true

        btnEditProfile.setTitle("Edit Profile", for: .normal)
        btnEditProfile.layer.cornerRadius = btnEditProfile.frame.size.height / 2
        btnEditProfile.layer.borderColor = Colors.gray.returnColor().cgColor
        btnEditProfile.layer.borderWidth = 1.0
        btnEditProfile.setTitleColor(Colors.gray.returnColor(), for: .normal)
        btnEditProfile.backgroundColor = UIColor.clear
        
        viewPrivateAccount.isHidden = true
        viewEmptyData.isHidden = true
        
//        btnReadMore.isHidden = true
        
    }
    
    func setupUserDetails() {
        
        lblUserName.text = anotherUserDetails?.userName
        lblName.text = anotherUserDetails?.name
        
        lblUserType.text = anotherUserDetails?.userType == "Business" ? "\(anotherUserDetails?.userType ?? "") - ABN \(anotherUserDetails?.ABN ?? "")" :  anotherUserDetails?.userType
        lblContactNo.text = "\(anotherUserDetails?.countryCode ?? "") \(anotherUserDetails?.mobileNumber ?? "")"
        
        ivUser.setImage(imageUrl: anotherUserDetails!.profilePic)
        lblRatings.text = "\((anotherUserDetails?.rating)!)"
        
        lblAbout.text = anotherUserDetails?.aboutMe
        
        
//        lblUserLink.text = anotherUserDetails?.website
        lblUserLink.attributedText = NSAttributedString(string: anotherUserDetails?.website ?? "", attributes:
        [.underlineStyle: NSUnderlineStyle.single.rawValue])

        lblFollowersCount.text = "\((anotherUserDetails?.followersCount)!)"
        lblFollowingCount.text = "\((anotherUserDetails?.followingCount)!)"
        lblEventsCount.text = "\(anotherUserDetails?.eventCount ?? 0)"
        btnOptions[2].setTitle(anotherUserDetails?.reviewCount ?? 0 == 0 ? "Reviews" :  "Reviews(\(anotherUserDetails?.reviewCount ?? 0))", for: .normal)
        
        if anotherUserDetails?.id != APIManager.sharedManager.user?.id {
            
            btnEditProfile.isHidden = false
            btnSettings.isHidden = true
            btnChat.isHidden = true
            widthBtnBack.constant = 50
            btnBack.isHidden = false
            
            btnEditProfile.setTitle((anotherUserDetails?.followingStatus)! == "" ? "Follow" : ((anotherUserDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
            btnEditProfile.layer.borderColor = (anotherUserDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((anotherUserDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
            btnEditProfile.setTitleColor((anotherUserDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((anotherUserDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
            btnEditProfile.backgroundColor = (anotherUserDetails?.followingStatus)! == "" ? UIColor.clear : ((anotherUserDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
            
        } else {
            
            btnEditProfile.setTitle("Edit Profile", for: .normal)
            btnEditProfile.layer.borderColor = Colors.gray.returnColor().cgColor
            btnEditProfile.setTitleColor(Colors.gray.returnColor(), for: .normal)
            btnEditProfile.backgroundColor = UIColor.clear
                        
            widthBtnBack.constant = 16
            btnBack.isHidden = true
            
            btnSettings.isHidden = false
            btnChat.isHidden = false
            
            btnEditProfile.isHidden = false
            
            viewPrivateAccount.isHidden = true
            
        }
        
        onTapOptions(btnOptions[selectedTab])
        
        let attributeString = NSMutableAttributedString(string: "read more",
                                                        attributes: yourAttributes)
        btnReadMore.setAttributedTitle(attributeString, for: .normal)
        
        if Utilities.getLabelHeight(text: (anotherUserDetails?.aboutMe)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 14.0)) > 60.0 {
            btnReadMore.isHidden = false
            heightOfAbout.constant = 60.0
            heightOfReadmore.constant = 20.0
        }else {
            btnReadMore.isHidden = true
            heightOfAbout.constant = Utilities.getLabelHeight(text: (anotherUserDetails?.aboutMe)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 14.0))
            heightOfReadmore.constant = 0.0
        }
        
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onTapReadMore(_ sender: Any) {
        if isLabelAtMaxHeight {
            let attributeString = NSMutableAttributedString(string: "read more",
                                                            attributes: yourAttributes)
            btnReadMore.setAttributedTitle(attributeString, for: .normal)
            isLabelAtMaxHeight = false
            heightOfAbout.constant = 60.0
        }
        else {
            let attributeString = NSMutableAttributedString(string: "read less",
                                                            attributes: yourAttributes)
            btnReadMore.setAttributedTitle(attributeString, for: .normal)
            isLabelAtMaxHeight = true
            heightOfAbout.constant = Utilities.getLabelHeight(text: (anotherUserDetails?.aboutMe)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 14.0))
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedTab = sender.tag
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[1].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            btnOptions[2].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            lblDots[2].isHidden = true
            
            if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
                self.cvMedias.isHidden = true
                self.tvPostReviews.isHidden = false
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = true
                self.postList?.removeAll()
                self.tvPostReviews.reloadData()
                self.pageNoPosts = 1
                self.hasMorePosts = -1

                getPosts()
            }else {
                self.cvMedias.isHidden = true
                self.tvPostReviews.isHidden = true
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = false
                self.lblPrivateMessage.text = "This Account is Private.\nFollow this Account to See their posts"
            }
            
        } else if sender.tag == 1 {
            btnOptions[0].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            btnOptions[1].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[2].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            lblDots[2].isHidden = true
            
            if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
                self.cvMedias.isHidden = false
                self.tvPostReviews.isHidden = true
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = true
                self.mediasList?.removeAll()
                self.cvMedias.reloadData()
                self.pageNoMedias = 1
                self.hasMoreMedias = -1
                getMedias()
            }else {
                self.cvMedias.isHidden = true
                self.tvPostReviews.isHidden = true
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = false
                self.lblPrivateMessage.text = "This Account is Private.\nFollow this Account to See their media"
            }
//            }
        } else {
            btnOptions[0].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            btnOptions[1].setTitleColor(Colors.lightGray.returnColor(), for: .normal)
            btnOptions[2].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = true
            lblDots[2].isHidden = false
//            if reviewList == nil {
//                getUsersReview()
            
            if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
                self.cvMedias.isHidden = true
                self.tvPostReviews.isHidden = false
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = true
                self.reviewList?.removeAll()
                self.tvPostReviews.reloadData()
                self.pageNoReviews = 1
                self.hasMoreReviews = -1

                getUsersReview()
            }else {
                self.cvMedias.isHidden = true
                self.tvPostReviews.isHidden = true
                self.viewEmptyData.isHidden = true
                self.viewPrivateAccount.isHidden = false
                self.lblPrivateMessage.text = "This Account is Private.\nFollow this Account to See their review"
            }
            
        }
    }
    
    @IBAction func onTapEditProfile(_ sender: UIButton) {
        if anotherUserDetails?.id != APIManager.sharedManager.user?.id {
            followUser(toUserId: anotherUserDetails?.id ?? 0, isComeFromReview: false)
        }else {
            isGoToOtherPage = true
            let editProfVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            self.view.ffTabVC.navigationController?.pushViewController(editProfVC, animated: true)
        }
    }
    
    @IBAction func onTapChat(_ sender: UIButton) {
        isGoToOtherPage = true
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        self.view.ffTabVC.navigationController?.pushViewController(chatVC!, animated: true)
    }
    
    @IBAction func onTapWebsite(_ sender: UIButton) {

        if (anotherUserDetails?.website.lowercased().contains("https://".lowercased()))! || (anotherUserDetails?.website.lowercased().contains("http://".lowercased()))!{
            if let url = URL(string: "\(anotherUserDetails?.website ?? "")") {
                UIApplication.shared.open(url)
            }
        }else{
            
            if let url = URL(string: "http://\(anotherUserDetails?.website ?? "")") {
                UIApplication.shared.open(url)
//                if UIApplication.shared.canOpenURL(url) {
//
//                }else {
//                    UIApplication.shared.open(URL(string: "http://\(anotherUserDetails?.website ?? "")")!)
//                }
            }
        }
    }
    
    @IBAction func onTapSettings(_ sender: UIButton) {
        isGoToOtherPage = true
        let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsVC
        
        self.view.ffTabVC.navigationController?.pushViewController(settingsVC!, animated: true)
    }
    
    @IBAction func onTapFollowers(_ sender: UIButton) {
        isGoToOtherPage = true
        if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
            let intVC = self.storyboard?.instantiateViewController(withIdentifier: "EventInterestedVC") as? EventInterestedVC
            intVC?.userId = anotherUserDetails?.id ?? 0
            intVC?.followerCount = anotherUserDetails?.followersCount ?? 0
            intVC?.followingCount = anotherUserDetails?.followingCount ?? 0
            intVC?.lblUserText = self.lblUserName.text!
            intVC?.isFollowers = true
            intVC?.status = "Followers"
            
            self.view.ffTabVC.navigationController?.pushViewController(intVC!, animated: true)
            
        }
    }

    @IBAction func onTapFollowing(_ sender: UIButton) {
        isGoToOtherPage = true
        if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
            let intVC = self.storyboard?.instantiateViewController(withIdentifier: "EventInterestedVC") as? EventInterestedVC
            intVC?.userId = anotherUserDetails?.id ?? 0
            intVC?.followerCount = anotherUserDetails?.followersCount ?? 0
            intVC?.followingCount = anotherUserDetails?.followingCount ?? 0
            intVC?.lblUserText = self.lblUserName.text!
            intVC?.isFollowers = true
            intVC?.status = "Following"
            
            self.view.ffTabVC.navigationController?.pushViewController(intVC!, animated: true)
        }
        
    }
    
    @IBAction func onTapEvents(_ sender: UIButton) {
        isGoToOtherPage = true
        if anotherUserDetails?.accountType != "Private" || anotherUserDetails?.followingStatus == "Accepted" || anotherUserDetails?.id == APIManager.sharedManager.user?.id {
            if anotherUserDetails?.id != APIManager.sharedManager.user?.id {
                let eventsList = (self.storyboard?.instantiateViewController(withIdentifier: "OtherUserEventsListVC") as? OtherUserEventsListVC)!
                eventsList.userId = userId!
                eventsList.isPrivate = anotherUserDetails?.accountType == "Private" ? true : false
                eventsList.isFollowing = anotherUserDetails?.followingStatus == "Accepted" ? true : false
                
                self.view.ffTabVC.navigationController?.pushViewController(eventsList, animated: true)
            } else {
                let eventsList = (self.storyboard?.instantiateViewController(withIdentifier: "EventsListVC") as? EventsListVC)!
                
                self.view.ffTabVC.navigationController?.pushViewController(eventsList, animated: true)
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

    // MARK: - Webservices
    
    func getAnotherUserDetails(userId: Int) {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getAnotherUserDetails(userId: userId)
                }
            }
            return
        }
        
        let params = ["userId": userId]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_OTHER_USER_DETAILS, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.anotherUserDetails = response?.result?.userDetail
                DispatchQueue.main.async {
                    self.setupUserDetails()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    func getPosts() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPosts()
                }
            }
            return
        }
        
        let params = ["page": pageNoPosts, "userId": anotherUserDetails!.id]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ALL_USER_POST, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.postList != nil {
                        self.postList?.append(contentsOf: (response?.result?.postList)!)
                    } else {
                        self.postList = (response?.result?.postList)!
                    }
                    
                    if self.postList!.count > 0 {
                        self.pageNoPosts += 1
                        self.hasMorePosts = (response?.result?.hasMore)!
                    }else {
                        self.viewEmptyData.isHidden = false
                    }
                    
                    self.tvPostReviews.dataSource = self
                    self.tvPostReviews.delegate = self
                    self.tvPostReviews.reloadData()
                }
                
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getMedias() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getMedias()
                }
            }
            
            return
        }
        
        let params = ["page": pageNoMedias, "userId": anotherUserDetails!.id]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ALL_USER_MEDIA, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.mediasList != nil {
                        self.mediasList?.append(contentsOf: (response?.result?.mediaList)!)
                    } else {
                        self.mediasList = (response?.result?.mediaList)!
                    }
                    if self.mediasList!.count > 0 {
                        self.pageNoMedias += 1
                        self.hasMoreMedias = (response?.result?.hasMore)!
                    }else {
                        self.viewEmptyData.isHidden = false

                    }
                    
                    self.cvMedias.dataSource = self
                    self.cvMedias.delegate = self
                    self.cvMedias.reloadData()
                }
                
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func getUsersReview() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getUsersReview()
                }
            }
            return
        }
        
        let params = ["page": pageNoReviews, "userId": anotherUserDetails!.id]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_USERS_REVIEW, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.reviewList != nil {
                        self.reviewList?.append(contentsOf: (response?.result?.reviewList)!)
                    } else {
                        self.reviewList = (response?.result?.reviewList)!
                    }
                    if self.reviewList!.count > 0 {
                        self.pageNoReviews += 1
                        self.hasMoreReviews = (response?.result?.hasMore)!
                    }else {
                        self.viewEmptyData.isHidden = false
                    }
                    
                    self.tvPostReviews.dataSource = self
                    self.tvPostReviews.delegate = self
                    self.tvPostReviews.reloadData()
                    
                }
                
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func followUser(toUserId: Int, isComeFromReview: Bool = false) {
            if !appDelegate.checkInternetConnection() {
                self.isRetryInternet { (isretry) in
                    if isretry! {
                        self.followUser(toUserId: toUserId, isComeFromReview: isComeFromReview)
                    }
                }
                return
            }
            
        let dictParams = ["toUserId": toUserId] as Dictionary<String, Any>
            
            showLoading()
            APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: dictParams) { (response: ApiResponse?, error) in
                self.hideLoading()
                if response?.status == 1 {
                    DispatchQueue.main.async {
                        if isComeFromReview {
                            self.reviewList![self.indexToUpdate].isFollowing = 1 - self.reviewList![self.indexToUpdate].isFollowing
                            
//                            if let isFollow : Int = self.reviewList![self.indexToUpdate].isFollowing {
//                                self.reviewList![self.indexToUpdate].isFollowing = 1 - isFollow
//                            }
                            
                            let value: String = (self.reviewList![self.indexToUpdate].isFollowing == 0) ? "" : ((self.reviewList![self.indexToUpdate].isFollowing == 1 && self.reviewList![self.indexToUpdate].accountType == "Private") ? "Pending" : "Following")
                            self.reviewList![self.indexToUpdate].followingStatus = value
                            
                            self.tvPostReviews.reloadData()
                        }else {
                            
                            if let isFollow = self.anotherUserDetails?.isFollowing! {
                                self.anotherUserDetails?.isFollowing = 1 - isFollow
                            }
                            
                            let value: String = (self.anotherUserDetails?.isFollowing == 0) ? "" : ((self.anotherUserDetails?.isFollowing == 1 && self.anotherUserDetails?.accountType == "Private") ? "Pending" : "Following")
                            self.anotherUserDetails?.followingStatus = value
                                                    
                            self.btnEditProfile.setTitle((self.anotherUserDetails?.followingStatus)! == "" ? "Follow" : ((self.anotherUserDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                            self.btnEditProfile.layer.borderColor = (self.anotherUserDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.anotherUserDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                            self.btnEditProfile.setTitleColor((self.anotherUserDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.anotherUserDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                            self.btnEditProfile.backgroundColor = (self.anotherUserDetails?.followingStatus)! == "" ? UIColor.clear : ((self.anotherUserDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                        }
                        
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
}

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == 0 {
            return postList?.count ?? 0
        } else {
            return reviewList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTab == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTVCell", for: indexPath) as! PostTVCell
            let post = postList![indexPath.row]
            cell.ivPost.setImage(imageUrl: post.mediaImage!)
            cell.lblPostTitle.text = post.title
            cell.lblPostDesc.text = post.description
            cell.lblPostDateTime.text = post.createDate
            cell.lblExpirydate.text = post.expiringDate
            cell.lblExpirydate.isHidden = post.isExpiringSoon == 1 ? false : true
            
            if post.amount! == "" {
                cell.btnPrice.isHidden = true
            }else {
                cell.btnPrice.setTitle("  \(post.amount!)  ", for: .normal)
            }
            
            
            cell.lblPostType.text = post.type == "Buy" ? "Buyer" : (post.type == "Sell" ? "Seller" : "Donor")
            
            cell.btnPost.tag = indexPath.row
            cell.btnPost.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTVCell", for: indexPath) as! ReviewTVCell
            let review = reviewList![indexPath.row]

            cell.ivUser.setImage(imageUrl: review.profilePic)
            cell.lblName.text = review.name
            cell.lblUserName.text = review.userName
            cell.lblReview.text = review.review.decodeEmoji
            
            cell.btnFollow.tag = indexPath.row
            cell.btnFollow.addTarget(self, action: #selector(onTapPostReview(_:)), for: .touchUpInside)
            cell.btnFollow.layer.borderWidth = 1.0
            
            if review.userId != APIManager.sharedManager.user?.id {
                cell.btnFollow.setTitle((review.followingStatus) == "" ? "Follow" : ((review.followingStatus) == "Pending" ? "Requested" : "Following"), for: .normal)
                cell.btnFollow.layer.borderColor = (review.followingStatus) == "" ? Colors.themeGreen.returnColor().cgColor : ((review.followingStatus) == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                cell.btnFollow.setTitleColor((review.followingStatus) == "" ? Colors.themeGreen.returnColor() : ((review.followingStatus) == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                cell.btnFollow.backgroundColor = (review.followingStatus) == "" ? UIColor.clear : ((review.followingStatus) == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                
                cell.btnFollow.isHidden = false
                cell.widthBtnFollow.constant = 80.0
                
            } else {
                cell.btnFollow.isHidden = true
                cell.widthBtnFollow.constant = 0.0
            }
            
            cell.viewRatings.rating = Double(review.rate)
            cell.viewRatings.isUserInteractionEnabled = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTab == 0 {
            if indexPath.row == postList!.count - 1 {
                if hasMorePosts == 1 {
                    getPosts()
                }
            }
        } else {
            if indexPath.row == reviewList!.count - 1 {
                if hasMoreReviews == 1 {
                    getUsersReview()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if selectedTab == 0 {
//            isGoToOtherPage = true
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
//            vc.postId = postList![indexPath.row].id
//            vc.ontapUpdateDelete = { isUpdated, isDeleted in
//                if isUpdated == 1 || isDeleted == 1 {
//                    self.onTapOptions(self.btnOptions[self.selectedTab])
//                }
//            }
//
//            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @objc func onTapPostEvent(_ sender: UIButton) {
        if selectedTab == 0 {
            isGoToOtherPage = true
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
            vc.postId = postList![sender.tag].id
            vc.ontapUpdateDelete = { isUpdated, isDeleted in
                if isUpdated == 1 || isDeleted == 1 {
//                    self.onTapOptions(self.btnOptions[self.selectedTab])
                }
            }
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onTapPostReview(_ sender: UIButton) {
        if selectedTab == 2 {
            indexToUpdate = sender.tag
            followUser(toUserId:  reviewList![indexToUpdate].userId, isComeFromReview: true)
        }
    }
}

extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediasList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMediaCVCell", for: indexPath) as! AddMediaCVCell

        cell.ivMedia.contentMode = .scaleAspectFill
        
        let media = mediasList![indexPath.item]
        
        cell.ivMedia.setImage(imageUrl: media.mediaImage!)
        if media.mediaType == "Image" {
            cell.btnVideoIndicator.isHidden = true
        } else {
            cell.btnVideoIndicator.isHidden = false
        }
        
        cell.viewContainer.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 2.0, opacity: 0.3)
        
        cell.viewContainer.layer.borderWidth = 0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.item == mediasList!.count - 1 && hasMoreMedias == 1 {
//            pageNoMedias += 1
            self.getMedias()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isGoToOtherPage = true
        let viewMedia = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVideoVC") as! ViewImageVideoVC
        viewMedia.userId = anotherUserDetails?.id
        viewMedia.profilePicURL = anotherUserDetails?.profilePic
        viewMedia.name = anotherUserDetails?.name
        viewMedia.userName = anotherUserDetails?.userName
        viewMedia.modalPresentationStyle = .overCurrentContext
        viewMedia.modalTransitionStyle = .crossDissolve
        viewMedia.media = mediasList![indexPath.item]
        viewMedia.removed = { status in
            if status == true {
                self.mediasList?.remove(at: indexPath.item)
                self.cvMedias.reloadData()
            }
        }
        self.view!.ffTabVC.present(viewMedia, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.width - 16)/3, height: (self.view.frame.width - 16)/3)
    }
    
}
