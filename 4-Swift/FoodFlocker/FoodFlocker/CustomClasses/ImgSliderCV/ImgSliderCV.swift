//
//  ImgSliderCV.swift
//  ShopzzApp
//
//  Created by Auxano Global Services on 6/7/18.
//  Copyright © 2018 Auxano Global Services. All rights reserved.
//

import UIKit
import AVFoundation

class ImgSliderCV: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout { //, UICollectionViewDelegateFlowLayout

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //Jaimesh
    //    var isEvents: Bool = false
    //    var isCollectionType: Bool = false
    
    var collectionItems = Array<Media>()
    var currentPage:((Int)->Void)?
    var playVideo:((URL)->Void)?
    
    var enableGesture:((Bool)->Void)?

    
//    var openProductDetails:(()->Void)?
//    var openEventDetails:(()->Void)?
//    var makeProductFavorite:(()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.register(UINib(nibName: "ImgSliderCVCell", bundle: nil), forCellWithReuseIdentifier: "ImgSliderCVCell")
        layoutCells()
        
        if #available(iOS 11.0, *) {
            self.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.frame.size.height, height: self.frame.size.height)
        layout.scrollDirection = .horizontal
        self.setCollectionViewLayout(layout, animated: true)
    }
    
    func setupDataSource(medias: [Media]) {
        collectionItems = medias
        self.dataSource = self
        self.delegate = self
        self.reloadData()
    }
    
    //MARK:- UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgSliderCVCell", for: indexPath) as! ImgSliderCVCell
   
        
        let media = collectionItems[indexPath.item]
        
        cell.ivProduct.image = nil //Jaimesh
        
        if media.mediaType == "Video" {
                
            cell.ivProduct.setImage(imageUrl: media.mediaImage!)
            
            cell.btnPlay.isHidden = false
            cell.btnPlay.tag = indexPath.row
            cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
        } else {
            cell.ivProduct.setImage(imageUrl: media.mediaImage!)
            cell.btnPlay.isHidden = true
            cell.ivProduct.isUserInteractionEnabled = true
        }
        
        return cell
    }
        
    //MARK:- UICollectionViewDelegateFlowLayout
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if appDelegate.currentLanguage != "en" {
//            cell.transform = CGAffineTransform(scaleX: -1, y: 1)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: self.frame.size.height)
    }
    
    //MARK:- UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        
        // Do whatever with currentPage.
        
//        if appDelegate.currentLanguage != "en" {
//            current = collectionItems.count - (current + 1)
//        }
        
        if currentPage != nil {
            currentPage!(current)
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.tag != 525 {
//            let x = scrollView.contentOffset.x
//            let w = scrollView.bounds.size.width
//            var current = Int(ceil(x/w))
//            // Do whatever with currentPage.
//            if appDelegate.currentLanguage != "en" {
//                current = collectionItems.count - (current + 1)
//            }
//            if currentPage != nil {
//                self.currentPage!(current)
//            }
//        }
//    }
    
    //Jaimesh
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if enableGesture != nil {
            enableGesture!(false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if enableGesture != nil {
            enableGesture!(true)
        }
    }
    
    //
    //MARK:- Button Click Events
    
    @objc func btnPlayTapped(_ sender: UIButton) {
        let itemVideo = collectionItems[sender.tag]
        playVideo!(URL(string: itemVideo.videoUrl!)!)
    }
    
}
