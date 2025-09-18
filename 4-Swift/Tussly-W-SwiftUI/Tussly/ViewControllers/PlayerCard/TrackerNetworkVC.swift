//
//  TrackerNetworkVC.swift
//  Tussly
//
//  Created by Auxano on 23/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class TrackerNetworkVC: UIViewController {
    
    // MARK: - Variables.
    var playerTabVC: (()->PlayerCardTabVC)?
    var arrGetGames = [Game]()
    var arrNetwork = [Networks]()
    
    // MARK: - Controls
    @IBOutlet weak var tvTracker : UITableView!
    @IBOutlet weak var btnAdd : UIButton!
    @IBOutlet weak var btnSave : UIButton!
    @IBOutlet weak var viewTracker : UIView!
    @IBOutlet weak var tvHeight : NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSave.isHidden = true
        btnSave.layer.cornerRadius = 15.0
        btnAdd.layer.cornerRadius = 15.0
        self.viewTracker.frame = CGRect(x: self.viewTracker.frame.origin.x, y: self.viewTracker.frame.origin.x, width: self.view.frame.size.width - 48, height: self.viewTracker.frame.size.height)
        self.viewTracker.addDashedBorder()
        self.tvHeight.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGames()
        tvTracker.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tvTracker.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.tvTracker!.observationInfo != nil {
            tvTracker.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    // MARK: - UI Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            self.tvHeight.constant = tvTracker.contentSize.height
            self.updateViewConstraints()
        }
    }
    
    // MARK: - IB Actions
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        playerTabVC!().selectedIndex = -1
    }
    
    @IBAction func onTapSave(_ sender: UIButton) {
        
    }
    
    @IBAction func onTapAdd(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTrackerNetworkVC") as! AddTrackerNetworkVC
        objVC.didSelectGame = {
            self.getTrackerNetwork()
        }
        objVC.isEditedId = 0
        objVC.arrGameList = self.arrGetGames
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    func getGames() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getGames()
                }
                return
                     }
           }
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_GAMES, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrGetGames = (response?.result?.games)!
                    self.getTrackerNetwork()
                }
            } else {
                DispatchQueue.main.async {
                    //Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.getTrackerNetwork()
                }
            }
        }
    }
    
    func getTrackerNetwork() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTrackerNetwork()
                }
            }
            return
        }
    
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_TRACKER_NETWORK, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrNetwork = (response?.result?.networks)!
                    self.tvTracker.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func removeTrackerNetwork(index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removeTrackerNetwork(index: self.arrNetwork[index].id!)
                }
            }
            return
        }
    
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_TRACKER_NETWORK, parameters: ["id" : arrNetwork[index].id!]) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.arrNetwork.remove(at: index)
                    self.tvTracker.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - TableView Methods
extension TrackerNetworkVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNetwork.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        cell.lblTitle.text = arrNetwork[indexPath.row].title ?? ""
        cell.ivProfile.setImage(imageUrl: arrNetwork[indexPath.row].gameImage ?? "")
        cell.lblMessage.text = arrNetwork[indexPath.row].gameName ?? ""
        cell.index = indexPath.row
        
        cell.onTapRemove = { index in
            self.removeTrackerNetwork(index: index)
        }
        
        cell.onTapEdit = { index in
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTrackerNetworkVC") as! AddTrackerNetworkVC
            objVC.didSelectGame = {
                self.getTrackerNetwork()
            }
            objVC.editData = ["title":self.arrNetwork[index].title, "url":self.arrNetwork[index].trackerNetworkUrl]
            objVC.arrGameList = self.arrGetGames
            objVC.isEditedId = self.arrNetwork[index].id!
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
}
