//
//  NoInternetConnectionVC.swift
//  - To represent "No Internet" screen which will be displayed when Internet connection lost.

//  FoodFlocker
//

import UIKit

class NoInternetConnectionVC: UIViewController {
    
    // MARK: - Variables
    var onTappedRetry:(() ->  Void)?
//    var infoFM = [[String : Any]]()
//    var selectedIndex: Int = 0
    
    // MARK: - Controls
    @IBOutlet weak var btnRetry: UIButton!
    
    // MARK: ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnRetry.backgroundColor = Colors.themeGreen.returnColor()
        btnRetry.layer.cornerRadius = btnRetry.frame.size.height / 2
    }
    
    // MARK: - Button Click Events
    
    // Check internet connectivity again
    @IBAction func onClickRetry(_ sender: Any) {
        if !appDelegate.checkInternetConnection() {
            return
        }
        
        onTappedRetry!()
        self.dismiss(animated: true, completion: nil)
    }
}
