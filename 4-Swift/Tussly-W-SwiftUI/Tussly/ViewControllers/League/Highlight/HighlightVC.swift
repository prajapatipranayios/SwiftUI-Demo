//
//  HighlightVC.swift
//  - Designed Highlight screen for League Module

//  Tussly
//
//  Created by Auxano on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class HighlightVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var viewSkeleten : UIView!
    @IBOutlet weak var btnUploadVideo : UIButton!
    @IBOutlet weak var viewContainer : UIView!
    @IBOutlet weak var viewTab : UIView!
    @IBOutlet weak var heightViewTab: NSLayoutConstraint!
    @IBOutlet weak var btnLeft : UIButton!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblWeek : UILabel!
    @IBOutlet weak var lblDummy : UILabel!
    @IBOutlet weak var btnAllHighlight : UIButton!
    @IBOutlet weak var btnMyHighlight : UIButton!
    @IBOutlet weak var cvAllHighlight: UICollectionView!
    @IBOutlet weak var cvMyHighlight: UICollectionView!
    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var heightCvAllHighlight : NSLayoutConstraint!
    @IBOutlet weak var heightCvMyHighlight : NSLayoutConstraint!
    @IBOutlet var bottomCvAllHighlight : NSLayoutConstraint!
    @IBOutlet var bottomCvMyHighlight : NSLayoutConstraint!
    
    // MARK: - Variables
    
    var currentWeek: Int = -1
    var maxWeekCount: Int = -1
    var highlightData = [Highlight]()
    var myHighlight = [Highlight]()
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentWeek = leagueTabVC!().currentWeek
        self.maxWeekCount = leagueTabVC!().currentWeek
        lblWeek.text = "Week \(currentWeek)"
        btnLeft.isHidden = true
        viewContainer.isHidden = true
        DispatchQueue.main.async {
            self.btnUploadVideo.layer.cornerRadius = self.btnUploadVideo.frame.size.height / 2
            self.btnUploadVideo.clipsToBounds = true
            if self.leagueTabVC!().userRole?.canPostVideo == 0 {
                self.btnUploadVideo.isHidden = true
                self.viewTab.isHidden = true
                self.heightViewTab.constant = 0
            }
            self.viewSkeleten.isHidden = false
//            self.viewSkeleten.showAnimatedSkeleton()
        }
        
        self.layoutCells()
        btnAllHighlight.isSelected = true
        cvAllHighlight.tag = 0
        cvMyHighlight.tag = 1
        
        getHighlight(onLoad: true)
    }
    
    // MARK: - UI Methods
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = cvAllHighlight.frame.size
        layout.scrollDirection = .horizontal
        self.cvAllHighlight.setCollectionViewLayout(layout, animated: true)
        self.cvAllHighlight.isPagingEnabled = true
        self.cvAllHighlight.isScrollEnabled = false
        let layoutMyHighlights = UICollectionViewFlowLayout()
        layoutMyHighlights.minimumInteritemSpacing = 0.0
        layoutMyHighlights.minimumLineSpacing = 0.0
        layoutMyHighlights.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        layoutMyHighlights.itemSize = CGSize(width: cvMyHighlight.frame.size.width, height: cvMyHighlight.frame.size.width * 4.5 / 5 - 80)
        layoutMyHighlights.scrollDirection = .vertical
        self.cvMyHighlight.setCollectionViewLayout(layoutMyHighlights, animated: true)
        
    }
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapUploadVideo(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "UploadVideoVC") as! UploadVideoVC
        objVC.uploadYoutubeVideo = { videoCaption,videoLink,thumbUrl,duration,viewCount in
            self.uploadVideo(videoLink: videoLink, caption: videoCaption, thumbUrl: thumbUrl, duration: duration, viewCount: viewCount)
        }
        objVC.titleString = "Upload Video"
        objVC.isEdit = false
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.view!.tusslyTabVC.present(objVC, animated: true, completion: nil)
    }
    
    @IBAction func onTapTab(_ sender: UIButton) {
        if sender.tag == 0 { //All Highlights
            self.btnAllHighlight.isSelected = true
            self.btnMyHighlight.isSelected = false
            self.btnAllHighlight.backgroundColor = UIColor.white
            self.btnAllHighlight.setTitleColor(Colors.black.returnColor(), for: .selected)
            self.btnMyHighlight.backgroundColor = Colors.black.returnColor()
            self.btnMyHighlight.setTitleColor(UIColor.white, for: .normal)
            self.btnLeft.isHidden = self.currentWeek == 1 ? true : false
            self.btnRight.isHidden = self.currentWeek == self.maxWeekCount ? true : false
            self.heightCvAllHighlight.constant = cvAllHighlight.frame.size.width * 4.5 / 5
            cvAllHighlight.isHidden = false
            cvMyHighlight.isHidden = true
            bottomCvAllHighlight.isActive = true
            bottomCvMyHighlight.isActive = false
            cvAllHighlight.reloadData()
        } else { //My Highlights
            self.cvMyHighlight.dataSource = self
            self.cvMyHighlight.delegate = self
            self.cvMyHighlight.reloadData()
            cvAllHighlight.isHidden = true
            cvMyHighlight.isHidden = false
            bottomCvMyHighlight.isActive = true
            bottomCvAllHighlight.isActive = false
            self.btnAllHighlight.isSelected = false
            self.btnMyHighlight.isSelected = true
            self.btnMyHighlight.backgroundColor = UIColor.white
            self.btnMyHighlight.setTitleColor(Colors.black.returnColor(), for: .selected)
            self.btnAllHighlight.backgroundColor = Colors.black.returnColor()
            self.btnAllHighlight.setTitleColor(UIColor.white, for: .normal)
            self.btnLeft.isHidden = true
            self.btnRight.isHidden = true
            self.heightCvMyHighlight.constant = (self.cvMyHighlight.frame.size.width * 4.5 / 5 - 80 + 16) * CGFloat(self.myHighlight.count)
        }
    }
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            currentWeek = currentWeek != 1 ? currentWeek - 1 : currentWeek
        } else {
            currentWeek = currentWeek != maxWeekCount ? currentWeek + 1 : currentWeek
        }
        btnLeft.isHidden = currentWeek == 1 ? true : false
        btnRight.isHidden = currentWeek == maxWeekCount ? true : false
        lblWeek.text = "Week \(currentWeek)"
        self.cvAllHighlight.scrollToItem(at: IndexPath(item: 0, section: self.currentWeek - 1), at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.cvAllHighlight.reloadData()
        }
    }
    
    @objc func deleteVideo(btn: UIButton) {
        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "CustomDialog") as! CustomDialog
        dialog.modalPresentationStyle = .overCurrentContext
        dialog.modalTransitionStyle = .crossDissolve
        dialog.titleText = Messages.deleteHighlight
        dialog.message = "Do you want to delete the video highlight of 'week \(myHighlight[btn.tag].weekNo)'?"
        dialog.highlightString = "'week \(myHighlight[btn.tag].weekNo)'"
        dialog.btnYesText = Messages.delete
        dialog.btnNoText = Messages.cancel
        dialog.tapOK = {
            self.deleteHighlightVideo(videoId:self.myHighlight[btn.tag].id,index: btn.tag)
        }
        self.view!.tusslyTabVC.present(dialog, animated: true, completion: nil)
    }
    
    @objc func playVideo(btn: UIButton) {
        if let url = URL(string: myHighlight[btn.tag].videoLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK: - Webservices
    
    func getHighlight(onLoad : Bool) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getHighlight(onLoad: onLoad)
                }
            }
            return
        }
        
