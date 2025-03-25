//
//  ThirdScreenVC.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import UIKit

class ThirdScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnNextScreen(_ sender: UIButton) {
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForthScreenVC") as! ForthScreenVC
        self.navigationController?.pushViewController(navVC, animated: true)
    }
    
}
