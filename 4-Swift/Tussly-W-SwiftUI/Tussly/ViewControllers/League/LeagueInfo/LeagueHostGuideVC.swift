//
//  LeagueHostGuideVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class LeagueHostGuideVC: UIViewController {

    @IBOutlet weak var cvSteps: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!


    var arrLoby = [GameLobby]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.numberOfPages = 1
        pageControl?.currentPage = 1
                
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.layoutCells()
        })
    }
    
    // MARK: - UI Methods
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = cvSteps.frame.size
        layout.scrollDirection = .horizontal
        self.cvSteps.setCollectionViewLayout(layout, animated: true)
    }

    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension LeagueHostGuideVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LobbySetupCVCell", for: indexPath) as! LobbySetupCVCell
        cell.lblStepTitle.text = "Step \(indexPath.item + 1)"
        cell.lblStep.text = APIManager.sharedManager.leagueInfo?.hostGuide
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cvSteps.frame.width, height: cvSteps.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

