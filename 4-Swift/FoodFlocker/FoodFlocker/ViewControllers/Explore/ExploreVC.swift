//
//  ExploreVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ExploreVC: UIViewController {

    //Outlets
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var cvMedias: UICollectionView!
    @IBOutlet weak var viewEmptyData: UIView!
    
    var hasMoreMedias = -1
    var pageNumberMedia = 1
    
    var medias: [Media]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        layoutCells()

        tfSearch.delegate = self
        
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.medias?.removeAll()
        self.hasMoreMedias = -1
        self.pageNumberMedia = 1
        
        getFollowerPosts()
    }
    
    func setupUI() {
        tfSearch.layer.cornerRadius = tfSearch.frame.size.height / 2
        tfSearch.backgroundColor = Colors.light.returnColor()
        tfSearch.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: tfSearch.frame.height))
        tfSearch.leftViewMode = .always
    }

    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (cvMedias.frame.size.width - 16)/3, height: (cvMedias.frame.size.width - 16)/3)
        layout.scrollDirection = .vertical
        self.cvMedias.setCollectionViewLayout(layout, animated: true)
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

    func getFollowerPosts() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getFollowerPosts()
                }
            }
            return
        }
        
        let dictParams = ["page": pageNumberMedia]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_FOLLOWER_POST, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    if self.medias != nil {
                        self.medias?.append(contentsOf: (response?.result?.mediaList)!)
                    } else {
                        self.medias = (response?.result?.mediaList)!
                    }
                    
                    if self.medias!.count > 0 {
                        self.pageNumberMedia += 1
                        self.hasMoreMedias = (response?.result?.hasMore)!
                        self.viewEmptyData.isHidden = true
                        self.cvMedias.isHidden = false
                        self.cvMedias.dataSource = self
                        self.cvMedias.delegate = self
                        self.cvMedias.reloadData()
                    } else {
                        self.viewEmptyData.isHidden = false
                        self.cvMedias.isHidden = true
                    }
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.viewEmptyData.isHidden = false
                    self.cvMedias.isHidden = true
                }
            }
        }
    }
}

extension ExploreVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "ExploreSearchVC") as! ExploreSearchVC
//        let navVC = UINavigationController(rootViewController: searchVC)
//        navVC.isNavigationBarHidden = true
//        navVC.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(searchVC, animated: true)
        self.navigationController?.pushViewController(searchVC, animated: true)
//        self.present(navVC, animated: true, completion: nil)
        textField.endEditing(true)
    }
}

extension ExploreVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias!.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMediaCVCell", for: indexPath) as! AddMediaCVCell
        let media = medias![indexPath.item]
        
        cell.ivMedia.setImage(imageUrl: media.mediaImage!)
        
        cell.btnVideoIndicator.isHidden = false
        if media.module == "Event" {
            cell.btnVideoIndicator.setBackgroundImage(UIImage(named: "EventIndicator"), for: .normal)
        } else if media.type == "Media" && media.mediaType == "Video" {
            cell.btnVideoIndicator.setBackgroundImage(UIImage(named: "VideoIndicator"), for: .normal)
        } else if media.type == "Media" && media.mediaType == "Image" {
            cell.btnVideoIndicator.isHidden = true
        } else {
            cell.btnVideoIndicator.setBackgroundImage(UIImage(named: "PostIndicator"), for: .normal)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = medias![indexPath.item]
        if media.module == "Event" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
            vc.eventId = media.moduleId!
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        } else if media.type == "Media" && media.mediaType == "Video" {
            let viewMedia = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVideoVC") as! ViewImageVideoVC
            viewMedia.isViewPost = true
            viewMedia.profilePicURL = media.profilePic
            viewMedia.name = media.name
            viewMedia.userName = media.userName
            viewMedia.modalPresentationStyle = .overCurrentContext
            viewMedia.modalTransitionStyle = .crossDissolve
            viewMedia.media = media
            self.view!.ffTabVC.present(viewMedia, animated: true, completion: nil)
        } else if media.type == "Media" && media.mediaType == "Image" {
            let viewMedia = self.storyboard?.instantiateViewController(withIdentifier: "ViewImageVideoVC") as! ViewImageVideoVC
            viewMedia.isViewPost = true
            viewMedia.userId = media.userId
            viewMedia.profilePicURL = media.profilePic
            viewMedia.name = media.name
            viewMedia.userName = media.userName
            viewMedia.modalPresentationStyle = .overCurrentContext
            viewMedia.modalTransitionStyle = .crossDissolve
            viewMedia.media = media
            self.view!.ffTabVC.present(viewMedia, animated: true, completion: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
            vc.postId = media.moduleId!
            self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == medias!.count - 1 {
            if hasMoreMedias == 1 {
                getFollowerPosts()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.width)/3, height: (self.view.frame.width)/3)
    }
}
