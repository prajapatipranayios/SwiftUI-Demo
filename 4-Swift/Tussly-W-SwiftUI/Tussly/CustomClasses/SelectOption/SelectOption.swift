//
//  SelectOption.swift
//  - This is a Popup which is used within multiple screens named below to select option from available:
//      1. Signup
//      2. Settings
//      3. Create Team
//      4. Edit team
//      5. Create Player Card
//      6. Manage League Roster
//      7. Manage Roster

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class SelectOption: UIViewController {
    
    // MARK: - Variables
    var didSelectItem: ((Int,Bool)->Void)?
    var selectedIndex = -1
    var gamerTag = [GamerTag]()
    var option = [String]()
    var titleTxt: String = ""
    var isImgPicker: Bool = false
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    // MARK: - Controls
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var tvGames : UITableView!
    @IBOutlet weak var viewMain : UIView!
    @IBOutlet weak var viewBottomSheet : UIView!
    @IBOutlet weak var bottomSheetbottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var heightTVOptions : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.bottomSheetbottomConstraint.constant = -(self.viewBottomSheet.frame.height + view.safeAreaInsets.bottom + 16.0)
        } else {
            self.bottomSheetbottomConstraint.constant = -(self.viewBottomSheet.frame.height + view.layoutMargins.bottom + 16.0)
        }
        self.view.layoutIfNeeded()
        
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
        viewBottomSheet.layer.cornerRadius = 15.0
        lblTitle.text = titleTxt
        tvGames.rowHeight = UITableView.automaticDimension
        tvGames.estimatedRowHeight = 100.0
        tvGames.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.openBottomSheet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tvGames.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tvGames.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                let newsize  = newvalue as! CGSize
                self.heightTVOptions.constant = newsize.height
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
    
    func closeBottomSheet(index :Int) {
        UIView.animate(withDuration: 0.5, animations: {
            if #available(iOS 11.0, *) {
                self.bottomSheetbottomConstraint.constant = -(self.viewBottomSheet.frame.height + self.view.safeAreaInsets.bottom + 16.0)
            } else {
                self.bottomSheetbottomConstraint.constant = -(self.viewBottomSheet.frame.height + self.view.layoutMargins.bottom + 16.0)
            }
            self.view.layoutIfNeeded()
        }) { (true) in
            self.dismiss(animated: true) {
                if self.option.count != 0 {
                    if self.didSelectItem != nil {
                        self.didSelectItem!(index,self.isImgPicker)
                    }
                }
            }
        }
        
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        closeBottomSheet(index: -1)
    }
}

// MARK: - UITableViewDelegate

extension SelectOption: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamerTag.count == 0 ? option.count : gamerTag.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectGamertagCell", for: indexPath) as! SelectGamertagCell
        cell.index = indexPath.row
        cell.btnGameName.setTitle(gamerTag.count == 0 ? option[indexPath.row] : gamerTag[indexPath.row].consoleName, for: .normal)
        cell.btnGameName.backgroundColor = UIColor.white
        cell.btnGameName.setTitleColor(gamerTag.count == 0 ? Colors.black.returnColor() : gamerTag[indexPath.row].isSelected != nil && gamerTag[indexPath.row].isSelected! ? Colors.border.returnColor() : Colors.black.returnColor(), for: .normal) // Jaimesh: Earlier it was Black only
        
        cell.btnGameName.isEnabled = gamerTag.count == 0 ? true : gamerTag[indexPath.row].isSelected != nil && gamerTag[indexPath.row].isSelected! ? false : true//Jaimesh
        
        /*////Beta 1 - disable visit store option
        if isImgPicker {
            if indexPath.row == 1 {
                cell.btnGameName.isEnabled = false
                cell.btnGameName.setTitleColor(Colors.border.returnColor(), for: .normal)
            }
        }   ///  */
        
        cell.viewBottom.isHidden = false
        
        if indexPath.row == selectedIndex - 1 {
            cell.viewBottom.isHidden = true
        }
        
        if selectedIndex == indexPath.row {
            cell.btnGameName.backgroundColor = Colors.theme.returnColor()
            cell.btnGameName.setTitleColor(UIColor.white, for: .normal)
            cell.viewBottom.isHidden = true
        }
        
        cell.onTapGamerCell = { index in
            self.selectedIndex = index
            self.tvGames.reloadData()
            if self.gamerTag.count == 0 {
            } else {
                if self.didSelectItem != nil {
                    self.didSelectItem!(self.selectedIndex,self.isImgPicker)
                }
            }
            self.closeBottomSheet(index: index)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
