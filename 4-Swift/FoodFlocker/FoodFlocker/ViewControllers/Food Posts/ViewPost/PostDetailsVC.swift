//
//  PostDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class PostDetailsVC: UIViewController {

    //Outlets
    @IBOutlet weak var svMain: UIScrollView!

    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var btnFav: UIButton!
    @IBOutlet weak var lblFoodType: UILabel!
    @IBOutlet weak var lblPersonType: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblPostDesc: UILabel!
    @IBOutlet weak var lblQty: UILabel!

    @IBOutlet weak var ivPostedBy: UIImageView!
    @IBOutlet weak var lblPostedBy: UILabel!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var lblReviews: UILabel!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var lblIngredients: UILabel!
    @IBOutlet weak var lblTags: UILabel!
    @IBOutlet weak var lblRecipe: UILabel!
    @IBOutlet weak var tvCostingSheet: UITableView!
    @IBOutlet weak var heightTVCostingSheet: NSLayoutConstraint!
    @IBOutlet weak var widthFollowing: NSLayoutConstraint!
    @IBOutlet weak var viewChatFollow: UIView!
    
    @IBOutlet weak var ivCook: UIImageView!
    @IBOutlet weak var lblRealName: UILabel!
    @IBOutlet weak var lblCookName: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var btnReadMore: UIButton!
    @IBOutlet weak var heightOfReadmore: NSLayoutConstraint!
    @IBOutlet weak var heightOfAbout: NSLayoutConstraint!
    
    @IBOutlet weak var bottomAddress: NSLayoutConstraint!
    
    // new changes
    @IBOutlet weak var lblTitleQTY: UILabel!
    @IBOutlet weak var bottomOfQTY: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitleIngredients: UILabel!
    @IBOutlet weak var topOfIngredients: NSLayoutConstraint!
    @IBOutlet weak var bottomOfIngredients: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitleTag: UILabel!
    @IBOutlet weak var bottomOfTag: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitleRecipe: UILabel!
    @IBOutlet weak var topOfRecipe: NSLayoutConstraint!
    @IBOutlet weak var bottomOfRecipe: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitleCostingSheet: UILabel!
    @IBOutlet weak var bottomOfCostingSheet: NSLayoutConstraint!
    @IBOutlet weak var bottomOfTvCostingSheet: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottomRealName: UIView!
    @IBOutlet weak var hightOfViewBottomRealName: NSLayoutConstraint!
    @IBOutlet weak var bottomOfViewBottomRealName: NSLayoutConstraint!
    
