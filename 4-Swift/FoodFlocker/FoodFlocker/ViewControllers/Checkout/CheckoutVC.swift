//
//  CheckoutVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 05/05/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel


class CheckoutVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tvCards: UITableView!
    
    @IBOutlet weak var lblNoCards: UILabel!
    @IBOutlet weak var btnAddNew: UIButton!
    @IBOutlet weak var btnAddMore: UIButton!
    
    @IBOutlet weak var btnPay: UIButton!

    var cards = [Card]()
    var selectedIndex: Int = -1
    
    var amount: String = ""
    var toUserId: Int = 0
    var moduleId: Int = 0
    
    var fpc: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    var ontapUpdate: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        btnPay.backgroundColor = Colors.inactiveButton.returnColor()
        getCards()
        
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
        
        btnPay.setTitle("Pay \(amount)", for: .normal)
        btnPay.isEnabled = false
    }
    
    func setupUI() {
        screenSize = 365.0
        
        self.tvCards.isHidden = true
        self.lblNoCards.isHidden = false
        self.btnAddNew.isHidden = false
        
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        btnAddNew.layer.cornerRadius = btnAddNew.frame.size.height / 2
        btnAddMore.layer.cornerRadius = btnAddMore.frame.size.height / 2
        btnPay.layer.cornerRadius = btnPay.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapAddNew(_ sender: UIButton) {
        addNewCard()
    }
    
    @IBAction func onTapAddMore(_ sender: UIButton) {
        addNewCard()
    }
    
    @IBAction func onTapPayAmount(_ sender: UIButton) {
        payAmount()
    }
    
    func addNewCard() {
        
        let addNewCardVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNewCardVC") as? AddNewCardVC
        
        addNewCardVC?.updateFrame = { size in
                    
            screenSize = size
                    
            self.fpc.set(contentViewController: addNewCardVC)
            self.fpc.addPanel(toParent: self, animated: false)
            self.blurView.isHidden = false
        }
        
        addNewCardVC?.removePanel = { card in
            self.fpc.removePanelFromParent(animated: false) {
                self.getCards()
                self.blurView.isHidden = true
            }
        }
        
        fpc.updateLayout()
        fpc.set(contentViewController: addNewCardVC)
        fpc.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
        
    }
    
    // MARK: - Webservices
    
    func getCards() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getCards()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_CARDS, parameters: nil) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.cards = (response?.result?.cardList)!
                
                for i in 0..<self.cards.count {
                    if self.cards[i].primary {
                        self.selectedIndex = i
                    }
                }
                
                DispatchQueue.main.async {
                    if self.cards.count > 0 {
                        if self.selectedIndex == -1 {
                            self.selectedIndex = 0
                        }
                        
                        self.tvCards.dataSource = self
                        self.tvCards.delegate = self
                        self.tvCards.reloadData()
                        self.tvCards.isHidden = false
                        self.lblNoCards.isHidden = true
                        self.btnAddNew.isHidden = true
                        self.btnPay.backgroundColor = Colors.orange.returnColor()
                        self.btnPay.isEnabled = true
                    } else {
                        self.tvCards.isHidden = true
                        self.lblNoCards.isHidden = false
                        self.btnAddNew.isHidden = false
                        self.btnPay.backgroundColor = Colors.inactiveButton.returnColor()
                        self.btnPay.isEnabled = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tvCards.isHidden = true
                    self.lblNoCards.isHidden = false
                    self.btnAddNew.isHidden = false
                    self.btnPay.backgroundColor = Colors.inactiveButton.returnColor()
                    self.btnPay.isEnabled = false
                }
            }
        }
    }
    
    func payAmount() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.payAmount()
                }
            }
            return
        }
        
        let arrAmount = self.amount.split(separator: "$")
        
        let dictParams = ["cardToken": cards[selectedIndex].token,
                          "description": "Testing Amount",
                          "amount": String(arrAmount[0]),
                          "toUserId": toUserId,
                          "module": "Post",
                          "moduleId": moduleId] as [String : Any]
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.TRANSACTION, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
//                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    
                    let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupVC") as! SuccessPopupVC
                    successPopup.titleString = "Your payment has been done successfully!"
                    successPopup.tapDone = {
                        if self.ontapUpdate != nil {
                            self.ontapUpdate!()
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    successPopup.modalPresentationStyle = .overCurrentContext
                    successPopup.modalTransitionStyle = .crossDissolve
                    
                    self.present(successPopup, animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CheckoutVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardTVCell", for: indexPath) as! CardTVCell
        
        let card = cards[indexPath.row]
     
        cell.lblName.text = card.name
        cell.lblCardNo.text = card.display_number
        
        if card.scheme == "visa" {
            cell.ivCardType.image = UIImage(named: "VISA")
        } else if card.scheme == "master" {
            cell.ivCardType.image = UIImage(named: "Master")
        } else {
            cell.ivCardType.image = UIImage(named: "American")
        }
        
        cell.viewContainer.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        if selectedIndex == indexPath.row {
            cell.ivCardDefault.isHidden = false
            cell.viewContainer.layer.borderWidth = 2.0
            
        } else {
            cell.ivCardDefault.isHidden = true
            cell.viewContainer.layer.borderWidth = 0.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
}

extension CheckoutVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        return AddNewCardLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}
