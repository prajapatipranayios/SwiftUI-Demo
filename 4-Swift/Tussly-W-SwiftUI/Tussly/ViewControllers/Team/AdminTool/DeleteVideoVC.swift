//
//  DeleteVideoVC.swift
//  - User can able to delete Video according to his rights from this screen.

//  Tussly
//
//  Created by Auxano on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class DeleteVideoVC: UIViewController {
    
    // MARK: - Controls
    @IBOutlet weak var tvVideo : UITableView!
    @IBOutlet weak var btnDelete: UIButton!
    
    // MARK: - Variables
    var selectedIndex = -1
    var allVideo: [Highlight]?
    
    var teamData: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvVideo.reloadData()
        setupUI()
        tvVideo.register(UINib(nibName: "TeamVideoCell", bundle: nil), forCellReuseIdentifier: "TeamVideoCell")
        getVideo()
    }
    
    // MARK: - UI Methods
    
    func setupUI() {
        btnDelete.isEnabled = false
        btnDelete.backgroundColor = Colors.themeDisable.returnColor()
        tvVideo.rowHeight = UITableView.automaticDimension
        tvVideo.estimatedRowHeight = 100.0
        DispatchQueue.main.async {
            self.btnDelete.layer.cornerRadius = self.btnDelete.frame.size.height/2
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapDelete(_ sender: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.removeVideo
        dialog.message = "Do you want to remove the video with title '\(self.allVideo![selectedIndex].videoCaption)' from this team?"
        dialog.highlightString = self.allVideo![selectedIndex].videoCaption
        dialog.tapOK = {
            self.deleteTeamVideo(videoId: self.allVideo![self.selectedIndex].id, index: self.selectedIndex)
        }
        dialog.btnYesText = Messages.remove
        dialog.btnNoText = Messages.cancel
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    // MARK: - Webservices
    
    func getVideo() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getVideo()
                }
            }
            return
        }
        
        //showLoading()
        let params = ["moduleId": teamData?.id as Any,"moduleType":"TEAM"] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            //self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.allVideo?.removeAll()
                    self.allVideo = (response?.result?.videos)!
                   self.tvVideo.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.allVideo = [Highlight]()
                    self.tvVideo.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func deleteTeamVideo(videoId: Int,index: Int) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.deleteTeamVideo(videoId: videoId, index: index)
                }
            }
            return
        }
        
        showLoading()
        let params = ["videoId": videoId]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.allVideo?.remove(at: index)
                    self.tvVideo.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DeleteVideoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allVideo?.count ?? 1 //  default 5 to 1 - By Pranay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoCell", for: indexPath) as! TeamVideoCell
        if allVideo != nil {
//            cell.hideAnimation()
            cell.heightViewBtnContainer.constant = 16
            cell.viewBtnContainer.isHidden = true
            cell.lblUserName.text = allVideo![indexPath.row].displayName
            cell.ivVideo.setImage(imageUrl: allVideo![indexPath.row].thumbnail)
            cell.lblDuration.text = allVideo![indexPath.row].duration
            cell.lblTitle.text = allVideo![indexPath.row].videoCaption
            cell.topLblUserName.constant = 4
            cell.ivSelection.isHidden = true
            if selectedIndex == indexPath.row {
                cell.ivSelection.isHidden = false
            }
        } else {
//            cell.showAnimation()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tvVideo.reloadData()
        btnDelete.isEnabled = true
        btnDelete.backgroundColor = Colors.theme.returnColor()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
