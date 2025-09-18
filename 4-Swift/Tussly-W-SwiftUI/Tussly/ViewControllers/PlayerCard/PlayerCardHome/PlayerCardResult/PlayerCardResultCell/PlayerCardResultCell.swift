//
//  TeamResultCell.swift
//  - To display information related to Game Result of different Team & its position on table.

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class PlayerCardResultCell: UITableViewCell {

    // MARK: - Controls
    @IBOutlet weak var cvPlayers: UICollectionView!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var heightBtnRight: NSLayoutConstraint!
    @IBOutlet weak var heightResultCV: NSLayoutConstraint!
    @IBOutlet weak var gridLayoutResultCV: StickyGridCollectionViewLayout! {
        didSet {
            gridLayoutResultCV.stickyRowsCount = 1
            gridLayoutResultCV.stickyColumnsCount = 1
        }
    }
    
    // MARK: - Variables
    var rowHeaders: [String]?
    var resultData: [[String: Any]]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cvPlayers.register(UINib(nibName: "ContentCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ContentCollectionViewCell")
        cvPlayers.register(UINib(nibName: "PlayerCVCell", bundle: nil), forCellWithReuseIdentifier: "PlayerCVCell")
        cvPlayers.register(UINib(nibName: "ContentWithBlackBackgroundCell", bundle: nil), forCellWithReuseIdentifier: "ContentWithBlackBackgroundCell")
        
        cvPlayers.delegate = self
        cvPlayers.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
        
    func setupResultCollectionData(resultData: [[String: Any]]? = nil, rowHeaders: [String]? = nil) {
        if resultData != nil {
            self.rowHeaders = rowHeaders
            self.resultData = resultData
        }
        
        DispatchQueue.main.async {
            self.cvPlayers.reloadData()
            self.heightResultCV.constant = self.cvPlayers.collectionViewLayout.collectionViewContentSize.height
        }
        
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PlayerCardResultCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (resultData?.count ?? 5) + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as! ContentCollectionViewCell
            
            if rowHeaders != nil && resultData != nil {
//                cell.hideAnimation()
                cell.contentLabel.text = rowHeaders?[indexPath.row]
            }else {
                cell.contentLabel.text = ""
//                cell.showAnimation()
            }
            
            cell.contentLabel.textColor = UIColor.white
            cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
            cell.backgroundColor = Colors.black.returnColor()
            return cell
        }  else if indexPath.section == (resultData?.count ?? 5) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentWithBlackBackgroundCell", for: indexPath) as! ContentWithBlackBackgroundCell
           
            if indexPath.row == 0 {
                cell.contentLabel.text = "Team Average"
                cell.contentLabel.font = Fonts.Bold.returnFont(size: 14.0)
            }
            
            if rowHeaders != nil && resultData != nil {
//               cell.hideAnimation()
               if indexPath.row != 0 {
                let row = resultData?[indexPath.section - 1]
                cell.contentLabel.text = "\(row![rowHeaders![indexPath.row]]!)"
                   cell.contentLabel.font = Fonts.Bold.returnFont(size: 12.0)
               }
            }else {
               cell.contentLabel.text = "Team Average"
//               cell.showAnimation()
            }
            cell.viewDetail.isHidden = true
            cell.btnPlayerDetail.isHidden = true
           
            return cell
       } else {
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCVCell",
                for: indexPath) as! PlayerCVCell
                cell.ivCaptainCap.isHidden = true
                
                if rowHeaders != nil && resultData != nil {
//                    cell.hideAnimation()
                    cell.lblPlayerName.text = resultData?[indexPath.section - 1]["Players"] as? String
                    cell.ivPlayer.setImage(imageUrl: resultData?[indexPath.section - 1]["avatarImage"] as! String)
                    cell.lblPlayerName.font = Fonts.Semibold.returnFont(size: 12.0)
                }else {
                    cell.lblPlayerName.text = ""
//                    cell.showAnimation()
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell",
                for: indexPath) as! ContentCollectionViewCell
                cell.backgroundColor = UIColor.white
                if rowHeaders != nil && resultData != nil {
//                    cell.hideAnimation()
                    let row = resultData?[indexPath.section - 1]
                    cell.contentLabel.text = "\(row![rowHeaders![indexPath.row]]!)"
                }else {
                    cell.contentLabel.text = ""
//                    cell.showAnimation()
                }
                
                cell.contentLabel.textColor = Colors.black.returnColor()
                cell.contentLabel.font = Fonts.Regular.returnFont(size: 12.0)
                return cell
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x

        if (scrollOffset + scrollViewWidth == scrollContentSizeWidth) {
            // then we are at the end
            btnRight?.isHidden = true
        } else {
            btnRight.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentWidth = CGFloat((UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0) + CGFloat(((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1) * 80)) > CGFloat(self.contentView.frame.width) ? 80.0 : (CGFloat(self.contentView.frame.width) - CGFloat(UIDevice.current.userInterfaceIdiom == .pad ? 210.0 : 150.0)) / CGFloat((rowHeaders?.count ?? SKELETON_ROWHEADER_COUNT) - 1)
                 
        return CGSize(width: indexPath.row == 0 ? UIDevice.current.userInterfaceIdiom == .pad ? 210 : 150 : currentWidth, height: indexPath.section == 0 ? 32 : 40)
    }
}

