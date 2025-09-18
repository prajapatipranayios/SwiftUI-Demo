//
//  BracketFilterPopupVC.swift
//  Tussly
//
//  Created by MAcBook on 11/07/22.
//  Copyright © 2022 Auxano. All rights reserved.
//  By Pranay

import UIKit

class BracketFilterPopupVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var tapOk: (([Any])->Void)?
    var tapClose: (()->Void)?
    var arrFilterPool : [filterPoolBracket] = []
    var myPoolTypeLabel: String?
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tblBracketFilter: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tblBracketFilter.dataSource = self
        tblBracketFilter.delegate = self
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension BracketFilterPopupVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilterPool.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BracketFilterPopupTVCell", for: indexPath) as! BracketFilterPopupTVCell
        cell.lblFilterPool.text = (arrFilterPool[indexPath.row].poolTypeLabel)!
        cell.lblMyPool.isHidden = (arrFilterPool[indexPath.row].poolTypeLabel)! == myPoolTypeLabel ? false : true
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row - \(indexPath.row + 1)")
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!([indexPath.row])
            }
        })
    }
}
