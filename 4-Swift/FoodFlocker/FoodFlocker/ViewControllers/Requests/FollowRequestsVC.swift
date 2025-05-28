//
//  FollowRequestsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 23/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class FollowRequestsVC: UIViewController {

	//Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var tvRequests: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!

    var followRequests: [UserRequest]?
    var hasMore = -1
    var pageNumber = 1
    
    var followUserParams = Dictionary<String, Any>()
    var indexToUpdate = -1


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        getFollowRequests()
    }
    
    func setupUI() {
        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
    }
    
    // MARK: - WebServices
    
    func getFollowRequests() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFollowRequests()
                }
            }
            return
        }
        
        let params = ["page": pageNumber]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_USER_REQUESTS, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.followRequests != nil {
                    self.followRequests?.append(contentsOf: (response?.result?.userList)!)
                } else {
                    self.followRequests = (response?.result?.userList)!
                }
                if self.followRequests!.count > 0 {
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
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ACCEPT_REJECT_USER_REQUEST, parameters: followUserParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                self.followRequests?.remove(at: self.indexToUpdate)
                DispatchQueue.main.async {
                    self.tvRequests.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
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

}

extension FollowRequestsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followRequests!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowRequestCell", for: indexPath) as! FollowRequestCell
        
        let request = followRequests![indexPath.row]
        
        cell.ivUser.setImage(imageUrl: request.profilePic)
        cell.lblUserName.text = request.name
        cell.lblUserType.text = request.userName
        
        cell.btnApprove.tag = indexPath.row
        cell.btnApprove.addTarget(self, action: #selector(btnApproveTapped(_:)), for: .touchUpInside)

        cell.btnReject.tag = indexPath.row
        cell.btnReject.addTarget(self, action: #selector(btnRejectTapped(_:)), for: .touchUpInside)
        
        cell.btnUser.tag = indexPath.row
        cell.btnUser.addTarget(self, action: #selector(onTapUser(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == followRequests!.count - 1 {
            if hasMore == 1 {
                getFollowRequests()
            }
        }
    }
    
    @objc func btnApproveTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        let request = followRequests![sender.tag]
        followUserParams.updateValue(request.requestId ?? 0, forKey: "requestId")
        followUserParams.updateValue("Accepted", forKey: "status")
        followUnFollowUser()
    }
    
    @objc func btnRejectTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        let request = followRequests![sender.tag]
        followUserParams.updateValue(request.requestId ?? 0, forKey: "requestId")
        followUserParams.updateValue("Rejected", forKey: "status")
        followUnFollowUser()
    }
    
    @objc func onTapUser(_ sender: UIButton) {
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileVC.userId = followRequests![sender.tag].userId
        self.view.ffTabVC.navigationController?.pushViewController(profileVC, animated: true)
    }
}
