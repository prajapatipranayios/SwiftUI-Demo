//
//  ChooseOptionVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 01/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ChooseOptionVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblMessage: UILabel!

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnReport: UIButton!

//    var module: String = ""
    var postEventDetails: PostEventDetail?
//    var createdBy: Int = -1
//    var moduleId: Int = -1

    var removePanel:((Int)->Void)?
    var openMediaPicker:((Int)->Void)?
    
    var chooseMedia: Bool = false
    var chooseProfile: Bool = false
    var isLogout: Bool = false
    var isFromChat: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        if isLogout == true {
            lblMessage.text = "Are you sure, you want to logout?"
            btnShare.setTitle("Cancel", for: .normal)
            btnReport.setTitle("Yes, logout", for: .normal)
        } else if chooseProfile == true {
            btnShare.setTitle("Take Photo", for: .normal)
            btnReport.setTitle("Choose Photo", for: .normal)
        } else if chooseMedia == true {
            btnShare.setTitle("Take Photo/Video", for: .normal)
            btnReport.setTitle("Choose Photo/Video", for: .normal)
        } else if isFromChat == true {
            btnShare.setTitle("View Profile", for: .normal)
            btnReport.setTitle("Clear Chat History", for: .normal)
        }else {
            if postEventDetails?.createdBy == APIManager.sharedManager.user?.id {
                btnShare.setTitle("Edit", for: .normal)
                btnReport.setTitle("Delete", for: .normal)
            }
        }
    }
    
    func setupUI() {
        btnShare.layer.cornerRadius = btnShare.frame.size.height / 2
        btnReport.layer.cornerRadius = btnReport.frame.size.height / 2
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapShare(_ sender: UIButton) {
        if chooseMedia == true {
            //"Take Photo/Video"
//            self.openCamera()
            if openMediaPicker != nil {
                openMediaPicker!(0)
            }
        }else if chooseProfile == true {
                    //"Take Photo/Video"
        //            self.openCamera()
            if openMediaPicker != nil {
                openMediaPicker!(0)
            }
        } else if isLogout == true {
            if removePanel != nil {
                removePanel!(0)
            }
        } else if isFromChat == true {
            if removePanel != nil {
                removePanel!(0)
            }
        } else {
            if removePanel != nil {
                removePanel!(0)
            }
        }
    }
    
    @IBAction func onTapReport(_ sender: UIButton) {
        if chooseMedia == true {
            //"Choose Photo/Video"
//            self.openGallary()
            if openMediaPicker != nil {
                openMediaPicker!(1)
            }
        }else if chooseProfile == true {
                    //"Choose Photo/Video"
        //            self.openGallary()
            if openMediaPicker != nil {
                openMediaPicker!(1)
            }
        } else if isLogout == true {
            if removePanel != nil {
                removePanel!(1)
            }
//            //User Logout
//            userLogout()
        }else if isFromChat == true {
            if removePanel != nil {
                removePanel!(1)
            }
            
        } else {
            if removePanel != nil {
                removePanel!(1)
            }
        }
    }
    
    // MARK: - Webservices
    

}
