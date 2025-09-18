//
//  HeadLineVC.swift
//  - Designed Headlines screen to display match Headlines for League Module

//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class HeadLineVC: UIViewController {
    
    // MARK: - Controls
    
    @IBOutlet weak var btnLeft : UIButton!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblWeek : UILabel!
    @IBOutlet weak var cvHeadlines : UICollectionView!

    // MARK: - Variables
    
    var headLineData: [Headline]?
    var currentWeek: Int = -1
    var maxWeekCount: Int = -1
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentWeek = leagueTabVC!().currentWeek
        self.maxWeekCount = leagueTabVC!().currentWeek
        lblWeek.text = "Week \(currentWeek)"
        btnLeft.isHidden = self.currentWeek == 1 ? true : false
        btnRight.isHidden = self.currentWeek == self.maxWeekCount ? true : false
        cvHeadlines.scrollToItem(at: IndexPath(item: currentWeek - 1, section: 0), at: .centeredHorizontally, animated: true)
        cvHeadlines.reloadData()
        getHeadlines()
    }
    
    // MARK: - Button Click Events
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            currentWeek = currentWeek != 1 ? currentWeek - 1 : currentWeek
        } else {
            currentWeek = currentWeek != maxWeekCount ? currentWeek + 1 : currentWeek
        }
        btnLeft.isHidden = currentWeek == 1 ? true : false
        btnRight.isHidden = currentWeek == maxWeekCount ? true : false

        lblWeek.text = "Week \(currentWeek)"
        cvHeadlines.scrollToItem(at: IndexPath(item: currentWeek - 1, section: 0), at: .centeredHorizontally, animated: true)
        self.cvHeadlines.reloadData()
    }
    
    // MARK: Webservices
    
    func getHeadlines() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getHeadlines()
                }
            }
            return
        }
        
        let params = ["leagueId": leagueTabVC!().tournamentDetail?.id ?? 0]
//        self.navigationController?.view.tusslyTabVC.showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_HEADLINES, parameters: params) { (response: ApiResponse?, error) in
//            DispatchQueue.main.async {
//                self.navigationController?.view.tusslyTabVC.hideLoading()
//            }
            if response?.status == 1 {
                self.headLineData = (response?.result?.matchHeadlines)!
                DispatchQueue.main.async {
                    self.cvHeadlines.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.headLineData = [Headline]()
                    self.cvHeadlines.reloadData()
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
}

// MARK: - UICollectionView Data Source/Delegate

extension HeadLineVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxWeekCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadlineCVCell", for: indexPath) as! HeadlineCVCell
        
        let currentWeekData : [Headline]?
        if self.headLineData != nil {
            currentWeekData = self.headLineData!.filter{
                $0.weekNo == currentWeek
            }
            cell.setupHeadlineTbl(headlines: currentWeekData)
        }else {
            cell.setupHeadlineTbl(headlines: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.headLineData != nil {
            return collectionView.frame.size
        }else {
            return CGSize(width: self.view.frame.width, height: collectionView.frame.size.height)
        }
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        currentWeek = current + 1
        btnLeft.isHidden = current + 1 == 1 ? true : false
        btnRight.isHidden = current + 1 == maxWeekCount ? true : false
        lblWeek.text = "Week \(current + 1)"
        cvHeadlines.reloadData()
    }
}
