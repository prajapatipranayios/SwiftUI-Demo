//
//  CustomImagePageControl.swift
//  ShopzzApp
//
//  Created by Auxano Global Services on 6/8/18.
//  Copyright © 2018 Auxano Global Services. All rights reserved.
//

import UIKit

class CustomImagePageControl: UIPageControl {
    
    let activeImage:UIImage = UIImage(named: "pcImageSelected")!
    let inactiveImage:UIImage = UIImage(named: "pcImage")!
    
    let activeVideo:UIImage = UIImage(named: "pcVideoSelected")!
    let inactiveVideo:UIImage = UIImage(named: "pcVideo")!
    
    var videoIndex = [Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }
    
    func updateDots() {
        
        var i = 0
        for view in self.subviews {
            if let imageView = self.imageForSubview(view) {
                if i == self.currentPage {
//                    imageView.image = self.activeImage
                    //My code
                    imageView.image = videoIndex.contains(i) ? self.activeVideo : self.activeImage
//                    imageView.image = i % 2 == 0 ? self.activeVideo : self.activeImage
                    //
                } else {
//                    imageView.image = self.inactiveImage
                    //My code
                    imageView.image = videoIndex.contains(i) ? self.inactiveVideo : self.inactiveImage
//                    imageView.image = i % 2 == 0 ? self.inactiveVideo : self.inactiveImage
                    //
                }
                i = i + 1
            } else {
                var dotImage = self.inactiveImage
//                if i == self.currentPage {
//                    dotImage = self.activeImage
//                }
                //My Code
//                if i % 2 == 0 {
                if videoIndex.contains(i) {
                    dotImage = self.inactiveVideo
                    if i == self.currentPage {
                        dotImage = self.activeVideo
                    }
                } else {
                    dotImage = self.inactiveImage
                    if i == self.currentPage {
                        dotImage = self.activeImage
                    }
                }
                
                view.clipsToBounds = false
                view.addSubview(UIImageView(image:dotImage))
                i = i + 1
            }
        }
    }
    
    fileprivate func imageForSubview(_ view:UIView) -> UIImageView? {
        var dot:UIImageView?
        
        if let dotImageView = view as? UIImageView {
            dot = dotImageView
        } else {
            for foundView in view.subviews {
                if let imageView = foundView as? UIImageView {
                    dot = imageView
                    break
                }
            }
        }
        
        return dot
    }
}
