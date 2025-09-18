//
//  ResultVC.swift
//  - To display match results for League Module

//  Tussly
//
//  Created by Auxano on 08/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class ResultVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var btnLeft : UIButton!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblWeek : UILabel!
    @IBOutlet weak var cvResults : UICollectionView!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblWeekLabel : UILabel!
    @IBOutlet weak var viewTop : UIView!

    // MARK: - Variables
    
    var resultData: [Result]!
    var currentWeek: Int = -1
    var maxWeekCount: Int = -1
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var currentLabel: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoData.isHidden = true
        lblTitle.isHidden = true
        self.cvResults.dataSource = self
        self.cvResults.delegate = self
        self.viewTop.isHidden = true
        DispatchQueue.main.async {
            self.layoutCells()
        }
        getRecentResult()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.leagueTabVC!().setContentSize(newContentOffset: CGPoint(x: 0, y: self.leagueTabVC!().cvLeagueTabs.frame.origin.y),animate: true)
    }
    
    // MARK: - UI Methods
    
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = CGSize(width: cvResults.frame.size.width, height: cvResults.frame.size.height)
        layout.scrollDirection = .horizontal
        cvResults.setCollectionViewLayout(layout, animated: false)
        self.cvResults.scrollToItem(at: IndexPath(item: self.maxWeekCount - 1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func arrowTapped(_ sender: UIButton) {
        if resultData.count > 0 {
            if sender.tag == 0 {
                currentWeek = currentWeek != 1 ? currentWeek - 1 : currentWeek
            } else {
                currentWeek = currentWeek != maxWeekCount ? currentWeek + 1 : currentWeek
            }
            btnLeft.isHidden = currentWeek == 1 ? true : false
            btnRight.isHidden = currentWeek == maxWeekCount ? true : false
            lblWeek.text = "Week \(currentWeek)"
            cvResults.scrollToItem(at: IndexPath(item: currentWeek - 1, section: 0), at: .centeredHorizontally, animated: true)
            self.cvResults.reloadData()
        }
    }
    
    // MARK: Webservices
    
    func getRecentResult() {
        
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getRecentResult()
                }
            }
            return
        }
        
//        showLoading()
        // By Pranay - add patam - timeZone
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_RECENT_RESULT, parameters: ["leagueId": leagueTabVC!().tournamentDetail?.id ?? 0, "timeZone" : APIManager.sharedManager.timezone]) { (response: ApiResponse?, error) in
//            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.resultData = (response?.result?.results)!
                    self.currentLabel = response?.result?.currentWeek ?? 0
                    if self.resultData.count == 1 {
                        self.btnRight.isHidden = true
                        self.btnLeft.isHidden = true
                    }
                    if self.resultData.count == 0 {
                        self.lblTitle.isHidden = true
                        self.viewTop.isHidden = true
                        self.lblNoData.isHidden = false
                        self.cvResults.isHidden = true
                        self.lblTitle.isHidden = true
                    } else {
                        //self.maxWeekCount = (response?.result?.currentWeek)!
                        self.maxWeekCount = self.resultData[self.resultData.count - 1].leagueWeekNo ?? 0
                        self.currentWeek = self.resultData[self.resultData.count - 1].leagueWeekNo ?? 0
                        self.lblWeek.text = "Week \(self.currentWeek)"
                        self.lblTitle.isHidden = false
                        self.viewTop.isHidden = false
                        self.lblNoData.isHidden = true
                        self.cvResults.isHidden = false
                        self.lblTitle.isHidden = false
                        self.btnLeft.isHidden = self.currentWeek == 1 ? true : false
                        self.btnRight.isHidden = self.currentWeek == self.maxWeekCount ? true : false
                    }
                    self.cvResults.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.lblTitle.isHidden = false
                    self.viewTop.isHidden = true
                    self.lblTitle.isHidden = true
                    self.cvResults.isHidden = true
                    self.viewTop.isHidden = true
                    self.lblNoData.isHidden = false
                }
            }
        }
    }
}

// MARK: - UICollectionView Data Source/Delegate

extension ResultVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxWeekCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCVCell", for: indexPath) as! ResultCVCell
        
        let currentWeekData : [Result]?
        if self.resultData != nil {
            currentWeekData = self.resultData.filter{
                $0.leagueWeekNo == currentWeek
            }
            cell.setupResultTbl(resultData: currentWeekData)
            if self.currentLabel == currentWeek {
                self.lblWeekLabel.isHidden = false
            } else {
                self.lblWeekLabel.isHidden = true
            }
            cell.openResultDetails = { index in
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "BoxscoreVC") as! BoxscoreVC
                objVC.matchId = currentWeekData![index].id!
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }else {
            cell.setupResultTbl(resultData: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: cvResults.frame.size.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        print(current)
        currentWeek = current + 1
        btnLeft.isHidden = current + 1 == 1 ? true : false
        btnRight.isHidden = current + 1 == maxWeekCount ? true : false
        lblWeek.text = "Week \(current + 1)"
        cvResults.reloadData()
    }
}
