//
//  ViewImageVideoVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 13/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewImageVideoVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewContainer: UIView!

    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var ivMedia: UIImageView!
    @IBOutlet weak var ivUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var btnVolume: UIButton!

    
//    @IBOutlet weak var btnVideoIndicator: UIButton!
    @IBOutlet weak var btnFollowing: UIButton!
    @IBOutlet weak var widthBtnFollowing: NSLayoutConstraint!


    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var media: Media?
    var chat: ChatMessage?
    var profilePicURL: String?
    var name: String?
    var userName: String?
    var userId: Int?
    
    var removed: ((Bool)->Void)?
    
    var isViewPost: Bool = false
    var isComeFromChat: Bool = false
    
    let avPlayer = AVQueuePlayer()
    var avPlayerLayer: AVPlayerLayer!
    var avPlayerLooper: AVPlayerLooper!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        self.btnVolume.setImage(self.avPlayer.isMuted ? UIImage(named: "volume_mute_icon") : UIImage(named: "volume_full_icon"), for: .normal)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 20.0
        
        if isComeFromChat {
            ivUser.isHidden = true
            lblName.isHidden = true
            lblUserName.isHidden = true
            btnDelete.isHidden = true
            btnFollowing.isHidden = true
            
            if chat!.messageType == "IMAGE" {
                ivMedia.setImage(imageUrl: chat!.messageUrl)
                videoContainer.isHidden = true
                ivMedia.isHidden = false
                btnVolume.isHidden = true
            } else {
                btnVolume.isHidden = false
                ivMedia.isHidden = false
                videoContainer.isHidden = false
                self.setSelectedVideoInPlayer(path: URL(string: chat!.messageUrl)!)
            }
        }else {
            if self.userId == APIManager.sharedManager.user?.id {
                self.btnFollowing.isHidden = true
                self.widthBtnFollowing.constant = 0.0
                self.btnFollowing.isHidden = true
                self.widthBtnFollowing.constant = 0
                self.btnDelete.isHidden = false
            }else {
                self.btnFollowing.setTitle((self.media?.followingStatus)! == "" ? "Follow" : ((self.media?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                self.btnFollowing.layer.borderColor = (self.media?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.media?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                self.btnFollowing.setTitleColor((self.media?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.media?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                self.btnFollowing.backgroundColor = (self.media?.followingStatus)! == "" ? UIColor.clear : ((self.media?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                
                btnFollowing.isHidden = false
                widthBtnFollowing.constant = 90.0
                btnDelete.isHidden = true
            }
            
            if media!.mediaType == "Image" {
                ivMedia.setImage(imageUrl: media!.mediaImage!)
                videoContainer.isHidden = true
                ivMedia.isHidden = false
                btnVolume.isHidden = true
            } else {
                btnVolume.isHidden = false
                ivMedia.isHidden = true
                videoContainer.isHidden = false
                self.setSelectedVideoInPlayer(path: URL(string: media!.videoUrl!)!)
            }
            
            ivUser.setImage(imageUrl: profilePicURL!)
            lblName.text = name!
            lblUserName.text = userName!
        }
    }
    
    func setupUI() {
        self.btnFollowing.layer.cornerRadius = self.btnFollowing.frame.size.height / 2
        self.btnFollowing.layer.borderWidth = 1.0
        self.btnFollowing.layer.borderColor = Colors.themeGreen.returnColor().cgColor

        self.ivUser.layer.cornerRadius = self.ivUser.frame.size.height / 2
        self.ivUser.clipsToBounds = true
        self.ivUser.layer.borderWidth = 1.0
        self.ivUser.layer.borderColor = UIColor.white.cgColor
        self.ivMedia.layer.cornerRadius = 10.0
        self.videoContainer.layer.cornerRadius = 10.0
        self.videoContainer.clipsToBounds = true
    }
    
    func setSelectedVideoInPlayer(path: URL) {
        let playerItem = AVPlayerItem(url: path)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoContainer.bounds
        avPlayerLooper = AVPlayerLooper(player: avPlayer, templateItem: playerItem)
        
        videoContainer.layer.insertSublayer(avPlayerLayer, at: 0)
        videoContainer.layer.masksToBounds = true
        avPlayer.play()
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteMediaTapped(_ sender: Any) {
        deleteMediaPost()
    }
    
    @IBAction func volumeTapped(_ sender: Any) {
        self.avPlayer.isMuted = !self.avPlayer.isMuted
        self.btnVolume.setImage(self.avPlayer.isMuted ? UIImage(named: "volume_mute_icon") : UIImage(named: "volume_full_icon"), for: .normal)
    }
    
    @IBAction func followingTapped(_ sender: Any) {
        followUser()
    }
    
    // MARK: - Webservices

    func deleteMediaPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.deleteMediaPost()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_MEDIA_POST, parameters: ["postId": media!.postId!]) { (response: ApiResponse?, error) in
            self.hideLoading()
            
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
            
            DispatchQueue.main.async {
                if self.removed != nil {
                    self.removed!(response?.status != nil && response?.status == 1 ? true : false)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func followUser() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.followUser()
                }
            }
            return
        }
        
        let dictParams = ["toUserId": media!.userId!] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.FOLLOW_UNFOLLOW_USER, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if let isFollow = self.media?.isFollowing! {
                        self.media?.isFollowing = 1 - isFollow
                    }
                    
                    let value: String = (self.media?.isFollowing == 0) ? "" : ((self.media?.isFollowing == 1 && self.media?.accountType == "Private") ? "Pending" : "Following")
                    self.media?.followingStatus = value
                    
                    self.btnFollowing.setTitle((self.media?.followingStatus)! == "" ? "Follow" : ((self.media?.followingStatus)! == "Pending" ? "Requested" : "Following"), for: .normal)
                    self.btnFollowing.layer.borderColor = (self.media?.followingStatus)! == "" ? Colors.themeGreen.returnColor().cgColor : ((self.media?.followingStatus)! == "Pending" ? Colors.gray.returnColor().cgColor : Colors.themeGreen.returnColor().cgColor)
                    self.btnFollowing.setTitleColor((self.media?.followingStatus)! == "" ? Colors.themeGreen.returnColor() : ((self.media?.followingStatus)! == "Pending" ? Colors.gray.returnColor() : .white), for: .normal)
                    self.btnFollowing.backgroundColor = (self.media?.followingStatus)! == "" ? UIColor.clear : ((self.media?.followingStatus)! == "Pending" ? UIColor.clear : Colors.themeGreen.returnColor())
                    
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
