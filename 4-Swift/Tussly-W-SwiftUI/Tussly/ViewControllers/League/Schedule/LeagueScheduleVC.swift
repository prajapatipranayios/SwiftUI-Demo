//
//  ScheduleVC.swift
//  - Designed Match Schedule screen for League Module grouped by Week

//  Tussly
//
//  Created by Jaimesh Patel on 12/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class LeagueScheduleVC: UIViewController {
    // MARK: - Controls
    
    @IBOutlet weak var btnLeft : UIButton!
    @IBOutlet weak var btnRight : UIButton!
    @IBOutlet weak var lblNoData : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    @IBOutlet weak var viewTop : UIView!
    @IBOutlet weak var cvSchedules : UICollectionView!

    
    // MARK: - Variables
    
    var tusslyTabVC: (()->TusslyTabVC)?
    var leagueTabVC: (()->LeagueTabVC)?
    var scheduleData: [Schedule]?
    var currentDateIndex = 0
    var arrDates = [String]()
    var arrFormatDates = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.cvSchedules.dataSource = self
        self.cvSchedules.delegate = self
        cvSchedules.reloadData()
        layoutCells()
        getLeagueSchedules()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblNoData.isHidden = true
        btnLeft.isHidden = true
        btnRight.isHidden = true
    }
    
    // MARK: - UI Methods
    func layoutCells() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.itemSize = cvSchedules.frame.size
        layout.scrollDirection = .horizontal
        cvSchedules!.collectionViewLayout = layout
    }
    
    // MARK: - Button Click Events
    @IBAction func arrowTapped(_ sender: UIButton) {
        if arrFormatDates.count > 0 {
            if sender.tag == 0 {
                currentDateIndex = currentDateIndex != 0 ? currentDateIndex - 1 : currentDateIndex
            } else {
                currentDateIndex = currentDateIndex != (arrFormatDates.count - 1) ? currentDateIndex + 1 : currentDateIndex
            }
            btnLeft.isHidden = currentDateIndex == 0 ? true : false
            btnRight.isHidden = currentDateIndex == (arrFormatDates.count - 1) ? true : false
            lblDate.text = self.arrDates[currentDateIndex]
            
            cvSchedules.scrollToItem(at: IndexPath(item: currentDateIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: - Webservices
    
    func getLeagueSchedules() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getLeagueSchedules()
                }
            }
            return
        }
        
        let params = ["leagueId": leagueTabVC!().tournamentDetail?.id ?? 0, "timeZone" : APIManager.sharedManager.timezone] as [String : Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_LEAGUE_SCHEDULE, parameters: params) { (response: ApiResponse?, error) in
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.scheduleData = (response?.result?.schedule)!
                    self.arrDates = (response?.result?.byDate)!
                    
                    for i in 0 ..< self.arrDates.count {
                        self.lblDate.text = self.arrDates[0]
                        let inputFormatter = DateFormatter()
                        inputFormatter.dateFormat = "MM/dd/yyyy"
                        let showDate = inputFormatter.date(from: self.arrDates[i])
                        inputFormatter.dateFormat = "MM/dd/yyyy"
                        let resultString = inputFormatter.string(from: showDate!)
                        self.arrFormatDates.append(resultString)
                    }
                    if self.arrDates.count == 0 {
                        self.viewTop.isHidden = true
                        self.lblNoData.isHidden = false
                        self.cvSchedules.isHidden = true
                    } else {
                        self.lblNoData.isHidden = true
                        self.cvSchedules.isHidden = false
                    }
                    self.cvSchedules.reloadData()
                } else {
                    self.cvSchedules.isHidden = true
                    self.viewTop.isHidden = true
                    self.lblNoData.isHidden = false
                }
            }
        }
    }
}

// MARK: - UICollectionView Data Source/Delegate
extension LeagueScheduleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFormatDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScheduleCVCell", for: indexPath) as! ScheduleCVCell
        let schedules : [Schedule]?
        if self.scheduleData != nil {
            schedules = self.scheduleData!.filter{
                $0.matchDate == arrFormatDates[indexPath.row]
            }
            cell.setupScheduleTbl(scheduleData: schedules!)
        }else {
            cell.setupScheduleTbl(scheduleData: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let current = Int(ceil(x/w))
        currentDateIndex = current
        btnLeft.isHidden = currentDateIndex == 0 ? true : false
        btnRight.isHidden = currentDateIndex == (arrFormatDates.count - 1) ? true : false
    }
}
