//
//  AddGamesCell.swift
//  - Designed custom cell to add Games while creating Player Card

//  Tussly
//
//  Created by Auxano on 18/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

protocol updateCharacterNoDelegate {
    func updateUI(item: [Int], section: Int)
}

class CharNameTVCell: UITableViewCell {
    // MARK: - Controls
    
    @IBOutlet weak var cvProfile : UICollectionView!
    
    // MARK: - Variables
    var arrTotal = [[Characters]]()
    var arrName = [Characters]()//[[String: String]]()
    var arrSelectedIndex = [Int]()
    var delegate: updateCharacterNoDelegate?
    var currentSection = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cvProfile.delegate = self
        cvProfile.dataSource = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.cvProfile.frame.width / 2, height: 38)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        cvProfile!.collectionViewLayout = layout
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK:- UICollectionViewDelegate

extension CharNameTVCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharProfileCVCell", for: indexPath) as! CharProfileCVCell
        cell.lblTitle.text = arrName[indexPath.row].name
        cell.index = indexPath.item
        cell.imgProfile.setImage(imageUrl: arrName[indexPath.row].imagePath ?? "")
        var section = Int()
        var row = Int()
        if arrSelectedIndex.contains(cell.index) {
            if(UserDefaults.standard.value(forKey: UserDefaultType.currentSection) != nil){
                section = UserDefaults.standard.value(forKey: UserDefaultType.currentSection) as! Int
            } else {
                section = -1
            }
            
            if(UserDefaults.standard.value(forKey: UserDefaultType.currentRow) != nil){
                row = UserDefaults.standard.value(forKey: UserDefaultType.currentRow) as! Int
            } else {
                row = -1
            }
            
            if(section == currentSection && row == cell.index){
                cell.imgSelected.isHidden = false
            } else {
                cell.imgSelected.isHidden = true
            }
        }else {
            cell.imgSelected.isHidden = true
        }
        
        cell.onTapProfile = { index in
            UserDefaults.standard.set(self.currentSection, forKey: UserDefaultType.currentSection)
            UserDefaults.standard.set(cell.index, forKey: UserDefaultType.currentRow)
            if self.arrSelectedIndex.contains(index) {
                self.arrSelectedIndex.remove(at: self.arrSelectedIndex.firstIndex(of: index)!)
            }
            else {
                self.arrSelectedIndex.append(index)
            }
            if(self.arrSelectedIndex.count > 1){
                self.arrSelectedIndex.removeFirst()
            }
            self.delegate?.updateUI(item: self.arrSelectedIndex, section: self.currentSection)
            self.cvProfile.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.cvProfile.frame.size.width / 2, height: 38)
        
    }
}
