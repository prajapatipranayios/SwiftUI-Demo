//
//  HighlightCell.swift
//  - Designed custom cell for displaying Highlight videos

//  Tussly
//
//  Created by Auxano on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class HighlightCell: UICollectionViewCell {
    
    // MARK: - Controls
    
    @IBOutlet weak var cvMyHighlight: UICollectionView!
    @IBOutlet weak var pageControl: TLPageControl!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var heightPageControl : NSLayoutConstraint!
    
    // MARK: - Variables
    
    var onTapUpload: (()->Void)?
    var index: Int = -1
    var allHighlightData: [Highlight]?
    var currentTeamName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutCells()
        DispatchQueue.main.async {
            self.btnUpload.layer.cornerRadius = self.btnUpload.frame.size.height / 2
        }
    }
    
    // MARK: - UI Methods
    
    func setupHighlighCvCell(allHighlight : [Highlight],teamName : String,isPostVideo: Int) {
        if isPostVideo == 0 {
            viewTop.isHidden = true
        }
        currentTeamName = teamName
        self.pageControl.numberOfPages = allHighlight.count
        allHighlightData = allHighlight
        cvMyHighlight.delegate = self
        cvMyHighlight.dataSource = self
        cvMyHighlight.reloadData()
    }
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = self.cvMyHighlight.frame.size
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.cvMyHighlight.isPagingEnabled = true
        self.cvMyHighlight!.setCollectionViewLayout(layout, animated: true)
        self.cvMyHighlight.contentOffset.y = 0
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : cvMyHighlight.contentOffset.y ,width : cvMyHighlight.frame.width,height : cvMyHighlight.frame.height)
        cvMyHighlight.scrollRectToVisible(frame, animated: true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapUploadVideo(_ sender: UIButton) {
        if self.onTapUpload != nil {
            self.onTapUpload!()
        }
    }
    
    @IBAction func onTapPrev(_ sender: UIButton) {
        let collectionBounds = cvMyHighlight.bounds
        let contentOffset = CGFloat(floor(cvMyHighlight.contentOffset.x - collectionBounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
        self.pageControl.currentPage = self.pageControl.currentPage - 1
    }

    @IBAction func onTapNext(_ sender: UIButton) {
        let collectionBounds = cvMyHighlight.bounds
        let contentOffset = CGFloat(floor(cvMyHighlight.contentOffset.x + collectionBounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
        self.pageControl.currentPage = self.pageControl.currentPage + 1
    }
    
    
    @objc func playVideo(btn: UIButton) {
        if let url = URL(string: allHighlightData![btn.tag].videoLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension HighlightCell: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allHighlightData?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyHighlightCell",
        for: indexPath) as! MyHighlightCell
        cell.btnPlay.tag = indexPath.item
        cell.btnPlay.addTarget(self, action: #selector(playVideo(btn:)), for: .touchUpInside)
        cell.ivVideo.setImage(imageUrl: allHighlightData![indexPath.item].thumbnail)
        cell.lblVideoName.text = allHighlightData![indexPath.item].displayName
        cell.lblPlayerName.text = currentTeamName
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvMyHighlight.frame.width, height: cvMyHighlight.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
