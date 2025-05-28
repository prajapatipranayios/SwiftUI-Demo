//
//  CancelTicketPopupVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 14/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class SelectCategoryPopupVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    // MARK: - Controls

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnVeg: UIButton!
    @IBOutlet weak var btnNonveg: UIButton!
    @IBOutlet weak var btnBoth: UIButton!
    @IBOutlet weak var bothButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bothButtonTopConstraint: NSLayoutConstraint!

    var isComeFromPost = false
    var categoryId = 1
    
    var tapYes:((Int)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        if isComeFromPost {
            bothButtonHeightConstraint.constant = 0.0
            bothButtonTopConstraint.constant = 0.0
            btnBoth.isHidden = true
        }else {
            bothButtonHeightConstraint.constant = 40.0
            bothButtonTopConstraint.constant = 16.0
            btnBoth.isHidden = false
        }
        
        self.view.layoutIfNeeded()
                
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 20.0
        
        
        btnVeg.layer.cornerRadius = btnVeg.frame.size.height / 2
        btnVeg.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        btnVeg.layer.borderWidth = 1.0
        
        btnNonveg.layer.cornerRadius = btnNonveg.frame.size.height / 2
        btnNonveg.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        btnNonveg.layer.borderWidth = 1.0
        
        btnBoth.layer.cornerRadius = btnBoth.frame.size.height / 2
        btnBoth.layer.borderColor = Colors.themeGreen.returnColor().cgColor
        btnBoth.layer.borderWidth = 1.0
        
        setDefaultView()
        setButtonView(tag: categoryId)
    }
    
    func setButtonView(tag: Int) {
        categoryId = tag
        
        switch tag {
        case 1:
            btnVeg.backgroundColor = Colors.themeGreen.returnColor()
            btnVeg.setTitleColor(UIColor.white, for: .normal)
        case 2:
            btnNonveg.backgroundColor = Colors.themeGreen.returnColor()
            btnNonveg.setTitleColor(UIColor.white, for: .normal)
        case 3:
            btnBoth.backgroundColor = Colors.themeGreen.returnColor()
            btnBoth.setTitleColor(UIColor.white, for: .normal)
        default:
            btnVeg.backgroundColor = Colors.themeGreen.returnColor()
            btnVeg.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    func setDefaultView() {
        btnVeg.backgroundColor = .white
        btnVeg.setTitleColor(UIColor.white, for: .normal)
        btnNonveg.backgroundColor = .white
        btnNonveg.setTitleColor(UIColor.black, for: .normal)
        btnBoth.backgroundColor = .white
        btnBoth.setTitleColor(UIColor.black, for: .normal)
        btnVeg.backgroundColor = .white
        btnVeg.setTitleColor(UIColor.black, for: .normal)
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapCategory(_ sender: UIButton) {
        setDefaultView()
        setButtonView(tag: sender.tag)
    }
    
    @IBAction func yesTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapYes != nil {
                self.tapYes!(self.categoryId)
            }
        })
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
