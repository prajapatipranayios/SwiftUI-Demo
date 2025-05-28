//
//  ChooseOptionVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ChooseEventOptionVC: UIViewController {

    //Outlets
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDuplicate: UIButton!
    @IBOutlet weak var btnRemove: UIButton!

    
    var removePanel:((Int)->Void)?
    
    var selectedIndex: Int = -1
    
    var isComeDownload = false
    var isComeDownloadReceipt = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    func setupUI() {
        btnEdit.layer.cornerRadius = btnEdit.frame.size.height / 2
        btnDuplicate.layer.cornerRadius = btnDuplicate.frame.size.height / 2
        btnRemove.layer.cornerRadius = btnRemove.frame.size.height / 2
        
        if isComeDownload {
            btnEdit.setTitle("Download Ticket", for: .normal)
            btnDuplicate.setTitle("Share", for: .normal)
            btnRemove.setTitle("Report", for: .normal)

        }else if isComeDownloadReceipt {
            btnEdit.setTitle("Share", for: .normal)
            btnDuplicate.setTitle("Download Recipt", for: .normal)
            btnRemove.setTitle("Report", for: .normal)

        }
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapEdit(_ sender: UIButton) {
        selectedIndex = 0
        if removePanel != nil {
            removePanel!(selectedIndex)
        }
    }
    
    @IBAction func onTapDuplicate(_ sender: UIButton) {
        selectedIndex = 1
        if removePanel != nil {
            removePanel!(selectedIndex)
        }
    }
    
    @IBAction func onTapRemove(_ sender: UIButton) {
        selectedIndex = 2
        if removePanel != nil {
            removePanel!(selectedIndex)
        }
    }
    
}
