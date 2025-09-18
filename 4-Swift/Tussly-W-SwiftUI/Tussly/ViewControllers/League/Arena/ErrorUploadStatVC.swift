//
//  ErrorUploadStatVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 20/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class ErrorUploadStatVC: UIViewController {

    //Outlets
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var viewContainer: UIView!

    var tapOK: (()->Void)?
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    func setupUI() {
        btnCapture.layer.cornerRadius = 15.0
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
    }

    // MARK: - Button Click Events
    
    @IBAction func captureTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            if self.tapOK != nil {
                self.tapOK!()
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
