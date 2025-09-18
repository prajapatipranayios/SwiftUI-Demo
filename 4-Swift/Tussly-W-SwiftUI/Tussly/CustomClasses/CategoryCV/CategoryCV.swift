//
//  CategoryCV.swift
//  - Custom CollectionView to display Categories horizontally.
//
//  Created by Jaimesh Patel on 10/10/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CategoryCV: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var btnLeft: UIButton?
    var btnRight: UIButton?

    var categoryItems: Array<String>?
    var selectedIndex: Int = -1
    var isWidthFix: Bool = false
    var isFromPlayerCard = false
    var isFromTeam = false
    var didSelect: ((Int)->Void)?
        
    // By Pranay
    var isLeagueJoinStatus : Bool = true
    var isOtherUser : Bool = false  //  when come from player card
    /// 212     =   1 - MEMBER, 2 - CAPTAIN, 3 - ADMIN, 4 - FOUNDER, 5 - ASSISTANT_CAPTAIN, 6 - NOT MEMBER
    var intTeamRole: Int = 0
    /// 212
    // .
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.register(UINib(nibName: "CategoryCVCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
    }
    
    func setupCategoryDataSource(items: Array<String>?, btnLeft: UIButton, btnRight: UIButton, isWidthFix: Bool = false, isFromPlayer : Bool, isFromTeams : Bool) {
        isFromPlayerCard = isFromPlayer
        isFromTeam = isFromTeams
        selectedIndex = self.tag == 555 ? selectedIndex == -1 ? 0 : selectedIndex  : -1
        self.btnLeft = btnLeft
        self.btnRight = btnRight
        self.isWidthFix = isWidthFix
        self.categoryItems = items
        self.dataSource = self
        self.delegate = self
        self.reloadData()
        self.btnLeft?.isHidden = true
        DispatchQueue.main.async {
            if self.frame.size.width > self.collectionViewLayout.collectionViewContentSize.width {
                self.btnRight?.isHidden = true
            }
        }
    }
    
    //MARK:- UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1    //0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCVCell
        
        if categoryItems != nil {
//            cell.hideAnimation()
            let item = categoryItems?[indexPath.item]
            cell.backgroundColor = selectedIndex == indexPath.item ? Colors.lightGray.returnColor() : UIColor.clear
            cell.lblCategory.text = item
            
            if isFromPlayerCard {
                if indexPath.item == 0 {
                    cell.ivCategory.image = UIImage(named: "Friends")
                    cell.lblCategory.textColor = Colors.black.returnColor()
                }
                else {
                    cell.ivCategory.image = UIImage(named: item == "Schedule" ? "Schedul" : item!)
                    //if self.isOtherUser && ((indexPath.row == 3) || ((indexPath.row == 1) && ((APIManager.sharedManager.playerData?.playerStatus)! == 2))) {
                    //if self.isOtherUser && ((item == "Edit Card") || (item == "Chat")) {    // Enable this, if you want to disable chat in other user.
                    if self.isOtherUser && (item == "Edit Card") {
                        cell.ivCategory.setImageColor(color: Colors.border.returnColor())
                        cell.lblCategory.textColor = Colors.border.returnColor()
                    }
                    else {
                        cell.lblCategory.textColor = Colors.black.returnColor()
                    }
                }
            } 
            else {
                cell.ivCategory.image = UIImage(named: item == "Schedule" ? "Schedul" : item!)
                //remove below condition to enable league info and leaderboard tab for league tab
                if APIManager.sharedManager.leagueType == "League" {
                    if indexPath.item != 1 && indexPath.item != 5 {
                        cell.lblCategory.textColor = Colors.black.returnColor()
                    } 
                    else {
                        cell.ivCategory.setImageColor(color: Colors.border.returnColor())
                        cell.lblCategory.textColor = Colors.border.returnColor()
                    }
                } 
                else {
                    //if indexPath.item != 4 {
                    if indexPath.row == 1 && !isLeagueJoinStatus {
                        cell.ivCategory.setImageColor(color: Colors.border.returnColor())
                        cell.lblCategory.textColor = Colors.border.returnColor()
                    }
                    else {
                        cell.lblCategory.textColor = Colors.black.returnColor()
                    }
                    
                }
            }
            
            if isFromTeam {
                cell.ivCategory.image = UIImage(named: item!)
                if intTeamRole == 1 {
                    if (categoryItems?[indexPath.item] == "Group Chat") || (categoryItems?[indexPath.item] == "Leave Team") {
                        cell.lblCategory.textColor = Colors.black.returnColor()
                    }
                    else {
                        cell.ivCategory.setImageColor(color: Colors.border.returnColor())
                        cell.lblCategory.textColor = Colors.border.returnColor()
                    }
                }
                else {
                    cell.lblCategory.textColor = Colors.black.returnColor()
                }
            }
        } 
        else {
            cell.backgroundColor = UIColor.clear
//            cell.showAnimation()
        }
        
        return cell
    }
    
    //MARK:- UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //remove below condition to enable league info and leaderboard tab for league tab
        var isSelect = false
        let item = categoryItems?[indexPath.item]
        
        if isFromPlayerCard {
            
            //if self.isOtherUser && ((indexPath.row == 3) || ((indexPath.row == 1) && ((APIManager.sharedManager.playerData?.playerStatus)! == 2))) {
            //if self.isOtherUser && ((item == "Edit Card") || (item == "Chat")) {  // Enable this, if you want to disable chat in other user.
            if self.isOtherUser && (item == "Edit Card") {
                isSelect = false
            }
            else {
                isSelect = true
            }
        }
        else {
            if APIManager.sharedManager.leagueType == "League" {
                if indexPath.item != 1 && indexPath.item != 5 {
                    isSelect = true
                } 
                else {
                    isSelect = false
                }
            }
            else {
                if indexPath.row == 1 && !isLeagueJoinStatus {
                    isSelect = false
                }
                else {
                    isSelect = true
                }
            }
        }
        
        if isFromTeam {
            if intTeamRole == 1 {
                if (categoryItems?[indexPath.item] == "Group Chat") || (categoryItems?[indexPath.item] == "Leave Team") {
                    isSelect = true
                }
                else {
                    isSelect = false
                }
            }
            else {
                isSelect = true
            }
        }
        
        if isSelect {
            selectedIndex = indexPath.item
            if didSelect != nil {
                didSelect!(selectedIndex)
            }
            self.reloadData()
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
        
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if categoryItems != nil {
            let size = (categoryItems![indexPath.row]).size(withAttributes: [
                NSAttributedString.Key.font : Fonts.Regular.returnFont(size: 12.0)
            ])
            if isWidthFix {
                if size.width+16 > 100 {
                    return CGSize(width: 105, height: 96.0)
                }
                else {
                    return CGSize(width: categoryItems![indexPath.row] == "Chat" ? size.width+46 : size.width+16, height: categoryItems![indexPath.row] == "Chat" ? 93.0 : 96.0)
                }
            }
            else {
                return CGSize(width: size.width+16, height: 96.0)
            }
        } 
        else {
            return CGSize(width: 96, height: 96)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                
        let scrollViewWidth = scrollView.frame.size.width
        let scrollContentSizeWidth = scrollView.contentSize.width
        let scrollOffset = scrollView.contentOffset.x

        if (scrollOffset == 0) {
            // then we are at the top
            btnLeft?.isHidden = true
            btnRight?.isHidden = false
        } 
        else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth - 2.0) {
            // then we are at the end
            btnLeft?.isHidden = false
            btnRight?.isHidden = true
        } 
        else {
            btnLeft?.isHidden = false
            btnRight?.isHidden = false
        }
    }

    @objc func arrowLeftBtnClick() {
        let collectionBounds = self.bounds
        let contentOffset = CGFloat(floor(self.contentOffset.x - collectionBounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    @objc func arrowRightBtnClick() {
        let collectionBounds = self.bounds
        let contentOffset = CGFloat(floor(self.contentOffset.x + collectionBounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func moveToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.contentOffset.y ,width : self.frame.width,height : self.frame.height)
        self.scrollRectToVisible(frame, animated: true)
    }
}
