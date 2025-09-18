//
//  NoInternetConnectionVC.swift
//  - To represent "No Internet" screen which will be displayed when Internet connection lost.

//  FoodFlocker
//

import UIKit

class NoInternetConnectionVC: UIViewController {
    
    // MARK: - Variables
    var onTappedRetry:(() ->  Void)?
    
    // MARK: - Controls
    @IBOutlet weak var btnRetry: UIButton!
    
    // MARK: ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnRetry.layer.cornerRadius = 15.0
        APIManager.sharedManager.timer.invalidate()
        APIManager.sharedManager.timerRPC.invalidate()
        APIManager.sharedManager.timerPopup.invalidate()
    }
    
    // MARK: - Button Click Events
    
    // Check internet connectivity again
    @IBAction func onClickRetry(_ sender: Any) {
        
        if !Network.reachability.isReachable {
            return
        }
        
        onTappedRetry!()
        self.dismiss(animated: true, completion: nil)
    }
}
