//
//  ManagePaymentsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel

class ManagePaymentsVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var tvCards: UITableView!
    
    @IBOutlet weak var lblNoCards: UILabel!
    @IBOutlet weak var btnAddNew: UIButton!
    @IBOutlet weak var btnAddMore: UIButton!

    var cards = [Card]()
    var indexToUpdate: Int = -1
    
    var fpc: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
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
    }
    
    func setupUI() {
        screenSize = 365.0
        
        self.tvCards.isHidden = true
        self.lblNoCards.isHidden = false
        self.btnAddNew.isHidden = false
        
        self.viewTop.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        btnAddNew.layer.cornerRadius = btnAddNew.frame.size.height / 2
        btnAddMore.layer.cornerRadius = btnAddMore.frame.size.height / 2
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
                DispatchQueue.main.async {
                    if self.cards.count > 0 {
                        self.tvCards.dataSource = self
                        self.tvCards.delegate = self
                        self.tvCards.reloadData()
                        self.tvCards.isHidden = false
                        self.lblNoCards.isHidden = true
                        self.btnAddNew.isHidden = true
                    } else {
                        self.tvCards.isHidden = true
                        self.lblNoCards.isHidden = false
                        self.btnAddNew.isHidden = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.tvCards.isHidden = true
                    self.lblNoCards.isHidden = false
                    self.btnAddNew.isHidden = false
                }
            }
        }
    }
    
    func removeCard() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removeCard()
                }
            }
            return
        }
        
        let params = ["cardToken": cards[indexToUpdate].token]
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.REMOVE_CARD, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                self.cards.remove(at: self.indexToUpdate)
                self.indexToUpdate = -1
                DispatchQueue.main.async {
                    self.tvCards.reloadData()
                    if self.cards.count > 0 {
                        self.tvCards.isHidden = false
                        self.lblNoCards.isHidden = true
                        self.btnAddNew.isHidden = true
                    } else {
                        self.tvCards.isHidden = true
                        self.lblNoCards.isHidden = false
                        self.btnAddNew.isHidden = false
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
   }
    
    func setDefaultCard() {
         if !appDelegate.checkInternetConnection() {
             self.isRetryInternet { (isretry) in
                 if isretry! {
                     self.setDefaultCard()
                 }
             }
             return
         }
         
         let params = ["cardToken": cards[indexToUpdate].token]
         
         showLoading()
         APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_DEFAULT_CARD, parameters: params) { (response: ApiResponse?, error) in
             self.hideLoading()
             if response?.status == 1 {
                 Utilities.showPopup(title: response?.message ?? "", type: .success)
                 DispatchQueue.main.async {
                    for i in 0..<self.cards.count {
                        self.cards[i].primary = i == self.indexToUpdate
                    }
                    self.indexToUpdate = -1
                    self.tvCards.reloadData()
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

extension ManagePaymentsVC: UITableViewDataSource, UITableViewDelegate {
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
        cell.viewContainer.layer.borderWidth = card.primary == true ? 2.0 : 0.0
        
        cell.btnDelete.isHidden = card.primary == true ? true : false
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
        
        cell.ivCardDefault.isHidden = card.primary == true ? false : true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        if card.primary == false {
            indexToUpdate = indexPath.row
            setDefaultCard()
        }
    }
    
    @objc func deleteTapped(_ sender: UIButton) {
        indexToUpdate = sender.tag
        removeCard()
    }

}

extension ManagePaymentsVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        return AddNewCardLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class AddNewCardLayout: FloatingPanelLayout {
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
