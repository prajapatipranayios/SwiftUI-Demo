//
//  RequestsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatRatingView

class RequestsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewOptionsContainer: UIView!
    
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!

    @IBOutlet weak var tvRequests: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!
    
    var selectedTabIndex = 0
    
    var dictParams = [String: Any]()

    var receivedPosts: [PostEventDetail]?
    var sentPosts: [PostEventDetail]?
    
    var pageNoReceived = 1
    var pageNoSent = 1
    
    var isGoToOtherPage = false
    
    var hasMoreReceived = -1
    var hasMoreSent = -1

    var dictParamsAcceptRejectPost = [String: Any]()
    var indexToUpdate = -1

    var dictParamsGiveRating = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvRequests.rowHeight = UITableView.automaticDimension
        tvRequests.estimatedRowHeight = 100.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isGoToOtherPage {
            isGoToOtherPage = false
        }else {
            onTapOptions(btnOptions[selectedTabIndex])
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
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(UIColor.white, for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            
            pageNoReceived = 1
            hasMoreReceived = -1
            dictParams.updateValue(pageNoReceived, forKey: "page")
            dictParams.updateValue("Receive", forKey: "type")
            
            receivedPosts?.removeAll()
            tvRequests.reloadData()
            getRequests()
            
//            if receivedPosts == nil {
//
//            } else {
//
//                self.viewEmptyData.isHidden = receivedPosts!.count > 0 ? true : false
//                self.tvRequests.isHidden = receivedPosts!.count > 0 ? false : true
//            }
        } else {
            btnOptions[1].setTitleColor(UIColor.white, for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            
            pageNoSent = 1
            hasMoreSent = -1
            dictParams.updateValue(pageNoSent, forKey: "page")
            dictParams.updateValue("Sent", forKey: "type")
            
            sentPosts?.removeAll()
            tvRequests.reloadData()
            getRequests()
//            if sentPosts == nil {
//
//            } else {
//
//                self.viewEmptyData.isHidden = sentPosts!.count > 0 ? true : false
//                self.tvRequests.isHidden = sentPosts!.count > 0 ? false : true
//            }
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

    func getRequests() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getRequests()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_POST_REQUESTS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    if self.selectedTabIndex == 0 {
                        
                        if self.receivedPosts != nil {
                            self.receivedPosts?.append(contentsOf: (response?.result?.postList)!)
                        } else {
                            self.receivedPosts = (response?.result?.postList)!
                        }
                        
                        if self.receivedPosts!.count > 0 {
                            self.pageNoReceived += 1
                            self.hasMoreReceived = (response?.result?.hasMore)!
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
                        if self.sentPosts != nil {
                            self.sentPosts?.append(contentsOf: (response?.result?.postList)!)
                        } else {
                            self.sentPosts = (response?.result?.postList)!
                        }
                        if self.sentPosts!.count > 0 {
                            self.pageNoSent += 1
                            self.hasMoreSent = (response?.result?.hasMore)!
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
                    }
                }
                
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func sendRequest(postId: Int) {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendRequest(postId: postId)
                }
            }
            
            return
        }
        
        let dictParams = ["postId": postId] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEND_REQUEST_FOR_POST, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.sentPosts?.remove(at: self.indexToUpdate)
                    self.tvRequests.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func acceptRejectPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.acceptRejectPost()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ACCEPT_REJECT_POST, parameters: dictParamsAcceptRejectPost) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    
                    if self.selectedTabIndex == 0 {
                        self.pageNoReceived = 1
                        self.hasMoreReceived = -1
                        self.dictParams.updateValue(self.pageNoReceived, forKey: "page")
                        self.dictParams.updateValue("Receive", forKey: "type")
                        
                        self.receivedPosts?.removeAll()
                        self.tvRequests.reloadData()
                        self.getRequests()
                        
                    } else {
                        self.pageNoSent = 1
                        self.hasMoreSent = -1
                        self.dictParams.updateValue(self.pageNoSent, forKey: "page")
                        self.dictParams.updateValue("Sent", forKey: "type")
                        
                        self.sentPosts?.removeAll()
                        self.tvRequests.reloadData()
                        self.getRequests()
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
            
        }
    }
    
    func giveRating() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.giveRating()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GIVE_RATE_REVIEW, parameters: dictParamsGiveRating) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    if self.selectedTabIndex == 0 {
                        self.receivedPosts![self.indexToUpdate].rate = self.dictParamsGiveRating["rate"] as? Double
                    }else {
                        self.sentPosts![self.indexToUpdate].rate = self.dictParamsGiveRating["rate"] as? Double
                    }
                    
                    self.tvRequests.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension RequestsVC: UITableViewDataSource, UITableViewDelegate, FloatRatingViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedTabIndex {
            case 0:
                return receivedPosts?.count ?? 0
            default:
                return sentPosts?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestTVCell", for: indexPath) as! RequestTVCell
        
        var post: PostEventDetail?
        cell.btnPostDetails.tag = indexPath.row
        cell.btnPostDetails.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)
        
        post = selectedTabIndex == 0 ? receivedPosts![indexPath.row] : sentPosts![indexPath.row]
        
        cell.ivItem.setImage(imageUrl: post!.mediaImage!)
        cell.lblTitle.text = post?.title
        cell.lblTime.text = post?.requestTime
        
        cell.widthBtnConfirm.constant = 120.0
        cell.viewRatings.isHidden = true
        cell.btnWriteReview.isHidden = true
        cell.btnConfirm.isHidden = true
        cell.btnReject.isHidden = true
        
        if post?.status == "Pending" {
            
            let firstPart = selectedTabIndex == 0 ? "Requested by " : "Requested to "
            let secondPart = (post?.name)!
            let attributedString = NSMutableAttributedString(string: firstPart + secondPart, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 14.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: (firstPart + secondPart).trimmedString.count))
            attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 14.0), range: NSRange(location: firstPart.count, length: secondPart.count))

            cell.lblReqBy.attributedText = attributedString
            
            
            if (selectedTabIndex == 0) {
                cell.btnConfirm.isHidden = false
                cell.btnReject.isHidden = false
                
                cell.btnConfirm.isEnabled = true
                cell.btnConfirm.setTitle("Confirm", for: .normal)
                cell.btnConfirm.layer.borderColor = Colors.orange.returnColor().cgColor
                cell.btnConfirm.layer.borderWidth = 1.0
                cell.btnConfirm.backgroundColor = Colors.orange.returnColor()
                cell.btnConfirm.setTitleColor(UIColor.white, for: .normal)
                cell.widthBtnConfirm.constant = 100.0
                
                cell.btnReject.setTitle("Reject", for: .normal)
                cell.btnReject.layer.borderWidth = 1.0
                cell.btnReject.layer.borderColor = UIColor.black.cgColor
                cell.btnReject.backgroundColor = UIColor.clear
                cell.btnReject.setTitleColor(UIColor.black, for: .normal)
                
                cell.btnConfirm.removeTarget(nil, action: nil, for: .allEvents)
                cell.btnReject.removeTarget(nil, action: nil, for: .allEvents)
                
                cell.btnConfirm.tag = indexPath.row
                cell.btnReject.tag = indexPath.row
                cell.btnConfirm.addTarget(self, action: #selector(confirmTapped(_:)), for: .touchUpInside)
                cell.btnReject.addTarget(self, action: #selector(rejectTapped(_:)), for: .touchUpInside)
            }else {
                cell.btnConfirm.layer.borderWidth = 1.0
                cell.btnConfirm.setTitle("Requested", for: .normal)
                cell.btnConfirm.layer.borderColor = Colors.gray.returnColor().cgColor
                cell.btnConfirm.layer.backgroundColor = UIColor.white.cgColor
                cell.btnConfirm.setTitleColor(Colors.gray.returnColor(), for: .normal)
                
                cell.btnConfirm.isHidden = false
                cell.btnConfirm.isEnabled = true
                
                cell.btnConfirm.removeTarget(nil, action: nil, for: .allEvents)
                
                cell.btnConfirm.tag = indexPath.row
                cell.btnConfirm.addTarget(self, action: #selector(requestedTapped(_:)), for: .touchUpInside)
            }
        } else if post?.status == "Accepted" {
            
            let firstPart = "Request has been accepted by "
            let secondPart = selectedTabIndex == 0 ? "You" : (post?.name)!
            let attributedString = NSMutableAttributedString(string: firstPart + secondPart, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 12.0)])
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: (firstPart + secondPart).trimmedString.count))
            attributedString.addAttribute(NSAttributedString.Key.font, value: Fonts.Bold.returnFont(size: 12.0), range: NSRange(location: firstPart.count, length: secondPart.count))

            cell.lblReqBy.attributedText = attributedString
            
            if post?.type != "Donate" {
                if (APIManager.sharedManager.user?.id == post?.createdBy && post?.type == "Buy") || (APIManager.sharedManager.user?.id != post?.createdBy && post?.type == "Sell") {
                    
                    cell.btnConfirm.isEnabled = true
                    cell.btnConfirm.isHidden = false
                    cell.btnConfirm.setTitle("Pay \((post?.amount)!)", for: .normal)
                    cell.btnConfirm.layer.borderColor = Colors.orange.returnColor().cgColor
                    cell.btnConfirm.layer.borderWidth = 1.0
                    cell.btnConfirm.backgroundColor = Colors.orange.returnColor()
                    cell.btnConfirm.setTitleColor(UIColor.white, for: .normal)
                    
                    cell.btnConfirm.removeTarget(nil, action: nil, for: .allEvents)
                    
                    cell.btnConfirm.tag = indexPath.row
                    cell.btnConfirm.addTarget(self, action: #selector(payAmountTapped(_:)), for: .touchUpInside)
                    
                }else {
                    cell.btnConfirm.isEnabled = true
                    cell.btnConfirm.isHidden = true
                    cell.btnConfirm.removeTarget(nil, action: nil, for: .allEvents)
                }
                
            } else { //post?.status == "Donate"
                cell.lblReqBy.text = post?.amount == "$0" ? "Free" : "Paid"
                cell.lblReqBy.textColor = Colors.orange.returnColor()
                
                cell.btnConfirm.isHidden = true
                cell.viewRatings.isHidden = false
                cell.viewRatings.delegate = self
                if post?.rate == 0 {
                    cell.viewRatings.rating = 0.0
                    cell.viewRatings.tag = indexPath.row
                    cell.viewRatings.isUserInteractionEnabled = true
                    cell.btnWriteReview.isHidden = true
                    cell.widthViewRatings.constant = 120.0
                }else if post?.review == "" {
                    cell.viewRatings.tag = indexPath.row
                    cell.viewRatings.isUserInteractionEnabled = false
                    cell.viewRatings.rating = Double(post!.rate!)
                    cell.widthViewRatings.constant = 100.0
                    cell.btnWriteReview.isHidden = false
                    cell.btnWriteReview.isEnabled = true
                    
                    cell.btnWriteReview.removeTarget(nil, action: nil, for: .allEvents)
                    cell.btnWriteReview.tag = indexPath.row
                    cell.btnWriteReview.addTarget(self, action: #selector(reviewTapped(_:)), for: .touchUpInside)
                }else {
                    cell.viewRatings.tag = indexPath.row
                    cell.viewRatings.isUserInteractionEnabled = false
                    cell.viewRatings.rating = Double(post!.rate!)
                    cell.btnWriteReview.isHidden = true
                    cell.widthViewRatings.constant = 120.0
                }
            }
        } else { //post?.status == "Paid"
            
            if (APIManager.sharedManager.user?.id == post?.createdBy && post?.type == "Buy") || (APIManager.sharedManager.user?.id != post?.createdBy && post?.type == "Sell") {
                
                cell.lblReqBy.text = post?.amount == "$0" ? "Free" : "Paid"
            }else {
                cell.lblReqBy.text = post?.amount == "$0" ? "Free" : "Receive"
            }
            
            
            cell.lblReqBy.textColor = Colors.orange.returnColor()
            
            cell.btnConfirm.isHidden = true
            cell.viewRatings.isHidden = false
            cell.viewRatings.delegate = self
            
            if post?.rate == 0 {
                cell.viewRatings.rating = 0.0
                cell.viewRatings.tag = indexPath.row
                cell.viewRatings.isUserInteractionEnabled = true
                cell.btnWriteReview.isHidden = true
                cell.widthViewRatings.constant = 120.0
            }else if post?.review == "" {
                cell.viewRatings.tag = indexPath.row
                cell.viewRatings.isUserInteractionEnabled = false
                cell.viewRatings.rating = Double(post!.rate!)
                cell.widthViewRatings.constant = 100.0
                cell.btnWriteReview.isHidden = false
                cell.btnWriteReview.isEnabled = true
                
                cell.btnWriteReview.removeTarget(nil, action: nil, for: .allEvents)
                
                cell.btnWriteReview.tag = indexPath.row
                cell.btnWriteReview.addTarget(self, action: #selector(reviewTapped(_:)), for: .touchUpInside)
            }else {
                cell.viewRatings.tag = indexPath.row
                cell.viewRatings.isUserInteractionEnabled = false
                cell.viewRatings.rating = Double(post!.rate!)
                cell.btnWriteReview.isHidden = true
                cell.widthViewRatings.constant = 120.0
            }
        }
        
        return cell
    }
    
    @objc func onTapPostEvent(_ sender: UIButton) {
        isGoToOtherPage = true
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
        switch selectedTabIndex {
            case 0:
                vc.postId = receivedPosts![sender.tag].postId!
            default:
                vc.postId = sentPosts![sender.tag].postId!
        }
        
        self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func confirmTapped(_ sender: UIButton) {
        var post: PostEventDetail?
        if selectedTabIndex == 0 {
            post = receivedPosts![sender.tag]
            indexToUpdate = sender.tag
            dictParamsAcceptRejectPost.updateValue(post!.id, forKey: "requestId")
            dictParamsAcceptRejectPost.updateValue("Accepted", forKey: "status")
            acceptRejectPost()
        } else {
            post = sentPosts![sender.tag]
        }
    }
    
    @objc func rejectTapped(_ sender: UIButton) {
        var post: PostEventDetail?
        if selectedTabIndex == 0 {
            post = receivedPosts![sender.tag]
            indexToUpdate = sender.tag
            dictParamsAcceptRejectPost.updateValue(post!.id, forKey: "requestId")
            dictParamsAcceptRejectPost.updateValue("Rejected", forKey: "status")
            acceptRejectPost()
        } else {
            post = sentPosts![sender.tag]
        }
    }
    
    @objc func requestedTapped(_ sender: UIButton) {
        var post: PostEventDetail?
        
        post = selectedTabIndex == 0 ? receivedPosts![sender.tag] : sentPosts![sender.tag]
        indexToUpdate = sender.tag
        sendRequest(postId: post!.postId ?? 0)
        
    }
    
    @objc func payAmountTapped(_ sender: UIButton) {
        let post = selectedTabIndex == 0 ? receivedPosts![sender.tag] : sentPosts![sender.tag]
        isGoToOtherPage = true
        let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
        checkoutVC.amount = post.amount!
        checkoutVC.toUserId = post.userId
        checkoutVC.moduleId = post.postId ?? 0
        checkoutVC.ontapUpdate = {
//            self.sentPosts![sender.tag].requestStatus = "Paid"
//            self.tvRequests.reloadData()
        }
        
        self.view!.ffTabVC.navigationController?.pushViewController(checkoutVC, animated: true)
    }
    
    @objc func reviewTapped(_ sender: UIButton) {
        let post = selectedTabIndex == 0 ? receivedPosts![sender.tag] : sentPosts![sender.tag]
        isGoToOtherPage = true
        let giveRateVC = self.storyboard?.instantiateViewController(withIdentifier: "GiveRateReviewVC") as! GiveRateReviewVC
        giveRateVC.module = "Post"
        giveRateVC.moduleId = post.postId ?? 0
        giveRateVC.ratings = post.rate ?? 0.0
        giveRateVC.toUserId = post.userId
        giveRateVC.ontapUpdate = { review in
            if self.selectedTabIndex == 0 {
                self.receivedPosts![sender.tag].review = review
            } else {
                self.sentPosts![sender.tag].review = review
            }
            
            self.tvRequests.reloadData()
        }
        giveRateVC.modalPresentationStyle = .overCurrentContext
        giveRateVC.modalTransitionStyle = .crossDissolve
        self.view!.ffTabVC.present(giveRateVC, animated: true, completion: nil)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        let post = selectedTabIndex == 0 ? receivedPosts![ratingView.tag] : sentPosts![ratingView.tag]
        
        indexToUpdate = ratingView.tag
        dictParamsGiveRating = ["moduleId": post.postId!,
                                "module" : "Post",
                                "toUserId": post.userId,
                                "rate": rating,
                                "review": ""]
        giveRating()
    }
    
}
