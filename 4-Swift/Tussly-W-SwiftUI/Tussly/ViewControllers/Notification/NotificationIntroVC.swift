//
//  NotificationIntroVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 14/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class NotificationIntroVC: UIViewController {

    // MARK: - Variables.
    var arrNotificationItro = [[String: String]]()
    
    // MARK: - Controls
    @IBOutlet weak var btnSkip : UIButton!
    @IBOutlet weak var btnNext : UIButton!
    @IBOutlet weak var pageController : UIPageControl!
    @IBOutlet weak var cvNotificationIntro : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        btnSkip.layer.cornerRadius = btnSkip.frame.height / 2
        btnNext.layer.cornerRadius = 15.0
        
        /*arrNotificationItro = [
            ["image": "Add_favorite", "title": "Add to Favorites", "discription": "Prevent certain notification from being automatically deleted"],
            ["image": "Delete_notificarion", "title": "Swipe Right to Delete", "discription": "Delete any notification with a single swipe to keep your inbox clean"],
            ["image": "Delete_prohibited", "title": "How to Delete Favorites", "discription": "Tap  icon to remove from favourites prior to deleting"],
            ["image": "Auto_deletion", "title": "Auto Delete", "discription": "Each Notification will be automatically deleted after a period of 2 months"]
        ]   //  */
        // By Pranay Value change
        arrNotificationItro = [
            ["image": "Add_favorite", "title": "Add to Favorites", "discription": "Prevent certain notifications from being automatically deleted"],
            ["image": "Delete_notificarion", "title": "Swipe Right to Delete", "discription": "Delete any notification with a single swipe to keep your inbox clean"],
            ["image": "Delete_prohibited", "title": "How to Delete Favorites", "discription": " icon to remove from favourites prior to deleting"],
            ["image": "Auto_deletion", "title": "Auto Delete", "discription": "Each Notification will be automatically deleted after a period of 2 months"]
        ]
        // .
        
        self.pageController.numberOfPages = arrNotificationItro.count
        self.pageController.currentPage = 0
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: cvNotificationIntro.frame.height, height: cvNotificationIntro.frame.width)
        layout.scrollDirection = .horizontal
        self.cvNotificationIntro.setCollectionViewLayout(layout, animated: true)
        self.cvNotificationIntro.bounces = false
        cvNotificationIntro.register(UINib(nibName: "NotificationIntroCell", bundle: nil),forCellWithReuseIdentifier: "NotificationIntroCell")
        cvNotificationIntro.reloadData()
    }
    
    @IBAction func didPressNext(_ sender: UIButton) {
        
        if self.pageController.currentPage == arrNotificationItro.count - 2 {
            btnSkip.isHidden = true
            btnNext.setTitle("Finish", for: .normal)
        }else {
            btnSkip.isHidden = false
            btnNext.setTitle("Next", for: .normal)
        }
        
        if self.pageController.currentPage == arrNotificationItro.count - 1 {
            self.dismiss(animated: true, completion: nil)
        }else {
            cvNotificationIntro.scrollToItem(at: IndexPath(item: self.pageController.currentPage + 1, section: 0), at: .centeredHorizontally, animated: true)
            self.pageController.currentPage = self.pageController.currentPage + 1
        }
    }

    @IBAction func didPressSkip(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension NotificationIntroVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrNotificationItro.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationIntroCell", for: indexPath) as! NotificationIntroCell
        
        cell.imgActionLogo.image = UIImage(named: arrNotificationItro[indexPath.row]["image"]!) // By Pranay
        
        if indexPath.row == 2 {
            cell.lblTitle.text = arrNotificationItro[indexPath.row]["title"]!
            
            let attributedString = NSMutableAttributedString(string: "Tap ")
            let loveAttachment = NSTextAttachment()
            if #available(iOS 13.0, *) {
                //loveAttachment.image = UIImage(systemName: "heart.fill")    //Favorite_notification
                loveAttachment.image = UIImage(named: "Favorite_notification")
                loveAttachment.image?.withTintColor(UIColor(red: 139, green: 0, blue: 0, alpha: 1))
                loveAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
                attributedString.append(NSAttributedString(attachment: loveAttachment))
                attributedString.append(NSAttributedString(string: arrNotificationItro[indexPath.row]["discription"]!))
            }
            cell.lblDiscription.attributedText = attributedString
        } else {
            //cell.imgActionLogo.image = UIImage(named: arrNotificationItro[indexPath.row]["image"]!) // By Pranay
            cell.lblTitle.text = arrNotificationItro[indexPath.row]["title"]!
            cell.lblDiscription.text = arrNotificationItro[indexPath.row]["discription"]!
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //self.pageController.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvNotificationIntro.frame.width, height: cvNotificationIntro.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageController?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        if self.pageController.currentPage == arrNotificationItro.count - 1 {
            btnSkip.isHidden = true
            btnNext.setTitle("Finish", for: .normal)
        }else {
            btnSkip.isHidden = false
            btnNext.setTitle("Next", for: .normal)
        }
        
    }
}
