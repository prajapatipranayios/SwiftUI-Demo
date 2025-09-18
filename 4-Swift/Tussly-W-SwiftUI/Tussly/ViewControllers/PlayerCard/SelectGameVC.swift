//
//  SelectGameVC.swift
//  - This screen allows User to select Game from available options

//  Tussly
//
//  Created by Auxano on 18/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SelectGameVC: UIViewController {
    
    // MARK: - Variables
    var didSelectItem: (([Game])->Void)?
    var arrGameList = [Game]()
    var tempArray = [Game]()
    var arrSelected = [Game]()
    var isSingleSelection = false
    var isSelectType = false
    var didSelectType: ((String)->Void)?
    var arrType = ["Tournament"] //["League", "Tournament"]
    var type = "League"
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    // MARK: - Controls
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var tvGame : UITableView!
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewSub : UIView!
    @IBOutlet weak var btnAddGame : UIButton!
    @IBOutlet weak var heightTVGame : NSLayoutConstraint!
    @IBOutlet weak var bottomSheetbottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var heightBtnAdd : NSLayoutConstraint!
    @IBOutlet weak var heightBtnCancel : NSLayoutConstraint!
    @IBOutlet weak var btnTopClose : UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSingleSelection {
            // By Pranay - add condition
            lblTitle.text = isSelectType ? Messages.selectType : Messages.selectGame
            // .
            heightBtnAdd.constant = 0
            heightBtnCancel.constant = 0
            btnTopClose.isHidden = false
            btnAddGame.isHidden = true
            btnCancel.isHidden = true
            
        } else {
            tvGame.separatorStyle = .none
            
            if self.arrSelected.count > 0 {
                self.btnAddGame.isEnabled = true
                self.btnAddGame.backgroundColor = Colors.theme.returnColor()
            } else {
                self.btnAddGame.isEnabled = false
                self.btnAddGame.backgroundColor = Colors.themeDisable.returnColor()
            }
        }
        
        if #available(iOS 11.0, *) {
            self.bottomSheetbottomConstraint.constant = -(self.viewSub.frame.height + view.safeAreaInsets.bottom + 16.0)
        } else {
            // Fallback on earlier versions
            self.bottomSheetbottomConstraint.constant = -(self.viewSub.frame.height + view.layoutMargins.bottom + 16.0)
        }
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.btnAddGame.layer.cornerRadius = 15
        }
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewMain)
        
        viewSub.layer.cornerRadius = 15.0
        tempArray = arrGameList
        tvGame.rowHeight = UITableView.automaticDimension
        tvGame.estimatedRowHeight = 100.0
        tvGame.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.openBottomSheet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvGame.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvGame.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                if newsize.height >= 170 {
                    self.heightTVGame.constant = 170
                } else {
                    self.heightTVGame.constant = newsize.height
                }
                self.updateViewConstraints()
            }
        }
    }
    
    // MARK: - UI Methods
    
    func openBottomSheet() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomSheetbottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        })
    }
    
    func closeBottomSheet() {
        UIView.animate(withDuration: 0.5, animations: {
            if #available(iOS 11.0, *) {
                self.bottomSheetbottomConstraint.constant = -(self.viewSub.frame.height + self.view.safeAreaInsets.bottom + 16.0)
            } else {
                // Fallback on earlier versions
                self.bottomSheetbottomConstraint.constant = -(self.viewSub.frame.height + self.view.layoutMargins.bottom + 16.0)
            }
            self.view.layoutIfNeeded()
        }) { (true) in
            self.dismiss(animated: true) {
                
            }
        }
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapAddGame(_ sender: UIButton) {
        if self.didSelectItem != nil {
            self.didSelectItem!(arrSelected)
        }
        closeBottomSheet()
    }
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        closeBottomSheet()
    }
}


// MARK: - UITableViewDelegate

