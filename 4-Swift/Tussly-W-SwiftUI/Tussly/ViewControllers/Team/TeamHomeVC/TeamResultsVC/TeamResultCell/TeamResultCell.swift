//
//  TeamResultCell.swift
//  - To display information related to Game Result of different Team & its position on table.

//  Tussly
//
//  Created by Jaimesh Patel on 11/12/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

protocol teamResultDelegate {
    func showFilterView()
}

class TeamResultCell: UITableViewCell {
    
    // MARK: - Variable
    var delegate: teamResultDelegate?

    // MARK: - Controls
    @IBOutlet weak var cvPlayers: UICollectionView!
    @IBOutlet weak var heightResultCV: NSLayoutConstraint!
    
    // MARK: - Variables
    var resultData: [PlayerInfo]?
    var headers: [String]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cvPlayers.register(UINib(nibName: "TeamPlayerCell", bundle: nil), forCellWithReuseIdentifier: "TeamPlayerCell")
        cvPlayers.delegate = self
        cvPlayers.dataSource = self
    }
        
    func setupResultCollectionData(resultData: [PlayerInfo]? = nil, header : [String]!) {
        if resultData != nil {
            self.resultData = resultData
            self.headers = header
        }
        if (self.resultData?.count ?? 0) > 0 {
            DispatchQueue.main.async {
                self.cvPlayers.reloadData()
                self.heightResultCV.constant = self.cvPlayers.collectionViewLayout.collectionViewContentSize.height
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension TeamResultCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return (self.resultData?.count ?? 0) > 0 ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (resultData?.count ?? 5) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeamPlayerCell",
                                                      for: indexPath) as! TeamPlayerCell
        if indexPath.item == 0 {
            cell.viewHeader.isHidden = false
            cell.lblLabel1.text = headers[0]
            cell.lblLabel2.text = headers[1]
            cell.lblLabel3.text = headers[2]
            cell.lblLabel4.text = headers[3]
        } else {
            cell.viewHeader.isHidden = true
            cell.lblName.text = resultData?[indexPath.item - 1].userName
            cell.imgAvatar.setImage(imageUrl: resultData?[indexPath.item - 1].avatarImage ?? "")
            cell.lblWL.text = "\(resultData?[indexPath.item - 1].matchWin ?? 0)-\(resultData?[indexPath.item - 1].matchLoss ?? 0)"
            cell.lblRWRL.text = "\(resultData?[indexPath.item - 1].roundWin ?? 0)-\(resultData?[indexPath.item - 1].roundLose ?? 0)"
            cell.lblS.text = resultData?[indexPath.item - 1].stock
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.contentView.frame.size.width, height: indexPath.item == 0 ? 32 : 40)
    }
}

