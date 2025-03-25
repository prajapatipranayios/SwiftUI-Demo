//
//  SecondScreenVC.swift
//  SwiftDemo1
//
//  Created by Auxano on 24/03/25.
//

import UIKit

class SecondScreenVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnNextScreen(_ sender: UIButton) {
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdScreenVC") as! ThirdScreenVC
        self.navigationController?.pushViewController(navVC, animated: true)
    }
    
}
