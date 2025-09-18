//
//  LeagueRulesVC.swift
//  Tussly
//
//  Created by Auxano on 21/06/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class LeagueRulesVC: UIViewController {
    
    // MARK: - Variables
    
    //Outlets
    @IBOutlet weak var viewGameRule: UIScrollView!
    @IBOutlet weak var viewArenaRule: UIScrollView!
    @IBOutlet weak var viewGameRuleLine: UIView!
    @IBOutlet weak var viewArenaRuleLine: UIView!
    @IBOutlet weak var viewGame: UIView!
    @IBOutlet var viewGameSettingLine: UIView!
    @IBOutlet var viewSystemLine: UIView!
    @IBOutlet var viewRuleLine: UIView!
    @IBOutlet var viewCodeLine: UIView!
    @IBOutlet weak var lblMessage : UILabel!
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblVisibility : UILabel!
    @IBOutlet weak var lblFormat : UILabel!
    @IBOutlet weak var lblRotation : UILabel!
    @IBOutlet weak var lblCustomStage : UILabel!
    @IBOutlet weak var lblStage : UILabel!
    @IBOutlet weak var lblMaxPlayer : UILabel!
    @IBOutlet weak var lblAmibos : UILabel!
    @IBOutlet weak var lblChat : UILabel!
    @IBOutlet weak var lblArenaSpirit : UILabel!
    @IBOutlet weak var lblMusic : UILabel!
    
    @IBOutlet weak var lblStyle : UILabel!
    @IBOutlet weak var lblTimeLimit : UILabel!
    @IBOutlet weak var lblFSMeter : UILabel!
    @IBOutlet weak var lblSpirit : UILabel!
    @IBOutlet weak var lblCPU : UILabel!
    @IBOutlet weak var lblDamageHandicap : UILabel!
    @IBOutlet weak var lblStageSelection : UILabel!
    @IBOutlet weak var lblItems : UILabel!
    @IBOutlet weak var tvRandomStage : UITextView!
    @IBOutlet weak var lblFirstTo : UILabel!
    @IBOutlet weak var lblStageMorph : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewGameRule.isHidden = true
        viewGameRuleLine.isHidden = true
        viewSystemLine.isHidden = true
        viewRuleLine.isHidden = true
        viewCodeLine.isHidden = true
        
        lblType.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.type
        lblVisibility.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.visibility
        lblFormat.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.format
        lblRotation.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.rotation
        lblStage.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.arenaStage
        lblMaxPlayer.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.maxPlayer
        lblCustomStage.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.customStages
        lblAmibos.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.amiibos
        lblChat.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.voiceChat
        lblArenaSpirit.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.arenaSpirits
        lblMusic.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.arenaRules?.roomMusic
        
        lblStyle.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.style
        lblTimeLimit.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.timeLimit
        lblFSMeter.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.fsMeter
        lblSpirit.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.gameSpirits
        lblCPU.text = "\(APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.CPULevel ?? 0)"
        lblDamageHandicap.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.damageHandicap
        lblStageSelection.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.gameStage
        lblItems.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.items
        lblFirstTo.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.firstTo
        lblStageMorph.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.stageMorph
        tvRandomStage.text = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.gameSettings?.gameRules?.randomStage
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func arenaOption() {
        viewGameSettingLine.isHidden = false
        viewCodeLine.isHidden = true
        viewRuleLine.isHidden = true
        viewSystemLine.isHidden = true
        viewGame.isHidden = false
        viewArenaRule.isHidden = false
        viewGameRule.isHidden = true
        viewArenaRuleLine.isHidden = false
        viewGameRuleLine.isHidden = true
    }
    
    func gameOption() {
        viewArenaRule.isHidden = true
        viewGameRule.isHidden = false
        viewArenaRuleLine.isHidden = true
        viewGameRuleLine.isHidden = false
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func optionsTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            arenaOption()
        } else {
            viewArenaRule.isHidden = true
            viewGameRule.isHidden = true
            viewGame.isHidden = true
            if sender.tag == 1 {
                viewGameSettingLine.isHidden = true
                viewCodeLine.isHidden = true
                viewRuleLine.isHidden = true
                viewSystemLine.isHidden = false
                lblMessage.attributedText = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.system?.htmlToAttributedString
            } else if sender.tag == 2 {
                viewGameSettingLine.isHidden = true
                viewCodeLine.isHidden = true
                viewRuleLine.isHidden = false
                viewSystemLine.isHidden = true
                lblMessage.attributedText = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.rules?.htmlToAttributedString
            } else {
                viewGameSettingLine.isHidden = true
                viewCodeLine.isHidden = false
                viewRuleLine.isHidden = true
                viewSystemLine.isHidden = true
                lblMessage.attributedText = APIManager.sharedManager.leagueInfo?.rulesAndRegulations?.codeOfConduct?.htmlToAttributedString
            }
        }
    }
    
    @IBAction func arenaRulesTapped(_ sender: UIButton) {
        arenaOption()
    }
    
    @IBAction func gameRulesTapped(_ sender: UIButton) {
        gameOption()
    }
        
}
