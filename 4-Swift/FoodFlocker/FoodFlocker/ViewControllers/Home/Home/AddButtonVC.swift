//
//  HomeVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 29/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class AddButtonVC: UIViewController {

    //Outlets
    @IBOutlet weak var btnNewAdd: UIButton!
    @IBOutlet weak var btnAddPost: UIButton!
    @IBOutlet weak var btnCreateEvent: UIButton!
    @IBOutlet weak var viewAddButton: UIView!
    
    var onTappedDismiss: (()->Void)?
    var onTappedAddPost: (()->Void)?
    var onTappedCreateEvent: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewAddButton.isHidden = true
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.bringSubviewToFront(viewAddButton)
        
        
        let clickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.onUiViewClick))
        viewAddButton.addGestureRecognizer(clickGesture)
        
        animationAddButton()
    }
    
    // MARK: - Button Click Events
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UI Methods
    @objc func onUiViewClick(sender : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        self.onTappedDismiss!()
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        self.onTappedDismiss!()
    }
    
    @IBAction func onTapAddPost(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        self.onTappedAddPost!()
    }
    
    @IBAction func onTapCreateEvent(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
        self.onTappedCreateEvent!()
    }
    
    func animationAddButton() {
        
        self.btnNewAdd.isHidden = false
        self.viewAddButton.isHidden = false
        self.btnAddPost.isHidden = true
        self.btnCreateEvent.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIButton.animate(withDuration: 0.2, animations: {
                self.btnNewAdd.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 1.5)
                self.btnNewAdd.setImage(UIImage(named: "close_icon"), for: .normal)
            }) { (true) in
                UIButton.transition(with: self.btnAddPost, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.btnAddPost.isHidden = false
                }) { (true) in
                    UIButton.transition(with: self.btnCreateEvent, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.btnCreateEvent.isHidden = false
                    }) { (true) in
                        
                    }
                }
            }
        }
    }
    
}