//    @IBOutlet weak var lblTitleIngredients: UILabel!
//    @IBOutlet weak var bottomOfIngredients: NSLayoutConstraint!
    
    
    var isLabelAtMaxHeight = false
    
    var postDetails: PostEventDetail?
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
    .font: Fonts.Regular.returnFont(size: 16.0),
    .foregroundColor: Colors.themeGreen.returnColor(),
    .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        setupPostDetails()
    }
    

    func setupUI() {

        ivPostedBy.layer.cornerRadius = ivPostedBy.frame.size.height / 2
        ivPostedBy.layer.masksToBounds = false
        ivPostedBy.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        ivPostedBy.layer.shadowOffset = CGSize(width: 0, height: 3)
        ivPostedBy.layer.shadowOpacity = 0.7
        ivPostedBy.layer.shadowRadius = 5.0
        ivPostedBy.clipsToBounds = true
        
        ivPostedBy.layer.borderColor = UIColor.white.cgColor
        ivPostedBy.layer.borderWidth = 1.0
        
        btnFollow.layer.borderWidth = 1.0
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height / 2
        
        ivCook.layer.cornerRadius = ivCook.frame.size.height / 2
        ivCook.layer.masksToBounds = false
        ivCook.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        ivCook.layer.shadowOffset = CGSize(width: 0, height: 3)
        ivCook.layer.shadowOpacity = 0.7
        ivCook.layer.shadowRadius = 5.0
        
        ivCook.layer.borderColor = UIColor.white.cgColor
        ivCook.layer.borderWidth = 1.0
        ivCook.clipsToBounds = true

        tvCostingSheet.layer.masksToBounds = false
        tvCostingSheet.layer.shadowColor = Colors.lightGray.returnColor().cgColor
        tvCostingSheet.layer.shadowOffset = CGSize(width: 0, height: 3)
        tvCostingSheet.layer.shadowOpacity = 0.7
        tvCostingSheet.layer.shadowRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvCostingSheet.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvCostingSheet.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVCostingSheet.constant = newsize.height
                self.updateViewConstraints()
            }
        }
    }
    
    func setupPostDetails() {

        
        lblPostTitle.text = postDetails?.title
        btnFav.setImage(UIImage(named: postDetails?.isLike == 1 ? "Like" : "Unlike"), for: .normal)
        lblPostDate.text = postDetails?.createDate
        lblFoodType.text = postDetails?.category
        lblPersonType.text = postDetails?.type == "Buy" ? "Buyer" : (postDetails?.type == "Sell" ? "Seller" : "Donor")
        lblPersonType.textColor = Colors.orange.returnColor()
        
        lblLikes.text = "\(postDetails!.likesCount)" + " Likes"
        lblPostDesc.text = postDetails?.description
        
        let attributeString = NSMutableAttributedString(string: "read more",
                                                        attributes: yourAttributes)
        btnReadMore.setAttributedTitle(attributeString, for: .normal)
        
        if Utilities.getLabelHeight(text: (postDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0)) > 70.0 {
            btnReadMore.isHidden = false
            heightOfAbout.constant = 70.0
            heightOfReadmore.constant = 20.0
        }else {
            btnReadMore.isHidden = true
            heightOfAbout.constant = Utilities.getLabelHeight(text: (postDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0))
            heightOfReadmore.constant = 0.0
        }
        
        self.view.layoutIfNeeded()
        
        if (postDetails?.foodDetails!.count)! > 0 {
            
            lblQty.text = postDetails?.foodDetails![0].quantity
            lblIngredients.text = postDetails?.foodDetails![0].ingredients
            lblTags.text = postDetails?.foodDetails![0].tags
            lblRecipe.text = postDetails?.foodDetails![0].recipe

            print((postDetails?.foodDetails![0].backgroundImage)!)
            ivCook.setImage(imageUrl: (postDetails?.foodDetails![0].backgroundImage)!)
            lblRealName.text = postDetails?.foodDetails![0].realName
            lblCookName.text = postDetails?.foodDetails![0].cookName
            
            tvCostingSheet.dataSource = self
            tvCostingSheet.delegate = self
            tvCostingSheet.reloadData()
        }else {
            
            lblTitleQTY.text = ""
            lblTitleIngredients.text = ""
            lblTitleTag.text = ""
            lblTitleRecipe.text = ""
            lblTitleCostingSheet.text = ""
            
            bottomOfQTY.constant = 0.0
            topOfIngredients.constant = 0.0
            bottomOfIngredients.constant = 0.0
            bottomOfTag.constant = 0.0
            topOfRecipe.constant = 0.0
            bottomOfRecipe.constant = 0.0
            
            bottomOfCostingSheet.constant = 0.0
            bottomOfTvCostingSheet.constant = 0.0
            hightOfViewBottomRealName.constant = 0.0
            bottomOfViewBottomRealName.constant = 0.0
            viewBottomRealName.isHidden = true
            self.tvCostingSheet.isHidden = true
            self.heightTVCostingSheet.constant = 0.0
            
            self.view.layoutIfNeeded()
        }
        
        ivPostedBy.setImage(imageUrl: postDetails!.profilePic)
        lblPostedBy.text = postDetails?.name
        lblRatings.text = "\(postDetails!.rating ?? 0.0)"
        lblReviews.text = "(\(postDetails!.reviewCount) reviews)"
        lblReviews.setUnderLine(text: "\(postDetails!.reviewCount) reviews")
        
        if postDetails!.userId == APIManager.sharedManager.user?.id {
            viewChatFollow.isHidden = true
            widthFollowing.constant = 0.0
            self.bottomAddress.constant = 16.0
            self.view.layoutIfNeeded()
        }else {
            self.btnFollow.setTitle((self.postDetails?.followingStatus)! == "" ? "Follow" : ((self.postDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
            self.btnFollow.layer.borderColor = (self.postDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.postDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
            self.btnFollow.setTitleColor((self.postDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.postDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
            self.btnFollow.backgroundColor = (self.postDetails?.followingStatus)! == "" ? UIColor.clear : ((self.postDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
            
            widthFollowing.constant = 134.0
            viewChatFollow.isHidden = false
            self.bottomAddress.constant = 88.0
            self.view.layoutIfNeeded()
        }
        
        lblAddress.text = postDetails?.address
        
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
            heightOfAbout.constant = Utilities.getLabelHeight(text: (postDetails?.description)!, width: view.bounds.width - 32.0, font: Fonts.Regular.returnFont(size: 16.0))
        }
        
        self.view.layoutIfNeeded()
    }
        
    @IBAction func messageTapped(_ sender: UIButton) {
        let conversationVC = self.storyboard?.instantiateViewController(withIdentifier: "ConversationVC") as? ConversationVC
        conversationVC?.userId = postDetails?.userId
        conversationVC?.profilePic = postDetails?.profilePic
        conversationVC?.userName = postDetails?.name
        conversationVC?.conversationId = APIManager.sharedManager.user!.id > postDetails!.userId ? "\(postDetails?.userId ?? 0)_\(APIManager.sharedManager.user!.id)" : "\(APIManager.sharedManager.user!.id)_\(postDetails?.userId ?? 0)"
        
        self.navigationController?.pushViewController(conversationVC!, animated: true)
    }
    
    @IBAction func favTapped(_ sender: UIButton) {
        likePost()
    }
    
    @IBAction func likesTapped(_ sender: UIButton) {
        let likeUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "LikeUsersVC") as? LikeUsersVC
        likeUsersVC?.moduleId = postDetails!.id
        likeUsersVC?.module = "Post"
        likeUsersVC?.likesCount = postDetails!.likesCount
        self.navigationController?.pushViewController(likeUsersVC!, animated: true)
    }
    
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
        
        let dictParams = ["toUserId": postDetails!.userId] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isFollow = self.postDetails?.isFollowing! {
                        self.postDetails?.isFollowing = 1 - isFollow
                    }
                    let value: String = (self.postDetails?.isFollowing == 0) ? "" : ((self.postDetails?.isFollowing == 1 && self.postDetails?.accountType == "Private") ? "Pending" : "Following")
                    self.postDetails?.followingStatus = value
                    
                    self.btnFollow.setTitle((self.postDetails?.followingStatus)! == "" ? "Follow" : ((self.postDetails?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                    self.btnFollow.layer.borderColor = (self.postDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.postDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                    self.btnFollow.setTitleColor((self.postDetails?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.postDetails?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                    self.btnFollow.backgroundColor = (self.postDetails?.followingStatus)! == "" ? UIColor.clear : ((self.postDetails?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                    
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func likePost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.likePost()
                }
            }
            return
        }
        
        let dictParams = ["moduleId": postDetails!.id, "module": "Post"] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LIKE_POST_EVENT, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isLike = self.postDetails?.isLike {
                        self.postDetails?.isLike = 1 - isLike
                        
                        self.postDetails!.likesCount = self.postDetails?.isLike == 1 ? self.postDetails!.likesCount + 1 : self.postDetails!.likesCount - 1
                        
                        self.lblLikes.text = "\(self.postDetails!.likesCount) Likes"
                    }

                    self.btnFav.setImage(UIImage(named: self.postDetails?.isLike == 1 ? "Like" : "Unlike"), for: .normal)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    

}

extension PostDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (postDetails?.foodDetails![0].costingSheet!.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostingSheetCell") as! CostingSheetCell
        cell.backgroundColor = indexPath.row % 2 == 1 ? UIColor.white : Colors.light.returnColor()
        
        let sheet = postDetails?.foodDetails![0].costingSheet![indexPath.row]
        
        cell.lblIngr.text = sheet?.name
        cell.lblCost.text = "\(sheet?.sign ?? "")\(String(format: "%.2f", sheet!.price))"

        return cell
    }
    
}
