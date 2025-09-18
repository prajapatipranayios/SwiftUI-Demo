//
//  TeamVideosVC.swift
//  - To display list of Videos related to Team

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class TeamVideosVC: UIViewController {

    // MARK: - Controls
    
    @IBOutlet weak var viewTab: UIView!
    @IBOutlet weak var heightViewTab : NSLayoutConstraint!
    @IBOutlet var btnTabVideos : [UIButton]!
    @IBOutlet var lblTabVideos : [UILabel]! {
        didSet {
            for lbl in lblTabVideos {
                lbl.layer.cornerRadius = lbl.frame.size.height / 2
                lbl.layer.masksToBounds = true
            }
        }
    }
    @IBOutlet weak var tvVideos : UITableView!
    
    // MARK: - Variables
    var isComeFromPlayercard: Bool = false
    var teamData: Team?
    var teamVideo: [Highlight]?
    var allVideo: [Highlight]?
    var footerView: AddVideoTVFooterView?
    var headerView: AddVideoTVHeaderView?
    var selectedTab: Int = 0 {
        didSet {
            self.btnTabVideos[0].isSelected = selectedTab == 0
            self.btnTabVideos[1].isSelected = !(selectedTab == 0)
            self.btnTabVideos[0].backgroundColor = selectedTab == 0 ? UIColor.white : Colors.lightGray.returnColor()
            self.btnTabVideos[1].backgroundColor = selectedTab != 0 ? UIColor.white : Colors.lightGray.returnColor()
            self.lblTabVideos[0].backgroundColor = selectedTab == 0 ? Colors.black.returnColor() : UIColor.clear
            self.lblTabVideos[1].backgroundColor = selectedTab != 0 ? Colors.black.returnColor() : UIColor.clear
        }
    }
    
    // 231 - By Pranay
    @IBOutlet weak var lblVideoNotFound: UILabel!
    
    var intIdFromSearch : Int = 0
    // 231 .
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedTab = isComeFromPlayercard == true ? 1 : 0
        
        if isComeFromPlayercard {
            headerView = Bundle.main.loadNibNamed("AddVideoTVHeaderView", owner: self, options: nil)?[0] as? AddVideoTVHeaderView
            headerView?.frame.size = (headerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))!
            headerView?.btnAdd.tag = 3
            headerView?.btnAdd.addTarget(self, action: #selector(uploadVideo(btn:)), for: .touchUpInside)
            tvVideos?.tableHeaderView = headerView
        }else {
            footerView = Bundle.main.loadNibNamed("AddVideoTVFooterView", owner: self, options: nil)?[0] as? AddVideoTVFooterView
            footerView?.frame.size = (footerView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))!
            footerView?.btnAdd.tag = 3
            footerView?.btnAdd.addTarget(self, action: #selector(uploadVideo(btn:)), for: .touchUpInside)
            tvVideos?.tableFooterView = footerView
        }
        
        
        tvVideos.register(UINib(nibName: "TeamVideoCell", bundle: nil), forCellReuseIdentifier: "TeamVideoCell")
        
        self.viewTab.isHidden = true
        self.heightViewTab.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // By Pranay
        self.lblVideoNotFound.isHidden = true
        self.tvVideos.tableHeaderView = nil
        self.tvVideos.tableFooterView = nil
        // .
        
        self.tvVideos.reloadData()
        self.getTeamVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeFooterToFit()
    }
    
    // MARK: - UI Methods

    func sizeFooterToFit() {
        var footer = self.tvVideos.tableFooterView
        if isComeFromPlayercard {
            footer = self.tvVideos.tableHeaderView
        }
        footer?.setNeedsLayout()
        footer?.layoutIfNeeded()
        
        if isComeFromPlayercard {
            headerView?.btnAdd.layer.cornerRadius = (headerView?.btnAdd.frame.size.height)! / 2
            headerView?.btnAdd.layer.masksToBounds = false
            DispatchQueue.main.async {
                self.headerView?.viewContainer.addDashedBorder()
            }
        }else {
            footerView?.btnAdd.layer.cornerRadius = (footerView?.btnAdd.frame.size.height)! / 2
            footerView?.btnAdd.layer.masksToBounds = false
            DispatchQueue.main.async {
                self.footerView?.viewContainer.addDashedBorder()
            }
        }
        
        let height = footer?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = footer?.frame
        frame?.size.height = height!
        footer?.frame = frame!

        if isComeFromPlayercard {
            self.tvVideos.tableHeaderView = footer
        }else {
            self.tvVideos.tableFooterView = footer
        }
    }
    
    @objc func uploadVideo(btn: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
        objVC.uploadYoutubeVideo = { videoCaption,videoLink,thumbUrl,duration,viewCount in
            self.uploadTeamVideo(videoLink: videoLink, caption: videoCaption, thumbUrl: thumbUrl, duration: duration, viewCount: viewCount)
        }
        objVC.titleString = "Add Video"
        objVC.isEdit = false
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @objc func deleteVideo(btn: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.removeVideo
        // By Pranay
        //dialog.message = "Do you want to remove the video with title '\(self.teamVideo![btn.tag].videoCaption)' from this team?" //arrSelected[0].displayName ??
        dialog.message = "Do you want to remove the video  '\(self.teamVideo![btn.tag].videoCaption)'" //arrSelected[0].displayName ??
        // .
        dialog.highlightString = self.teamVideo![btn.tag].videoCaption
        dialog.tapOK = {
            self.deleteTeamVideo(videoId: self.teamVideo![btn.tag].id, index: btn.tag)
        }
        dialog.btnYesText = Messages.remove
        dialog.btnNoText = Messages.cancel
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @objc func editVideo(btn: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
        objVC.EditYoutubeVideo = { videoCaption,duration,index in
            self.editTeamVideo(videoId: self.teamVideo![index].id, index: index, caption: videoCaption)
        }
        objVC.titleString = "Team Highlight Video"
        objVC.isEdit = true
        objVC.index = btn.tag
        objVC.videoUrl = self.teamVideo![btn.tag].videoLink
        objVC.videoCaption = self.teamVideo![btn.tag].videoCaption
        objVC.duration = self.teamVideo![btn.tag].duration
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapTab(_ sender: UIButton) {
            selectedTab = sender.tag
            if selectedTab != 0 {
                if !isComeFromPlayercard {
                    tvVideos.tableFooterView = nil
                    tvVideos.tableHeaderView = footerView
                }
                self.teamVideo = self.allVideo!.filter {
                    $0.userId == APIManager.sharedManager.user?.id
                }
            } else {
                if !isComeFromPlayercard {
                    tvVideos.tableHeaderView = nil
                    tvVideos.tableFooterView = nil
                } else {
                    tvVideos.tableFooterView = footerView
                }
                teamVideo = allVideo
            }
            tvVideos.reloadData()
        }
    
    // MARK: - Webservices
    
    func getTeamVideo() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getTeamVideo()
                }
            }
            return
        }
        
        //self.navigationController?.view.tusslyTabVC.showLoading()
        //let params = ["moduleId": teamData?.id as Any,"moduleType": isComeFromPlayercard == true ? "PLAYER" : "TEAM"] as [String : Any]
        
        /// 232 - By Pranay
        let params = ["moduleId": teamData?.id as Any,"moduleType": isComeFromPlayercard == true ? "PLAYER" : "TEAM", "otherUserId": intIdFromSearch] as [String : Any]    //   By Pranay - added param
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
//            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
//            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.teamVideo?.removeAll()
                    self.allVideo = (response?.result?.videos)!
                    
                    if self.intIdFromSearch == 0 {
                        self.teamVideo = self.allVideo!.filter {
                            $0.userId == APIManager.sharedManager.user?.id
                        }
                    } else {
                        self.teamVideo = self.allVideo
                        if self.teamVideo!.count > 0 {
                            self.lblVideoNotFound.isHidden = true
                        } else {
                            self.lblVideoNotFound.isHidden = false
                        }
                    }
                    
                    if self.isComeFromPlayercard {
                        // By Pranay
                        if self.intIdFromSearch == 0 {
                            self.tvVideos.tableHeaderView = self.headerView
                            self.viewTab.isHidden = true
                            self.heightViewTab.constant = 0
                        } else {
                            self.tvVideos.tableHeaderView = nil
                            //self.tvVideos.tableFooterView = nil
                            self.viewTab.isHidden = true
                            self.heightViewTab.constant = 0
                        }
                        // .
                        
                    }else {
                        //if self.teamVideo!.count == 0 {
                        // By Pranay
                        if self.intIdFromSearch == 0 {
                            self.tvVideos.tableFooterView = self.footerView
                        } else {
                            self.tvVideos.tableFooterView = nil
                            self.tvVideos.tableHeaderView = nil
                        }
                        // .
                        if self.allVideo!.count == 0 {
                            self.viewTab.isHidden = true
                            self.heightViewTab.constant = 0
                            // By Pranay
                            self.selectedTab = 1
                            self.onTapTab(self.btnTabVideos[1])
                            
                            self.lblVideoNotFound.isHidden = true
                            if self.teamData?.teamMemberStatus != 2 {
                                self.lblVideoNotFound.isHidden = false
                                self.selectedTab = 0
                                self.onTapTab(self.btnTabVideos[0])
                            }
                            
                            // .
                        } else {
                            // By Pranay
                            if self.teamData?.teamMemberStatus != 2 {
                                self.viewTab.isHidden = true
                                self.heightViewTab.constant = 0
                            } else {
                                self.viewTab.isHidden = false
                                self.heightViewTab.constant = 51
                            }
                            // .
                            //self.teamVideo = self.allVideo
                            self.selectedTab = 0
                            self.onTapTab(self.btnTabVideos[0])
                        }
                    }
                                        
                   self.tvVideos.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.teamVideo = [Highlight]()
                    self.tvVideos.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func uploadTeamVideo(videoLink: String,caption: String,thumbUrl : String,duration:String, viewCount:String) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadTeamVideo(videoLink: videoLink, caption: caption, thumbUrl: thumbUrl, duration: duration, viewCount: viewCount)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["videoLink": videoLink,"videoCaption" :caption,"moduleId":isComeFromPlayercard ? APIManager.sharedManager.user?.id as Any : teamData?.id as Any,"moduleType": isComeFromPlayercard ? "PLAYER" : "TEAM","thumbnail":thumbUrl,"duration":duration, "viewCount":viewCount] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.UPLOAD_VIDEO, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.getTeamVideo()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func editTeamVideo(videoId: Int,index: Int,caption : String) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.editTeamVideo(videoId: videoId, index: index, caption: caption)
                    
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["videoId": videoId,"videoCaption" :caption] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.EDIT_VIDEO, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.teamVideo?[index].videoCaption = caption
                    let mainIndex = self.allVideo!.firstIndex(where: {$0.id == self.teamVideo![index].id})
                    if mainIndex != nil {
                        self.allVideo?[mainIndex!].videoCaption = caption
                    }
                    self.tvVideos.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
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
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        //let params = ["videoId": videoId]
        
        /// 232 - By Pranay
        let params = ["videoId": videoId, "otherUserId": intIdFromSearch]    //   By Pranay - added param
        /// 232 .
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    let mainIndex = self.allVideo!.firstIndex(where: {$0.id == self.teamVideo![index].id})
                    if mainIndex != nil {
                        self.allVideo?.remove(at: mainIndex!)
                    }
                    self.teamVideo?.remove(at: index)
                    
                    if self.teamVideo!.count == 0 {
                        self.selectedTab = 0
                        if self.isComeFromPlayercard {
                            self.tvVideos.tableHeaderView = self.headerView
                        }else {
                            self.tvVideos.tableFooterView = self.footerView
                        }
                        self.viewTab.isHidden = true
                        self.heightViewTab.constant = 0
                        self.teamVideo = self.allVideo
                    }
                    self.tvVideos.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TeamVideosVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teamVideo?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoCell", for: indexPath) as! TeamVideoCell
        if self.teamVideo != nil {
//            cell.hideAnimation()
            cell.heightViewBtnContainer.constant = selectedTab == 1 ? 16 : 0
            cell.viewBtnContainer.isHidden = selectedTab == 1 ? false : true
            cell.lblUserName.text = selectedTab == 0 ? self.teamVideo![indexPath.row].displayName : ""
            cell.topLblUserName.constant = selectedTab == 0 ? 4 : 0
            cell.ivVideo.setImage(imageUrl: self.teamVideo![indexPath.row].thumbnail)
            cell.lblDuration.text = self.teamVideo![indexPath.row].duration
            cell.lblTitle.text = self.teamVideo![indexPath.row].videoCaption
            cell.lblTime.text = self.teamVideo![indexPath.row].dateTime
            let views : String = self.teamVideo![indexPath.row].viewCount
            cell.lblViews.text = (views == "" ? "0" : views) + " views"
            
            // By Pranay
            cell.onVideoImgTap = { index in
                if UIApplication.shared.canOpenURL(URL(string: self.teamVideo![index].videoLink)!) {
                    //UIApplication.sharedApplication().openURL(youtubeUrl)
                    UIApplication.shared.open(URL(string: self.teamVideo![index].videoLink)!, options: [:], completionHandler: nil)
                } else{
                    //youtubeUrl = NSURL(string:"https://www.youtube.com/watch?v=\(youtubeId)")!
                    //UIApplication.sharedApplication().openURL(youtubeUrl)
                    UIApplication.shared.open(URL(string: self.teamVideo![index].videoLink)!, options: [:], completionHandler: nil)
                }
            }
            
            if intIdFromSearch == 0 && selectedTab == 1 {
                cell.viewBtnContainer.isHidden = false
            } else {
                cell.viewBtnContainer.isHidden = true
            }
            //.
            
            cell.btnEdit.tag = indexPath.row
            cell.btnDelete.tag = indexPath.row
            cell.btnEdit.addTarget(self, action: #selector(editVideo(btn:)), for: .touchUpInside)
            cell.btnDelete.addTarget(self, action: #selector(deleteVideo(btn:)), for: .touchUpInside)
        } else {
//            cell.showAnimation()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
