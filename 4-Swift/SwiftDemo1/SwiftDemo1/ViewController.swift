//
//  ViewController.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/10/24.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func btnShowToastTap(_ sender: UIButton) {
        //let toast = ToastMessage()
        //toast.showToast(message: "Success!", type: .success, inView: self.view)
        //toast.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.orange, textColor: UIColor.black, inView: self.view)
        //toast.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
        
        ToastMessage.shared.showToast(message: "Success!", type: .success, inView: self.view)
        ToastMessage.shared.showToast(message: "Warning!", type: .warning, position: .top, backgroundColor: UIColor.yellow, textColor: UIColor.black, inView: self.view)
        ToastMessage.shared.showToast(message: "Failed!", type: .failure, position: .center, inView: self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
}

