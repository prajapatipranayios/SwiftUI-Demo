//
//  StageRankingDialog.swift
//  Tussly
//
//  Created by Auxano on 01/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class StageRankingDialog: UIViewController {
    
    // MARK: - Variables
    var arrStage = [Stages]()
    var arrTemp = [Stages]()
    var arrOriginal = [Stages]()
    var arrSelectedStageIndex = [Int]()
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var arrStageDuplicate = [Any]()
    var tapOk: (([Any])->Void)?
    // [Any] = [Bool(true-apply to rank, false-apply 3 stages to swap),
                                            //[Int](ranked stages)]
    var tapForFilter: ((Int)->Void)?
    var arrStageId = [Int]()
    var teamId = 0
    var isFromPlayerCard = false
    var header = ""
    var arrSwaped = [Int]()
    var arrForPlayer = [TeamPlayer]()
    
    /// 331 - By Pranay
    var isUpdateFireStore: Int = 0
    /// 331 .

    // MARK: - Controls
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSwapHeight: NSLayoutConstraint!
    @IBOutlet weak var btnApplyRank: UIButton!
    @IBOutlet weak var tvStage: UITableView!
    @IBOutlet weak var btnSwap: UIButton!
    
    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        btnApplyRank.layer.cornerRadius = 15
        btnSwap.layer.cornerRadius = 5
        if(arrSelectedStageIndex.count == 2){
            btnSwap.backgroundColor = Colors.stageRank.returnColor()
        } else {
            btnSwap.backgroundColor = Colors.disableButton.returnColor()
        }
        
        if isFromPlayerCard {
            btnSwap.isHidden = true
            btnSwapHeight.constant = 0
            messageHeight.constant = 0
            btnApplyRank.setTitle("Apply", for: .normal)
            lblTitle.text = header
        } else {
            arrOriginal = APIManager.sharedManager.content?.stages ?? []
            for i in 0 ..< arrSwaped.count {
                arrOriginal.map{
                    if $0.id == arrSwaped[i] {
                        arrTemp.append($0)
                    }
                }
            }
            arrStage = arrSwaped.count == 0 ? arrOriginal : arrTemp
        }
    }
    
    /// 333 - By Pranay
    override func viewWillAppear(_ animated: Bool) {
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
    }
    /// 333 .
    
    // MARK: - UI Methods

    // MARK: - Button Click Events
    
    @IBAction func applyRankTapped(_ sender: UIButton) {
        if isFromPlayerCard {
            if arrSelectedStageIndex.count == 0 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: {
                    if self.tapForFilter != nil {
                        self.tapForFilter!(self.arrSelectedStageIndex[0])
                    }
                })
            }
        } else {
            var arrTempOriginal = [Stages]()
            var arrOriginalId = [Int]()
            arrTempOriginal = arrSwaped.count == 0 ? arrOriginal : arrTemp
            for i in 0 ..< arrTempOriginal.count {
                arrOriginalId.append(arrTempOriginal[i].id!)
            }
            
            arrStageId = [Int]()
            for i in 0 ..< arrStage.count {
                arrStageId.append(arrStage[i].id!)
            }
            
            if arrOriginalId != arrStageId {
                rankStages()
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            /*var arrId = [Int]()
                            for i in 0 ..< self.arrStage.count {
                                arrId.append(self.arrStage[i].id ?? 0)
                            }   //  */
                            self.tapOk!([true, arrOriginalId])
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func swapTapped(_ sender: UIButton) {
        if(arrSelectedStageIndex.count == 2){
            arrStageDuplicate.append(arrStage[arrSelectedStageIndex[0]])
            arrStageDuplicate.append(arrStage[arrSelectedStageIndex[1]])
            arrStage.remove(at: arrSelectedStageIndex[0])
            arrStage.insert(arrStageDuplicate[1] as! Stages, at: arrSelectedStageIndex[0])
            arrStage.remove(at: arrSelectedStageIndex[1])
            arrStage.insert(arrStageDuplicate[0] as! Stages, at: arrSelectedStageIndex[1])
            arrSelectedStageIndex.removeAll()
            arrStageDuplicate.removeAll()
            tvStage.reloadData()
            btnSwap.backgroundColor = Colors.disableButton.returnColor()
        }
    }
    
    // MARK: Webservices
    func rankStages() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.rankStages()
                }
            }
            return
        }
        
        showLoading()
        //for i in 0 ..< arrStage.count {
        //    arrStageId.append(arrStage[i].id!)
        //}
        
        /// 331 - By Pranay
        var param = [String: Any]()
        param = [
            "leagueId": APIManager.sharedManager.match?.leagueId ?? 0,
            "matchId": APIManager.sharedManager.match?.matchId ?? 0,
            "teamId": self.teamId,
            "stageId": arrStageId,
            "isUpdateFireStore": isUpdateFireStore
        ]
        /// 331 .
        
        //APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_DEFAULT_STAGE, parameters: ["leagueId" : APIManager.sharedManager.match?.leagueId ?? 0, "matchId": APIManager.sharedManager.match?.matchId ?? 0, "teamId":self.teamId, "stageId": arrStageId]) { (response: ApiResponse?, error) in
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_DEFAULT_STAGE, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            var arrId = [Int]()
                            for i in 0 ..< self.arrStage.count {
                                arrId.append(self.arrStage[i].id ?? 0)
                            }
                            self.tapOk!([true, arrId])
                        }
                    })
                }
            } else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            self.tapOk!([true, []])
                        }
                    })
                }
            }
        }
    }
}

//MARK: - Tableview Methods
extension StageRankingDialog: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFromPlayerCard ? (header == "Select Stage" ? arrStage.count : arrForPlayer.count) : arrStage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StageRankingCVCell") as! StageRankingCVCell
        cell.lblIndex.text = "\(indexPath.row + 1)."
        cell.lblStageName.text = isFromPlayerCard ? (header == "Select Stage" ? arrStage[indexPath.row].name : ("\(arrForPlayer[indexPath.row].firstName ?? "") \(arrForPlayer[indexPath.row].lastName ?? "")")) : arrStage[indexPath.row].mapTitle
        
        if(arrSelectedStageIndex.contains(indexPath.row)){
            cell.imgCheck.isHidden = false
        } else {
            cell.imgCheck.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(arrSelectedStageIndex.contains(indexPath.row)){
            arrSelectedStageIndex.remove(at: arrSelectedStageIndex.firstIndex(of: indexPath.row)!)
        } else {
            if isFromPlayerCard && arrSelectedStageIndex.count > 0 {
                arrSelectedStageIndex.remove(at: 0)
            }
            arrSelectedStageIndex.append(indexPath.row)
        }
        if(arrSelectedStageIndex.count == 2){
            btnSwap.backgroundColor = Colors.stageRank.returnColor()
        } else {
            btnSwap.backgroundColor = Colors.disableButton.returnColor()
        }
        if(arrSelectedStageIndex.count > 2){
            arrSelectedStageIndex.removeLast()
            self.dismiss(animated: true, completion: {
                if self.tapOk != nil {
                    var arrId = [Int]()
                    for i in 0 ..< self.arrStage.count {
                        arrId.append(self.arrStage[i].id ?? 0)
                    }
                    self.tapOk!([false, arrId])
                }
            })
        }
        tvStage.reloadData()
    }
}