//        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["moduleId": leagueTabVC!().tournamentDetail?.id ?? 0,"moduleType":"LEAGUE"] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
                
                if response?.status == 1 {
                    self.viewSkeleten.isHidden = true
//                    self.viewSkeleten.hideSkeleton()
                    self.highlightData = (response?.result?.videos)!
                    self.myHighlight = self.highlightData.filter {
                        $0.userId == APIManager.sharedManager.user?.id
                    }
                    
                    if onLoad {
                        self.cvAllHighlight.dataSource = self
                        self.cvAllHighlight.delegate = self
                        self.onTapTab(self.btnAllHighlight)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            self.cvAllHighlight.reloadData()
                        }
                    } else {
                        if self.btnAllHighlight.isSelected {
                            self.onTapTab(self.btnAllHighlight)
                        } else {
                            self.onTapTab(self.btnMyHighlight)
                        }
                    }
                    if self.highlightData.count == 0 {
                        self.viewContainer.isHidden = false
                    } else {
                        self.viewContainer.isHidden = true
                    }
                    if self.myHighlight.count == 0 {
                        self.viewTab.isHidden = true
                        self.heightViewTab.constant = 0
                    } else {
                        self.viewTab.isHidden = false
                        self.heightViewTab.constant = 51
                    }
                } else {
                    self.viewSkeleten.isHidden = true
//                    self.viewSkeleten.hideSkeleton()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
            
        }
    }
    
    func deleteHighlightVideo(videoId: Int,index: Int) {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.deleteHighlightVideo(videoId: videoId, index: index)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["videoId": videoId]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_VIDEOS, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    let mainIndex = self.highlightData.firstIndex(where: {$0.id == self.myHighlight[index].id})
                    if mainIndex != nil {
                        self.highlightData.remove(at: mainIndex!)
                    }
                    self.myHighlight.remove(at: index)
                    self.cvMyHighlight.reloadData()
                    self.heightCvMyHighlight.constant = (self.cvMyHighlight.frame.size.width * 4.5 / 5 - 80 + 16) * CGFloat(self.myHighlight.count)
                    if self.myHighlight.count == 0 {
                        self.onTapTab(self.btnAllHighlight)
                        self.viewTab.isHidden = true
                        self.heightViewTab.constant = 0
                    }
                    
                    if self.highlightData.count == 0 {
                        self.viewContainer.isHidden = false
                    } else {
                        self.viewContainer.isHidden = true
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func uploadVideo(videoLink: String,caption: String,thumbUrl : String,duration:String, viewCount: String) {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadVideo(videoLink: videoLink, caption: caption, thumbUrl: thumbUrl, duration: duration, viewCount: viewCount)
                }
            }
            return
        }
        
        self.navigationController?.view.tusslyTabVC.showLoading()
        let params = ["videoLink": videoLink,"videoCaption" :caption,"moduleId":leagueTabVC!().tournamentDetail?.id ?? 0,"moduleType":"LEAGUE","thumbnail":thumbUrl,"duration":duration,"weekNo":leagueTabVC!().currentWeek, viewCount: viewCount] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.UPLOAD_VIDEO, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                self.navigationController?.view.tusslyTabVC.hideLoading()
            }
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.getHighlight(onLoad: false)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}
    
    // MARK: - UICollectionViewDelegate
    
    extension HighlightVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            if collectionView.tag == 0 {
                return maxWeekCount
            } else {
                return myHighlight.count
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView.tag == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HighlightCell", for: indexPath) as! HighlightCell
                cell.index = indexPath.section
                let currentWeekData = self.highlightData.filter{
                    $0.weekNo == currentWeek
                }
                cell.onTapUpload = {
                    self.onTapUploadVideo(self.btnUploadVideo)
                }
                cell.setupHighlighCvCell(allHighlight: currentWeekData,teamName : leagueTabVC!().teamName, isPostVideo: self.leagueTabVC!().userRole?.canPostVideo ?? 0)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyHighlightCell", for: indexPath) as! MyHighlightCell
                cell.btnDelete.tag = indexPath.section
                if self.leagueTabVC!().userRole?.canDeleteOwnVideo == 0 {
                    cell.btnDelete.isHidden = true
                } else {
                    cell.btnDelete.addTarget(self, action: #selector(deleteVideo(btn:)), for: .touchUpInside)
                }
                cell.btnPlay.tag = indexPath.section
                cell.btnPlay.addTarget(self, action: #selector(playVideo(btn:)), for: .touchUpInside)
                cell.ivVideo.setImage(imageUrl: myHighlight[indexPath.section].thumbnail)
                cell.lblVideoName.text = "Week \(myHighlight[indexPath.section].weekNo)"
                return cell
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionView.tag == 0 ? collectionView.frame.size : CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.width * 4.5 / 5 - 80)
        }
    }
