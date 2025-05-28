//
//  NotificationsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!

    //View Header
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var ivFollower: UIImageView!
    @IBOutlet weak var ivArrow: UIImageView!

    @IBOutlet weak var tvNotifications: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!

    var notifications: [Notification]?
    var hasMore = -1
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        getNotifications()
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        
        ivFollower.layer.cornerRadius = ivFollower.frame.size.width / 2
        ivFollower.clipsToBounds = true

        ivArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
    }

    // MARK: - Button Click Events
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkFollowerRequestsTapped(_ sender: UIButton) {
        let requestsVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowRequestsVC") as! FollowRequestsVC

        self.view.ffTabVC.navigationController?.pushViewController(requestsVC, animated: true)
    }
    
    // MARK: - WebServices
    
    func getNotifications() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getNotifications()
                }
            }
            return
        }
        
        let params = ["page": pageNumber]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_NOTIFICATIONS, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.notifications != nil {
                    self.notifications?.append(contentsOf: (response?.result?.notifications)!)
                } else {
                    self.notifications = (response?.result?.notifications)!
                }
                
                if self.notifications!.count > 0 {
                    self.pageNumber += 1
                    self.hasMore = (response?.result?.hasMore)!
                    DispatchQueue.main.async {
                        self.viewEmptyData.isHidden = true
                        self.tvNotifications.isHidden = false
                        self.tvNotifications.dataSource = self
                        self.tvNotifications.delegate = self
                        self.tvNotifications.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.tvNotifications.isHidden = true
                        self.viewEmptyData.isHidden = false
                    }
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

extension NotificationsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVCell", for: indexPath) as! NotificationTVCell
        
        let notif = notifications![indexPath.row]
        
        cell.ivNotif.setImage(imageUrl: notif.profilePic)
        
        cell.lblNotif.attributedText = notif.description.htmlToAttributedString
        cell.lblDuration.text = notif.notificationTime
        
        if notif.isRead == 0 {
            cell.viewBackground.backgroundColor = .white
            cell.viewBackground.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 5.0, opacity: 0.5)
            cell.seprater.isHidden = true
        }else {
            cell.viewBackground.backgroundColor = Colors.light.returnColor()
            cell.seprater.isHidden = false
            cell.viewBackground.addShadow(offset: CGSize(width: 0.0, height: 0.0), color: Colors.gray.returnColor(), radius: 0.0, opacity: 0.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == notifications!.count - 1 {
            if hasMore == 1 {
                getNotifications()
            }
        }
    }
}