extension SelectGameVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelectType ? arrType.count : tempArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGameCell", for: indexPath) as! SelectGameCell
        
        if isSelectType
        {
            cell.lblName.text = arrType[indexPath.row]
            
            if arrType[indexPath.row] == "League"
            {
                cell.ivLogo.image = UIImage(named: "League")
            }
            else
            {
                cell.ivLogo.image = UIImage(named: "Tournament")
            }
            
            cell.index = indexPath.row
            cell.onTapGameCell = { index in
                
                self.type = self.arrType[index]
                
                if self.didSelectType != nil
                {
                    self.didSelectType!(self.type)
                }
                self.closeBottomSheet()
                self.tvGame.reloadData()
            }
            cell.btnSelection.setImage(UIImage(named: ""), for: .normal)
           
            if (type == "Tournament" && indexPath.row == 1) || (type == "League" && indexPath.row == 0)
            {
                cell.btnSelection.setImage(UIImage(named: "Select"), for: .normal)
            }
//            else {
//                if isFilter && (type == "All" && indexPath.row == 2) {
//                    cell.btnSelection.setImage(UIImage(named: "Select"), for: .normal)
//                }
//            }
           
        }
        else
        {
            ////Beta 1 - diable game other than SSBU
            // By Pranay
            /*if tempArray[indexPath.row].gameName != "All" && tempArray[indexPath.row].gameName != "SSBU" {
                cell.lblName.textColor = Colors.border.returnColor()
                cell.ivLogo.setImageColor(color: Colors.border.returnColor())
            } else {
                cell.lblName.textColor = Colors.black.returnColor()
            }*/
            cell.lblName.textColor = Colors.black.returnColor()
            // .
            
            cell.lblName.text = tempArray[indexPath.row].gameName
            cell.ivLogo.setImage(imageUrl: tempArray[indexPath.row].gameLogo ?? tempArray[indexPath.row].gameImage)
            cell.index = indexPath.row
            cell.onTapGameCell = { index in
                ////Beta 1 - diable game other than SSBU
                /// 121
                //if self.tempArray[index].gameName != "All" && self.tempArray[index].gameName != "SSBU" {
                  //  return
                //}
                /// 121  -  comment By Pranay
                
                if self.isSingleSelection
                {
                    self.arrSelected.removeAll()
                    self.arrSelected.append(self.tempArray[index])
                    if self.didSelectItem != nil {
                        self.didSelectItem!(self.arrSelected)
                    }
                    self.closeBottomSheet()
                }
                else
                {
                    if self.arrSelected.count > 0
                    {
                        let mainIndex = self.arrSelected.firstIndex(where: {$0.id == self.tempArray[index].id })
                        
                        if mainIndex != nil
                        {
                            self.arrSelected.remove(at: mainIndex!)
                        }
                        else
                        {
                            self.arrSelected.append(self.tempArray[index])
                        }
                    }
                    else
                    {
                        self.arrSelected.append(self.tempArray[index])
                    }
                }
                
                if self.arrSelected.count > 0
                {
                    self.btnAddGame.isEnabled = true
                    self.btnAddGame.backgroundColor = Colors.theme.returnColor()
                }
                else
                {
                    self.btnAddGame.isEnabled = false
                    self.btnAddGame.backgroundColor = Colors.themeDisable.returnColor()
                }
                self.tvGame.reloadData()
            }
            
            if isSingleSelection
            {
                cell.btnSelection.setImage(UIImage(named: ""), for: .normal)
            }
            else
            {
                //cell.btnSelection.isSelected = false
                cell.btnSelection.setImage(UIImage(named: "Uncheck"), for: .normal)
            }
            
            if arrSelected.count > 0
            {
                let mainIndex = arrSelected.firstIndex(where: {$0.id == tempArray[indexPath.row].id })
                
                if mainIndex != nil
                {
                    //cell.btnSelection.isSelected = true
                    cell.btnSelection.setImage(UIImage(named: "Select"), for: .normal)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
