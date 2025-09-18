//
//  ArenaVC.swift
//  Tussly
//
//  Created by Auxano on 13/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ArenaGameSettingPopupVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    // MARK: - Outlets
    @IBOutlet weak var viewGameSetting : UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var viewGameRule: UIScrollView!
    @IBOutlet weak var viewArenaRule: UIScrollView!
    @IBOutlet weak var viewGameRuleLine: UIView!
    @IBOutlet weak var viewArenaRuleLine: UIView!
    @IBOutlet weak var lblRandomTop: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var label1 : UILabel!
    @IBOutlet weak var label2 : UILabel!
    @IBOutlet weak var label3 : UILabel!
    @IBOutlet weak var label4 : UILabel!
    @IBOutlet weak var label5 : UILabel!
    @IBOutlet weak var label6 : UILabel!
    @IBOutlet weak var label7 : UILabel!
    @IBOutlet weak var label8 : UILabel!
    @IBOutlet weak var label9 : UILabel!
    @IBOutlet weak var label10 : UILabel!
    @IBOutlet weak var labelAns1 : UILabel!
    @IBOutlet weak var labelAns2 : UILabel!
    @IBOutlet weak var labelAns3 : UILabel!
    @IBOutlet weak var labelAns4 : UILabel!
    @IBOutlet weak var labelAns5 : UILabel!
    @IBOutlet weak var labelAns6 : UILabel!
    @IBOutlet weak var labelAns7 : UILabel!
    @IBOutlet weak var labelAns8 : UILabel!
    @IBOutlet weak var labelAns9 : UILabel!
    @IBOutlet weak var labelAns10 : UILabel!
    
    @IBOutlet weak var lblStyle : UILabel!
    @IBOutlet weak var tvRandomStage : UITextView!
    @IBOutlet weak var lblFirstTo : UILabel!
    @IBOutlet weak var lblStageMorph : UILabel!
    @IBOutlet weak var lblHazard : UILabel!
    @IBOutlet weak var lblTeamAttack : UILabel!
    @IBOutlet weak var lblLaunchRate : UILabel!
    @IBOutlet weak var lblBoost : UILabel!
    @IBOutlet weak var lblPausing : UILabel!
    @IBOutlet weak var lblScoreDisplay : UILabel!
    @IBOutlet weak var lblShowDamage : UILabel!
    
    @IBOutlet weak var lblType : UILabel!
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

    // By Pranay
    @IBOutlet weak var viewGameBar: UIView!
    //.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// 333 - By Pranay
        viewGameBar.backgroundColor = UIColor(hexString: "\(APIManager.sharedManager.gameSettings?.colorCode ?? "")")
        /// 333 .   */
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewGameSetting)
        
        btnClose.layer.cornerRadius = 15
        viewGameRule.isHidden = true
        viewGameRuleLine.isHidden = true
        
        lblType.text = "All Skills Levels"
        lblVisibility.text = APIManager.sharedManager.content?.arenaRules?.visibility ?? ""
        lblFormat.text = APIManager.sharedManager.content?.arenaRules?.format ?? ""
        lblRotation.text = APIManager.sharedManager.content?.arenaRules?.rotation ?? ""
        lblStage.text = APIManager.sharedManager.content?.arenaRules?.arenaStage ?? ""
        lblMaxPlayer.text = APIManager.sharedManager.content?.arenaRules?.maxPlayer ?? ""
        lblCustomStage.text = APIManager.sharedManager.content?.arenaRules?.customStages ?? ""
        lblAmibos.text = APIManager.sharedManager.content?.arenaRules?.amiibos ?? ""
        lblChat.text = APIManager.sharedManager.content?.arenaRules?.voiceChat ?? ""
        lblArenaSpirit.text = APIManager.sharedManager.content?.arenaRules?.arenaSpirits ?? ""
        lblMusic.text = APIManager.sharedManager.content?.arenaRules?.roomMusic ?? ""
        
        let styleIs = APIManager.sharedManager.content?.leagueRules?.style ?? ""
        lblStyle.text = styleIs
        label1.text = styleIs == "Time" ? "Time Limit:" : (styleIs == "Stock" ? "Stock:" : "Stamina:")
        labelAns1.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.timeLimit ?? "") : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.stock ?? "") : "\(APIManager.sharedManager.content?.leagueRules?.stamina ?? 0)")
        
        label2.text = styleIs == "Time" ? "FS Meter:" : (styleIs == "Stock" ? "Time Limit:" : "Stock:")
        labelAns2.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.fsMeter ?? "") : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.timeLimit ?? "") : (APIManager.sharedManager.content?.leagueRules?.stock ?? ""))
        
        label3.text = styleIs == "Time" ? "Spirits:" : (styleIs == "Stock" ? "FS Meter:" : "Time Limit:")
        labelAns3.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.gameSpirits ?? "") : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.fsMeter ?? "") : (APIManager.sharedManager.content?.leagueRules?.timeLimit ?? ""))
        
        label4.text = styleIs == "Time" ? "CPU Levels:" : (styleIs == "Stock" ? "Spirits:" : "FS Meter:")
        labelAns4.text = styleIs == "Time" ? "\(APIManager.sharedManager.content?.leagueRules?.CPULevel ?? 0)" : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.gameSpirits ?? "") : (APIManager.sharedManager.content?.leagueRules?.fsMeter ?? ""))
        
        label5.text = styleIs == "Time" ? "Damage Handicap:" : (styleIs == "Stock" ? "CPU Levels:" : "Spirits:")
        labelAns5.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.damageHandicap ?? "") : (styleIs == "Stock" ? "\(APIManager.sharedManager.content?.leagueRules?.CPULevel ?? 0)" : (APIManager.sharedManager.content?.leagueRules?.gameSpirits ?? ""))
        
        label6.text = styleIs == "Time" ? "Stage Selection:" : (styleIs == "Stock" ? "Damage Handicap:" : "CPU Levels:")
        labelAns6.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.gameStage ?? "") : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.damageHandicap ?? "") : "\(APIManager.sharedManager.content?.leagueRules?.CPULevel ?? 0)")
        
        label7.text = styleIs == "Time" ? "Items:" : (styleIs == "Stock" ? "Stage Selection:" : "Damage Handicap:")
        labelAns7.text = styleIs == "Time" ? (APIManager.sharedManager.content?.leagueRules?.items ?? "") : (styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.gameStage ?? "") : (APIManager.sharedManager.content?.leagueRules?.damageHandicap ?? ""))
        
        label8.text = styleIs == "Stock" ? "Items:" : "Stage Selection:"
        labelAns8.text = styleIs == "Stock" ? (APIManager.sharedManager.content?.leagueRules?.items ?? "") : (APIManager.sharedManager.content?.leagueRules?.gameStage ?? "")
        
        label9.text = "Items:"
        labelAns9.text = APIManager.sharedManager.content?.leagueRules?.items ?? ""
        
        label10.text = "Add allowed or disallowed items:"
        labelAns10.text = APIManager.sharedManager.content?.leagueRules?.itemsOther ?? ""
        
        lblRandomTop.constant = styleIs == "Time" ? 320 : (styleIs == "Stock" ? 358 : 396)
        
        if styleIs == "Stock" {
            label9.text = ""
            labelAns9.text = ""
            viewHeight.constant = 895
        }
        
        if styleIs == "Time" {
            label9.text = ""
            labelAns9.text = ""
            label8.text = ""
            labelAns8.text = ""
            viewHeight.constant = 857
        }
        
        lblFirstTo.text = APIManager.sharedManager.content?.leagueRules?.firstTo ?? ""
        lblStageMorph.text = APIManager.sharedManager.content?.leagueRules?.stageMorph ?? ""
        tvRandomStage.text = APIManager.sharedManager.content?.leagueRules?.randomStage ?? ""
        //        lblSystemSetting.text = APIManager.sharedManager.content?.leagueRules?.systemSetting ?? ""
        //        lblCod.text = APIManager.sharedManager.content?.leagueRules?.codeOfConduct ?? ""
        //        lblRules.text = APIManager.sharedManager.content?.leagueRules?.rulesAndRegulation ?? ""
        lblHazard.text = APIManager.sharedManager.content?.leagueRules?.stageHazards ?? ""
        lblTeamAttack.text = APIManager.sharedManager.content?.leagueRules?.teamAttack ?? ""
        lblLaunchRate.text = APIManager.sharedManager.content?.leagueRules?.launchRate ?? ""
        lblBoost.text = APIManager.sharedManager.content?.leagueRules?.underdogBoost ?? ""
        lblPausing.text = APIManager.sharedManager.content?.leagueRules?.pausing ?? ""
        lblScoreDisplay.text = APIManager.sharedManager.content?.leagueRules?.scoreDisplay ?? ""
        lblShowDamage.text = APIManager.sharedManager.content?.leagueRules?.showDamage ?? ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func arenaRulesTapped(_ sender: UIButton) {
        viewArenaRule.isHidden = false
        viewGameRule.isHidden = true
        viewArenaRuleLine.isHidden = false
        viewGameRuleLine.isHidden = true
    }
    
    @IBAction func gameRulesTapped(_ sender: UIButton) {
        viewArenaRule.isHidden = true
        viewGameRule.isHidden = false
        viewArenaRuleLine.isHidden = true
        viewGameRuleLine.isHidden = false
    }
        
}
