//
//  TLPageControl.swift
//  - Designed Custom Page control to display custom images as Dot to User.

//  Tussly
//
//  Created by Jaimesh Patel on 14/11/19.
//  Copyright © 2019 Jaimesh Patel. All rights reserved.
//

import UIKit

class TLPageControl: UIPageControl {

    let activePage: UIImage = UIImage(named: "page_active")!
    let inActivePage: UIImage = UIImage(named: "page_inactive")!

    override var numberOfPages: Int {
        didSet {
            updateDots()
        }
    }

    override var currentPage: Int {
        didSet {
            updateDots()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.pageIndicatorTintColor = UIColor.clear
        self.currentPageIndicatorTintColor = UIColor.clear
        self.clipsToBounds = false
    }

    func updateDots() {
        var i = 0
        for view in self.subviews {
            var imageView = self.imageView(forSubview: view)
            if imageView == nil {
                if i == self.currentPage {
                    imageView = UIImageView(image: activePage)
                } else {
                    imageView = UIImageView(image: inActivePage)
                }
                imageView!.center = view.center
                view.addSubview(imageView!)
                view.clipsToBounds = false
            }
            if i == self.currentPage {
                imageView!.alpha = 1.0
                imageView?.image = activePage
            } else {
                imageView!.alpha = 0.5
                imageView?.image = inActivePage
            }
            i += 1
        }
    }

    fileprivate func imageView(forSubview view: UIView) -> UIImageView? {
        var dot: UIImageView?
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
