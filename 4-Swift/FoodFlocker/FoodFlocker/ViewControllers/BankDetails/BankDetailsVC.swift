//
//  BankDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/05/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel

class BankDetailsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    
    @IBOutlet weak var viewBankDetails: UIView!
    
    @IBOutlet weak var lblBankName: UILabel!
    @IBOutlet weak var lblAccNo: UILabel!
    @IBOutlet weak var lblBSBCode: UILabel!
    @IBOutlet weak var lblFullName: UILabel!

    @IBOutlet weak var btnEdit: UIButton!

    @IBOutlet weak var lblNoBankDetails: UILabel!
    @IBOutlet weak var btnAddBankDetails: UIButton!
    
    var fpc: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var blurView: UIVisualEffectView!
    
    var bankDetails: BankDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        screenSize = 385.0
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.cornerRadius = 30.0
        fpc.isRemovalInteractionEnabled = true
        

        blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(blurView)
        blurView.isHidden = true
        
        getBankDetail()
    }
    
    func setupUI() {
        
        self.viewBankDetails.isHidden = true
        self.btnEdit.isHidden = true
        self.lblNoBankDetails.isHidden = false
        self.btnAddBankDetails.isHidden = false
        
        viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        btnEdit.layer.cornerRadius = btnEdit.frame.size.height / 2
        btnAddBankDetails.layer.cornerRadius = btnAddBankDetails.frame.size.height / 2
        
        viewBankDetails.layer.cornerRadius = 20.0
        viewBankDetails.addShadow(offset: CGSize(width: 2.0, height: 2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.3)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapAddBankDetails(_ sender: UIButton) {
        addBankDetails()
    }
    
    @IBAction func onTapEdit(_ sender: UIButton) {
        addBankDetails()
    }

    func addBankDetails() {
        let addBankVC = self.storyboard?.instantiateViewController(withIdentifier: "AddBankDetailsVC") as? AddBankDetailsVC
        addBankVC?.bankDetails = bankDetails
        
        addBankVC?.updateFrame = { size in
                    
            screenSize = size
                    
            self.fpc.set(contentViewController: addBankVC)
            self.fpc.addPanel(toParent: self, animated: false)
            self.blurView.isHidden = false
        }
        
        addBankVC?.removePanel = { bankDetail in
            self.fpc.removePanelFromParent(animated: true) {
                self.bankDetails = bankDetail
                self.setupBankDetails()
                self.blurView.isHidden = true
            }
        }
        
        fpc.set(contentViewController: addBankVC)
        fpc.contentViewController?.view.backgroundColor = UIColor.white //Jaimesh
        
        fpc.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
    }
    
    func setupBankDetails() {
        self.viewBankDetails.isHidden = false
        self.btnEdit.isHidden = false
        self.lblNoBankDetails.isHidden = true
        self.btnAddBankDetails.isHidden = true
        
        lblBankName.text = bankDetails?.bank_account.bank_name
        lblAccNo.text = bankDetails?.bank_account.number
        lblBSBCode.text = bankDetails?.bank_account.bsb
        lblFullName.text = bankDetails?.bank_account.name
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Webservices
    
    func getBankDetail() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getBankDetail()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_BANK_DETAIL, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.bankDetails = response?.result?.userBankAccountDetail
                
                DispatchQueue.main.async {
                    self.setupBankDetails()
                }
            } else {
                DispatchQueue.main.async {
                    self.viewBankDetails.isHidden = true
                    self.btnEdit.isHidden = true
                    self.lblNoBankDetails.isHidden = false
                    self.btnAddBankDetails.isHidden = false
                }
            }
        }
    }

}

extension BankDetailsVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        return AddBankDetailsLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class AddBankDetailsLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return screenSize
            default: return nil
        }
    }
}
