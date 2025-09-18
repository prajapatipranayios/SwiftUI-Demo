//
//  LeagueMatchDetailVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit
import WebKit


class LeagueMatchDetailVC: UIViewController, UIScrollViewDelegate {

    // MARK: - Variables
    
    // MARK: - Controls
    @IBOutlet weak var lblBestOfFormat: UILabel!
    @IBOutlet weak var lblStage: UILabel!
    @IBOutlet weak var lblStageFormat: UILabel!
    @IBOutlet weak var lblStarter: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var lblOmega: UILabel!
    @IBOutlet weak var lblCharBan: UILabel!
    @IBOutlet weak var lblTimeMatchRound: UILabel!
    @IBOutlet weak var lblTimeSelectChar: UILabel!
    @IBOutlet weak var lblTimebanStage: UILabel!
    
    @IBOutlet weak var viewRegular : UIScrollView!
    @IBOutlet weak var viewRegularLine: UIView!
    @IBOutlet weak var viewPlayoffLine: UIView!
    @IBOutlet weak var btnBestFormat: UIButton!
    @IBOutlet weak var btnViewBestFormat: UIButton!
    @IBOutlet weak var bestFormatValueTrailConst: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnViewBestFormat.isHidden = true
        bestFormatValueTrailConst.constant = 16
        viewPlayoffLine.isHidden = true
    }
    
    // MARK: - UI Methods
    
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onTapView(_ sender: UIButton) {
        
    }
    
    @IBAction func regularTapped(_ sender: UIButton) {
        btnBestFormat.setTitle("Best of Foramt:", for: .normal)
        btnViewBestFormat.isHidden = true
        bestFormatValueTrailConst.constant = 16
        viewRegularLine.isHidden = false
        viewPlayoffLine.isHidden = true
        
        lblBestOfFormat.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.bestOfFormat
        lblStage.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.stagePick
        lblStageFormat.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.stagePickFormat
        lblStarter.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.starterStages?.count ?? 0)"
        lblCounter.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.counterStages?.count ?? 0)"
        lblOmega.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.omegaAndBattleFieldsStages?.count ?? 0)"
        lblCharBan.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.characterBans?.count ?? 0)"
        lblTimeMatchRound.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.timeBetweenMatchRounds
        lblTimeSelectChar.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.timeToSelectStage
        lblTimebanStage.text = APIManager.sharedManager.leagueInfo?.matchDetails?.regularSeason?.timeToBanOrPickStage
    }
    
    @IBAction func playoffTapped(_ sender: UIButton) {
        btnBestFormat.setTitle("Best of Foramt(s):", for: .normal)
        btnViewBestFormat.isHidden = false
        bestFormatValueTrailConst.constant = 55
        viewRegularLine.isHidden = true
        viewPlayoffLine.isHidden = false
        
        lblBestOfFormat.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.bestOfFormat
        lblStage.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.stagePick
        lblStageFormat.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.stagePickFormat
        lblStarter.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.starterStages?.count ?? 0)"
        lblCounter.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.counterStages?.count ?? 0)"
        lblOmega.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.omegaAndBattleFieldsStages?.count ?? 0)"
        lblCharBan.text = "\(APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.characterBans?.count ?? 0)"
        lblTimeMatchRound.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.timeBetweenMatchRounds
        lblTimeSelectChar.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.timeToSelectStage
        lblTimebanStage.text = APIManager.sharedManager.leagueInfo?.matchDetails?.playoffs?.timeToBanOrPickStage
    }
}

