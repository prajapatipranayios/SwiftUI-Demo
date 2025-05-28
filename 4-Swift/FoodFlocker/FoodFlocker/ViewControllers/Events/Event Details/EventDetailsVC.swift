//
//  EventDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class EventDetailsVC: UIViewController {

    //Outlets
    @IBOutlet weak var svMain: UIScrollView!
    
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblEventMonth: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!

    @IBOutlet weak var ivInterested: UIImageView!
    @IBOutlet weak var lblInterested: UILabel!
    
    @IBOutlet weak var ivMaybe: UIImageView!
    @IBOutlet weak var lblMaybe: UILabel!
    
    @IBOutlet weak var ivLike: UIImageView!
    @IBOutlet weak var lblLike: UILabel!
    
    @IBOutlet weak var ivFavourite: UIImageView!
    @IBOutlet weak var lblFavourite: UILabel!
    
    @IBOutlet weak var lblInterestedCount: UILabel!
    @IBOutlet weak var lblMaybeCount: UILabel!
    @IBOutlet weak var lblLikesCount: UILabel!

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblEventDateTime: UILabel!
    @IBOutlet weak var lblFoodCategory: UILabel!

    @IBOutlet weak var viewBtnContainer: UIView!
    
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    
    @IBOutlet weak var heightSVAbout: NSLayoutConstraint!
    
    @IBOutlet weak var lblEventDetails: UILabel!

    @IBOutlet weak var tvFoodDetails: UITableView!
    @IBOutlet weak var heightTVFoodDetails: NSLayoutConstraint!

    @IBOutlet weak var ivHostedBy: UIImageView!
    @IBOutlet weak var lblHostedBy: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var lblReviews: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var svForum: UIScrollView!
    @IBOutlet weak var svAbout: UIScrollView!

    @IBOutlet weak var tvForum: UITableView!
    @IBOutlet weak var heightTVForum: NSLayoutConstraint!
    @IBOutlet weak var ivUserProfile: UIImageView!
    @IBOutlet weak var tfSaySomething: UITextField!

    @IBOutlet weak var widthFollowing: NSLayoutConstraint!
    @IBOutlet weak var viewChatFollow: UIView!
    
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var heightOfReadmore: NSLayoutConstraint!
    @IBOutlet weak var heightOfAbout: NSLayoutConstraint!
    @IBOutlet weak var viewEmptyData: UIView!
    
    var isLabelAtMaxHeight = false
        
    let yourAttributes: [NSAttributedString.Key: Any] = [
    .font: Fonts.Regular.returnFont(size: 16.0),
    .foregroundColor: Colors.themeGreen.returnColor(),
    .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    var eventDetails: PostEventDetail?

    var statusParam: String = ""
    
    var questionsList: [ForumQuestion]?
    
    var paramsGiveReply = Dictionary<String, Any>()
    var onUpdateTicket: ((Int)->Void)?
    var ontapTab: ((Int)->Void)?
    
    var hasMore = -1
    var pageNoQueList: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvFoodDetails.register(UINib(nibName: "EventFoodItemCell", bundle: nil), forCellReuseIdentifier: "EventFoodItemCell")
        
        tvForum.register(UINib(nibName: "ForumSecHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ForumSecHeaderView")
        tvForum.register(UINib(nibName: "ForumTVCell", bundle: nil), forCellReuseIdentifier: "ForumTVCell")
        
        tvForum.sectionHeaderHeight = UITableView.automaticDimension
        tvForum.estimatedSectionHeaderHeight = 159
        tvForum.estimatedRowHeight = 90
        tvForum.rowHeight = UITableView.automaticDimension
        setupEventDetails()
        
        tfSaySomething.delegate = self
        tfSaySomething.tag = 11
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
            lbl.backgroundColor = Colors.themeGreen.returnColor()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvFoodDetails.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvForum.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tvFoodDetails.removeObserver(self, forKeyPath: "contentSize")
        tvForum.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let tv = object as! UITableView
                let newsize  = newvalue as! CGSize
                if tv.tag == 0 {
                    self.heightTVFoodDetails.constant = newsize.height
                } else {
                    self.heightTVForum.constant = newsize.height
                }
                self.updateViewConstraints()
            }
        }
    }
    
    func setupUI() {
        
        viewBtnContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 5.0, bgColor: UIColor.white)
        
        heightSVAbout.constant = self.view.frame.size.height - (Utilities.isIphoneXAbove() ? 138 : 60)
        
        btnOptions[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
        btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        lblDots[0].isHidden = false
        lblDots[1].isHidden = true
        
        ivHostedBy.layer.cornerRadius = ivHostedBy.frame.size.height / 2
        ivHostedBy.layer.masksToBounds = false
        ivHostedBy.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        ivHostedBy.layer.shadowOffset = CGSize(width: 0, height: 3)
        ivHostedBy.layer.shadowOpacity = 0.7
        ivHostedBy.layer.shadowRadius = 5.0
        ivHostedBy.clipsToBounds = true
        
        ivHostedBy.layer.borderColor = UIColor.white.cgColor
        ivHostedBy.layer.borderWidth = 1.0
        
        btnFollow.layer.borderWidth = 1.0
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height / 2
        
        ivUserProfile.layer.cornerRadius = ivUserProfile.frame.size.height / 2
//        ivUserProfile.layer.borderWidth = 1.0
//        ivUserProfile.layer.borderColor = UIColor.white.cgColor
//        ivUserProfile.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
    }
    
    func setupEventDetails() {

        lblEventTitle.text = eventDetails?.title
        
//        eventDetails?.endDate
        let date = eventDetails?.startDate!.split(separator: " ")
        
        lblEventMonth.text = String(date![1])
        lblEventDate.text = String(date![0])
        
        ivLike.image = UIImage(named: self.eventDetails?.isLike == 1 ? "Like" : "Unlike")
        lblLike.textColor = self.eventDetails?.isLike == 1 ? Colors.red.returnColor() : Colors.gray.returnColor()
        
        ivFavourite.image = UIImage(named: self.eventDetails?.isSave == 1 ? "FavoriteActive" : "Favorite")
        lblFavourite.textColor = self.eventDetails?.isSave == 1 ? Colors.themeGreen.returnColor() : Colors.gray.returnColor()

        lblInterestedCount.text = "\((eventDetails?.interestedCount)!) Interested"
        lblMaybeCount.text = "\((eventDetails?.mayBeCount)!) Maybe"
        lblLikesCount.text = "\((eventDetails?.likesCount)!) Likes"

        lblLocation.text = eventDetails?.address
        lblEventDateTime.text = "\(eventDetails?.startDate ?? "") - \(eventDetails?.endDate ?? "")"
        lblFoodCategory.text = eventDetails?.category
        
        lblEventDetails.text = eventDetails?.description
        
        let attributeString = NSMutableAttributedString(string: "read more",
                                                        attributes: yourAttributes)
        btnReadMore.setAttributedTitle(attributeString, for: .normal)
        
        if Utilities.getLabelHeight(text: (eventDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0)) > 70.0 {
            btnReadMore.isHidden = false
            heightOfAbout.constant = 70.0
            heightOfReadmore.constant = 20.0
        }else {
            btnReadMore.isHidden = true
            heightOfAbout.constant = Utilities.getLabelHeight(text: (eventDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0))
            heightOfReadmore.constant = 0.0
        }
        
        self.view.layoutIfNeeded()
        
        
        svForum.isHidden = true
        
        ivHostedBy.setImage(imageUrl: eventDetails!.profilePic)
        lblHostedBy.text = eventDetails?.name
        lblRatings.text = "\(eventDetails!.rating ?? 0.0)"
        lblReviews.text = "(\(eventDetails!.reviewCount) reviews)"
        lblReviews.setUnderLine(text: "\(eventDetails!.reviewCount) reviews")
        
        if eventDetails!.userId == APIManager.sharedManager.user?.id {
            viewChatFollow.isHidden = true
            widthFollowing.constant = 0.0
        }else {
            self.btnFollow.setTitle((self.eventDetails?.followingStatus)! == "" ? "Follow" : ((self.eventDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
            self.btnFollow.layer.borderColor = (self.eventDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.eventDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
            self.btnFollow.setTitleColor((self.eventDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.eventDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
            self.btnFollow.backgroundColor = (self.eventDetails?.followingStatus)! == "" ? UIColor.clear : ((self.eventDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
            
            widthFollowing.constant = 126.0
            viewChatFollow.isHidden = false
        }
        
        ivUserProfile.setImage(imageUrl: eventDetails!.profilePic)
        
        changeEventStatus()
    }
    
    func changeEventStatus() {
        if eventDetails?.eventStatus == "Interested" {
            self.ivInterested.image = UIImage(named: "InterestedActive")
            self.lblInterested.textColor = Colors.orange.returnColor()
            
            self.ivMaybe.image = UIImage(named: "MayBe")
            self.lblMaybe.textColor = Colors.gray.returnColor()
            
        }else if eventDetails?.eventStatus == "May_be" {
            self.ivMaybe.image = UIImage(named: "MayBeActive")
            self.lblMaybe.textColor = Colors.orange.returnColor()
            
            self.ivInterested.image = UIImage(named: "Interested")
            self.lblInterested.textColor = Colors.gray.returnColor()
            
        } else {
            
            self.ivInterested.image = UIImage(named: "Interested")
            self.lblInterested.textColor = Colors.gray.returnColor()
            
            self.ivMaybe.image = UIImage(named: "MayBe")
            self.lblMaybe.textColor = Colors.gray.returnColor()
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func followUserTapped(_ sender: UIButton) {
        followUser()
    }
    
    @IBAction func onTapReadMore(_ sender: Any) {
        if isLabelAtMaxHeight {
            let attributeString = NSMutableAttributedString(string: "read more",
                                                            attributes: yourAttributes)
            btnReadMore.setAttributedTitle(attributeString, for: .normal)
            isLabelAtMaxHeight = false
            heightOfAbout.constant = 70.0
        }
        else {
            let attributeString = NSMutableAttributedString(string: "read less",
                                                            attributes: yourAttributes)
            btnReadMore.setAttributedTitle(attributeString, for: .normal)
            isLabelAtMaxHeight = true
            heightOfAbout.constant = Utilities.getLabelHeight(text: (eventDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0))
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func messageTapped(_ sender: UIButton) {
        let conversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationVC
        conversationVC?.userId = eventDetails?.userId
        conversationVC?.profilePic = eventDetails?.profilePic
        conversationVC?.userName = eventDetails?.name
        conversationVC?.conversationId = APIManager.sharedManager.user!.id > eventDetails!.userId ? "\(eventDetails?.userId ?? 0)_\(APIManager.sharedManager.user!.id)" : "\(APIManager.sharedManager.user!.id)_\(eventDetails?.userId ?? 0)"
        
        self.navigationController?.pushViewController(conversationVC!, animated: true)
    }
    
    @IBAction func interestedTapped(_ sender: UIButton) {
        let intVC = self.storyboard?.instantiateViewController(withIdentifier: "EventInterestedVC") as? EventInterestedVC
        intVC?.eventId = eventDetails?.id
        intVC?.eventName = eventDetails?.name
        intVC?.status = "Interested"
        intVC?.interestedCount = eventDetails?.interestedCount
        intVC?.maybeCount = eventDetails?.mayBeCount
        self.navigationController?.pushViewController(intVC!, animated: true)
    }
    
    @IBAction func maybeTapped(_ sender: UIButton) {
        let intVC = self.storyboard?.instantiateViewController(withIdentifier: "EventInterestedVC") as? EventInterestedVC
        intVC?.eventId = eventDetails?.id
        intVC?.eventName = eventDetails?.name
        intVC?.status = "May_be"
        intVC?.interestedCount = eventDetails?.interestedCount
        intVC?.maybeCount = eventDetails?.mayBeCount
        self.navigationController?.pushViewController(intVC!, animated: true)

    }
    
    @IBAction func likesTapped(_ sender: UIButton) {
        let likeUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "LikeUsersVC") as? LikeUsersVC
        likeUsersVC?.moduleId = eventDetails!.id
        likeUsersVC?.module = "Event"
        likeUsersVC?.likesCount = eventDetails!.likesCount
        self.navigationController?.pushViewController(likeUsersVC!, animated: true)
    }
    
    @IBAction func onTapInterested(_ sender: UIButton) {
        statusParam = "Interested"
        changeUserEventStatus()
    }
    
    @IBAction func onTapMaybe(_ sender: UIButton) {
        statusParam = "May_be"
        changeUserEventStatus()
    }
    
    @IBAction func onTapLike(_ sender: UIButton) {
        likeEvent()
    }
    
    @IBAction func onTapFavorite(_ sender: UIButton) {
        makeEventFavorite()
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        if self.ontapTab != nil {
            self.ontapTab!(sender.tag)
        }
        
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            svAbout.isHidden = false
            svForum.isHidden = true
            
        } else {
            btnOptions[1].setTitleColor(Colors.themeGreen.returnColor(), for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            svAbout.isHidden = true
            svForum.isHidden = false
            
            hasMore = -1
            pageNoQueList = 1
            self.questionsList?.removeAll()
            self.tvForum.reloadData()
            self.getForumQuestions()
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

    func followUser() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.followUser()
                }
            }
            return
        }
        
        let dictParams = ["toUserId": eventDetails!.userId] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isFollow = self.eventDetails?.isFollowing! {
                        self.eventDetails?.isFollowing = 1 - isFollow
                    }
                    let value: String = (self.eventDetails?.isFollowing == 0) ? "" : ((self.eventDetails?.isFollowing == 1 && self.eventDetails?.accountType == "Private") ? "Pending" : "Following")
                    self.eventDetails?.followingStatus = value
                    
                    self.btnFollow.setTitle((self.eventDetails?.followingStatus)! == "" ? "Follow" : ((self.eventDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                    self.btnFollow.layer.borderColor = (self.eventDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.eventDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                    self.btnFollow.setTitleColor((self.eventDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.eventDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                    self.btnFollow.backgroundColor = (self.eventDetails?.followingStatus)! == "" ? UIColor.clear : ((self.eventDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func likeEvent() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.likeEvent()
                }
            }
            return
        }
        
        let dictParams = ["moduleId": eventDetails!.id, "module": "Event"] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LIKE_POST_EVENT, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isLike = self.eventDetails?.isLike {
                        self.eventDetails?.isLike = 1 - isLike
                        
                        self.eventDetails!.likesCount = self.eventDetails?.isLike == 1 ? self.eventDetails!.likesCount + 1 : self.eventDetails!.likesCount - 1
                        
                        self.lblLikesCount.text = "\(self.eventDetails!.likesCount) Likes"
                    }
                    
                    self.ivLike.image = UIImage(named: self.eventDetails?.isLike == 1 ? "Like" : "Unlike")
                    self.lblLike.textColor = self.eventDetails?.isLike == 1 ? Colors.red.returnColor() : UIColor.black
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func makeEventFavorite() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.makeEventFavorite()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SAVE_UNSAVE_EVENT, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isSave = self.eventDetails?.isSave {
                        self.eventDetails?.isSave = 1 - isSave
                    }
                    
                    self.ivFavourite.image = UIImage(named: self.eventDetails?.isSave == 1 ? "FavoriteActive" : "Favorite")
                    self.lblFavourite.textColor = self.eventDetails?.isSave == 1 ? Colors.themeGreen.returnColor() : Colors.gray.returnColor()
                    
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func changeUserEventStatus() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.changeUserEventStatus()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id, "status": statusParam] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.CHANGE_USER_EVENT_STATUS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if self.eventDetails?.eventStatus == self.statusParam {
                        self.eventDetails?.eventStatus = ""
                        if self.statusParam == "Interested" {
                            self.eventDetails!.interestedCount = self.eventDetails!.interestedCount! - 1
                            
                            self.lblInterestedCount.text = "\((self.eventDetails?.interestedCount)!) Interested"
                        }else {
                            self.eventDetails!.mayBeCount = self.eventDetails!.mayBeCount! - 1
                            self.lblMaybeCount.text = "\((self.eventDetails?.mayBeCount)!) Maybe"
                        }
                    }else {
                        if self.statusParam == "Interested" {
                            self.eventDetails!.interestedCount = self.eventDetails!.interestedCount! + 1
                            
                            self.eventDetails!.mayBeCount = self.eventDetails!.mayBeCount! - (self.eventDetails?.eventStatus == "May_be" ? 1 : 0)
 
                            self.lblInterestedCount.text = "\((self.eventDetails?.interestedCount)!) Interested"
                            self.lblMaybeCount.text = "\((self.eventDetails?.mayBeCount)!) Maybe"
                        }else {
                            self.eventDetails!.mayBeCount = self.eventDetails!.mayBeCount! + 1
                            self.eventDetails!.interestedCount = self.eventDetails!.interestedCount! - (self.eventDetails?.eventStatus == "Interested" ? 1 : 0)
                            
                            self.lblInterestedCount.text = "\((self.eventDetails?.interestedCount)!) Interested"
                            self.lblMaybeCount.text = "\((self.eventDetails?.mayBeCount)!) Maybe"
                        }
                        
                        self.eventDetails?.eventStatus = self.statusParam
                        
                    }
                    
                    self.statusParam = ""
                    self.changeEventStatus()
                }
            } else {
                self.statusParam = ""
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    func getForumQuestions() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getForumQuestions()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id, "page": pageNoQueList] as Dictionary<String, Any>

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FORUM_QUESTION_LIST, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.questionsList != nil {
                    self.questionsList?.append(contentsOf: (response?.result?.questionsList)!)
                } else {
                    self.questionsList = (response?.result?.questionsList)!
                }
                
                DispatchQueue.main.async {
                    if self.questionsList!.count > 0 {
                        self.pageNoQueList += 1
                        self.hasMore = (response?.result?.hasMore)!
                        
                        self.viewEmptyData.isHidden = true
                        self.tvForum.isHidden = false
                        self.tvForum.dataSource = self
                        self.tvForum.delegate = self
                        self.tvForum.reloadData()
                    }else {
                        self.tvForum.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func sendQuestion() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendQuestion()
                }
            }
            return
        }
        
        let dictParams = ["eventId": eventDetails!.id, "question": tfSaySomething.text!.encodeEmoji] as Dictionary<String, Any>

        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEND_QUESTIONS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.tfSaySomething.text = ""
                    self.pageNoQueList = 1
                    self.questionsList?.removeAll()
                    self.getForumQuestions()
                }
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                self.statusParam = ""
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func giveReply() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.giveReply()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GIVE_REPLY, parameters: paramsGiveReply) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.pageNoQueList = 1
                self.questionsList?.removeAll()
                self.getForumQuestions()
                
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                self.statusParam = ""
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension EventDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 55 {
            return questionsList!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 55 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ForumSecHeaderView") as! ForumSecHeaderView
            let question = questionsList?[section]
            
            header.ivUser.setImage(imageUrl: question!.profilePic)
            header.lblUserName.text = question?.name
            header.lblDateTime.text = question?.questionDate
            header.lblQuestion.text = question?.question.decodeEmoji
            
            return header
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 55 {
            return (questionsList?[section].answers.count)! + 1
        } else {
            return (eventDetails?.foodDetails!.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 55 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ForumTVCell") as! ForumTVCell
            
            let answers = questionsList?[indexPath.section].answers
            if indexPath.row == (answers?.count)! {
                cell.lblComment.text = ""
                cell.viewReply.isHidden = false
                cell.ivUser.isHidden = true
                cell.lblComment.isHidden = true
                cell.lblDuration.isHidden = true
                cell.tfReply.tag = indexPath.section
                cell.tfReply.delegate = self
            } else {
                cell.viewReply.isHidden = true
                cell.ivUser.isHidden = false
                cell.lblComment.isHidden = false
                cell.lblDuration.isHidden = false
                
                let answer = answers![indexPath.row]
                cell.ivUser.setImage(imageUrl: answer.profilePic)
//                cell.lblComment.text = "\(answer.name) . \(answer.answer?.decodeEmoji ?? "")"
                cell.lblComment.attributedText = Utilities.attributedText(withString: "\(answer.name) . \(answer.answer?.decodeEmoji ?? "")", boldString: answer.name, font: Fonts.Regular.returnFont(size: 14.0))
                
                cell.lblDuration.text = answer.answerDate
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventFoodItemCell") as! EventFoodItemCell
            cell.backgroundColor = UIColor.clear
            
            let foodDetails = eventDetails?.foodDetails![indexPath.row]
            
            cell.lblFoodName.text = foodDetails?.foodName
            cell.lblFoodQty.text = foodDetails?.quantity
            cell.lblFoodIngr.text = foodDetails?.ingredients
            cell.lblFoodTag.text = foodDetails?.tags
            
            cell.tvCostingSheet.register(UINib(nibName: "EventCostingSheetCell", bundle: nil), forCellReuseIdentifier: "EventCostingSheetCell")

            if (foodDetails?.costingSheet!.count)! > 0 {
                cell.setupCostingSheet(sheet: (foodDetails?.costingSheet)!)
            } else {
                cell.heightTVCostingSheet.constant = 0
            }
            
            cell.heightTVCostingSheet.constant = CGFloat(((foodDetails?.costingSheet?.count)! * 50) + 50)
            cell.contentView.layoutIfNeeded()
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.tag == 55 {
            if indexPath.section == questionsList!.count - 1 && indexPath.row == questionsList![indexPath.section].answers.count {
                if hasMore == 1 {
                    getForumQuestions()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
        
//        if tableView.tag == 55 {
//            let answers = questionsList?[indexPath.section].answers
//
//            if indexPath.row == (answers?.count)! {
//                return 40.0
//            }else {
//                return UITableView.automaticDimension
//            }
//        }else {
//            return UITableView.automaticDimension
//        }
        
    }
    
}

extension EventDetailsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.trimmedString
        
        if textField.text != "" {
            if textField.tag == 11 && textField == tfSaySomething {
                sendQuestion()
            } else {
                let question = questionsList![textField.tag]
                paramsGiveReply.updateValue(question.id, forKey: "questionId")
                paramsGiveReply.updateValue(textField.text!.encodeEmoji, forKey: "answer")
                textField.text = ""
                giveReply()
            }
        }
    }
}
