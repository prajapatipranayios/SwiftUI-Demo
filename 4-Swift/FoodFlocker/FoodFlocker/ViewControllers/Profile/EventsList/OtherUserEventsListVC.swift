//
//  EventsListVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 10/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class OtherUserEventsListVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    
    @IBOutlet weak var tvContent: UITableView!
    
    @IBOutlet weak var viewEmptyData: UIView!

    @IBOutlet weak var viewPrivateAccount: UIView!
    @IBOutlet weak var lblPrivateMessage: UILabel!
    
    var userId = 0
    var isPrivate = false
    var isFollowing = false
    
    var dictParams = [String: Any]()
    
    var pageNoCreate = 1
    
    var hasMoreCreate = -1
    
    var eventsCreated: [PostEventDetail]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        tvContent.register(UINib(nibName: "EventTVCell", bundle: nil), forCellReuseIdentifier: "EventTVCell")
        tvContent.estimatedRowHeight = 118.0
        tvContent.rowHeight = UITableView.automaticDimension
        
        tvContent.isHidden = true
        viewPrivateAccount.isHidden = true
        viewEmptyData.isHidden = true
        
        if !isPrivate || isFollowing || userId == APIManager.sharedManager.user?.id {
            if eventsCreated == nil {
                dictParams.updateValue(pageNoCreate, forKey: "page")
                dictParams.updateValue(userId, forKey: "userId")
                getEvents()
            } else {
                tvContent.reloadData()
                self.viewEmptyData.isHidden = eventsCreated!.count > 0 ? true : false
                self.tvContent.isHidden = eventsCreated!.count > 0 ? false : true
            }
        }else {
            viewPrivateAccount.isHidden = true
            self.lblPrivateMessage.text = "This Account is Private./nFollow this Account to See their events"
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }

    func setupUI() {
        viewTopContainer.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomRight , .bottomLeft])
        viewTopContainer.layer.masksToBounds = false
        viewTopContainer.layer.shadowRadius = 3.0
        viewTopContainer.layer.shadowOpacity = 0.3
        viewTopContainer.layer.shadowColor = UIColor.gray.cgColor
        viewTopContainer.layer.shadowOffset = CGSize(width: 0 , height:3)
        
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: .white)
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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

    func getEvents() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getEvents()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ALL_USER_Event, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                
                if self.eventsCreated != nil {
                    self.eventsCreated?.append(contentsOf: (response?.result?.eventList)!)
                } else {
                    self.eventsCreated = (response?.result?.eventList)!
                }
                if self.eventsCreated!.count > 0 {
                    self.pageNoCreate += 1
                    self.hasMoreCreate = (response?.result?.hasMore)!
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
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension OtherUserEventsListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsCreated!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTVCell", for: indexPath) as! EventTVCell
        
        var event: PostEventDetail?
        
        event = eventsCreated![indexPath.row]
        cell.widthBtnOptions.constant = 25.0
        cell.btnOptions.isHidden = false
        cell.viewRatings.isHidden = true
        cell.btnReminder.isHidden = true
        cell.btnCancelTicket.isHidden = true
        cell.btnOptions.isHidden = true
        cell.btnConfirmTicket.isHidden = true
        cell.btnOptions.tag = indexPath.row
        cell.btnWriteReview.isHidden = true
        cell.ivEvent.setImage(imageUrl: event!.mediaImage!)
        cell.lblEventTitle.text = event!.title
        cell.lblEventDateTime.text = event!.startDate
        cell.lblEventLocation.text = event!.address
        cell.lblEventDateTime.textColor = event!.isExpire == 1 ? Colors.red.returnColor() : Colors.themeGreen.returnColor()
        
        cell.btnEvent.tag = indexPath.row
        cell.btnEvent.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == eventsCreated!.count - 1 {
            if hasMoreCreate == 1 {
                getEvents()
            }
        }
    }
    
    @objc func onTapPostEvent(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
        vc.eventId = eventsCreated![sender.tag].id
        self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
    }
    
}
