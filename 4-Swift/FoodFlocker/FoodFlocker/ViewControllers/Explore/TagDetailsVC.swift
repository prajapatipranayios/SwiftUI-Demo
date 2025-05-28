//
//  TagDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class TagDetailsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewOptionsContainer: UIView!
    @IBOutlet weak var lblTag: UILabel!

    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!

    @IBOutlet weak var tvContent: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!
    
    var selectedTabIndex = 0
    
    var dictParams = [String: Any]()

    var posts: [PostEventDetail]?
    var events: [PostEventDetail]?
    
    var pageNoPosts = 1
    var pageNoEvents = 1
    
    var hasMorePosts = -1
    var hasMoreEvents = -1

    var tagToSearch: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvContent.register(UINib(nibName: "PostTVCell", bundle: nil), forCellReuseIdentifier: "PostTVCell")
        tvContent.register(UINib(nibName: "EventTVCell", bundle: nil), forCellReuseIdentifier: "EventTVCell")

        tvContent.rowHeight = UITableView.automaticDimension
        tvContent.estimatedRowHeight = 100.0
        
        dictParams.updateValue(tagToSearch, forKey: "search")
        onTapOptions(btnOptions[selectedTabIndex])
        
        lblTag.text = tagToSearch
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
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(UIColor.white, for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            
            if posts == nil {
                dictParams.updateValue(pageNoPosts, forKey: "page")
                dictParams.updateValue("Post", forKey: "module")
                getSearchPostEvent()
            } else {
                tvContent.reloadData()
                self.viewEmptyData.isHidden = posts!.count > 0 ? true : false
                self.tvContent.isHidden = posts!.count > 0 ? false : true
            }
        } else {
            btnOptions[1].setTitleColor(UIColor.white, for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            
            if events == nil {
                dictParams.updateValue(pageNoEvents, forKey: "page")
                dictParams.updateValue("Event", forKey: "module")
                getSearchPostEvent()
            } else {
                tvContent.reloadData()
                self.viewEmptyData.isHidden = events!.count > 0 ? true : false
                self.tvContent.isHidden = events!.count > 0 ? false : true
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
    func getSearchPostEvent() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getSearchPostEvent()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_SEARCH_POST_EVENT, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.selectedTabIndex == 0 {
                    if self.posts != nil {
                        self.posts?.append(contentsOf: (response?.result?.postList)!)
                    } else {
                        self.posts = (response?.result?.postList)!
                    }
                    if self.posts!.count > 0 {
                        self.pageNoPosts += 1
                        self.hasMorePosts = (response?.result?.hasMore)!
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
                    if self.events != nil {
                        self.events?.append(contentsOf: (response?.result?.eventList)!)
                    } else {
                        self.events = (response?.result?.eventList)!
                    }
                    if self.events!.count > 0 {
                        self.pageNoEvents += 1
                        self.hasMoreEvents = (response?.result?.hasMore)!
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

extension TagDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTabIndex == 0 {
            return posts!.count
        } else {
            return events!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTabIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTVCell", for: indexPath) as! PostTVCell
            let post = posts![indexPath.row]
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

            cell.lblPostType.text = post.type
            cell.lblPostCategory.text = post.category

            cell.btnPost.tag = indexPath.row
            cell.btnPost.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)

            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventTVCell", for: indexPath) as! EventTVCell
            
            let event = events![indexPath.row]
            
            cell.ivEvent.setImage(imageUrl: event.mediaImage!)
            cell.lblEventTitle.text = event.title
            cell.lblEventDateTime.text = event.startDate
            cell.lblEventLocation.text = event.address
            
            cell.widthBtnOptions.constant = 0
            cell.btnOptions.isHidden = true
            cell.viewRatings.isHidden = true
            cell.btnReminder.isHidden = true
            cell.btnCancelTicket.isHidden = true
            cell.btnConfirmTicket.isHidden = true
            cell.btnWriteReview.isHidden = true

            cell.lblEventDateTime.textColor = event.isExpire == 1 ? Colors.red.returnColor() : Colors.themeGreen.returnColor()
            
            cell.btnEvent.tag = indexPath.row
            cell.btnEvent.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTabIndex == 0 {
            if indexPath.row == posts!.count - 1 {
                if hasMorePosts == 1 {
                    getSearchPostEvent()
                }
            }
        } else {
            if indexPath.row == events!.count - 1 {
                if hasMoreEvents == 1 {
                    getSearchPostEvent()
                }
            }
        }
    }
    
    @objc func onTapPostEvent(_ sender: UIButton) {
        if selectedTabIndex == 0 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
            vc.postId = posts![sender.tag].id
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        }else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
            vc.eventId = events![sender.tag].id
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

