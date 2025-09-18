//
//  VoteVC.swift
//  - Designed Vote screen for League Module
//
//  Created by Auxano on 23/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class VoteVC: UIViewController {
        // MARK: - Variables
    
        var didSelectItem: ((String,Int)->Void)?
        var arrPlayer = [Player]()
        var selectedIndex = -1
        private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
        // MARK: - Controls
        
        @IBOutlet weak var tvVote : UITableView!
        @IBOutlet weak var viewMain : UIView!
        @IBOutlet weak var viewSub : UIView!
        @IBOutlet weak var btnVote : UIButton!
        @IBOutlet weak var viewBottom : UIView!

        override func viewDidLoad() {
            super.viewDidLoad()
            DispatchQueue.main.async {
                self.btnVote.layer.cornerRadius = self.btnVote.frame.size.height / 2
            }
//            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//            let blurEffectView = UIVisualEffectView(effect: blurEffect)
//            blurEffectView.frame = view.bounds
//            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            view.addSubview(blurEffectView)
            
            let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
            blurEffect.setValue(2, forKeyPath: "blurRadius")
            blurView.effect = blurEffect
            view.addSubview(blurView)
            view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            
            view.bringSubviewToFront(viewMain)
            viewSub.layer.cornerRadius = 15.0
            viewBottom.addShadow(offset: CGSize(width: 0, height: -5), color: Colors.shadow.returnColor(), radius: 2.0, opacity: 0.2)
            tvVote.rowHeight = UITableView.automaticDimension
            tvVote.estimatedRowHeight = 100.0
            tvVote.reloadData()
        }
        
        // MARK: - Button Click Events

        @IBAction func onTapAddVote(_ sender: UIButton) {
            if self.didSelectItem != nil {
                if selectedIndex != -1 {
                    self.didSelectItem!(arrPlayer[selectedIndex].displayName!,arrPlayer[selectedIndex].id!)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        @IBAction func onTapCancel(_ sender: UIButton) {
            self.dismiss(animated: true, completion: nil)
        }
    }


    // MARK: - UITableViewDelegate

    extension VoteVC: UITableViewDelegate,UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrPlayer.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VoteCell", for: indexPath) as! VoteCell
            cell.lblName.text = arrPlayer[indexPath.row].displayName
            cell.ivProfile.setImage(imageUrl: arrPlayer[indexPath.row].avatarImage!)
            cell.index = indexPath.row
            cell.onTapVoteCell = { index in
                self.selectedIndex = index
                self.tvVote.reloadData()
            }
            cell.btnSelection.isSelected = false
            if selectedIndex == indexPath.row {
                cell.btnSelection.isSelected = true
            }
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
    }
