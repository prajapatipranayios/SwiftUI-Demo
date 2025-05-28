//
//  FilterHistoryVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 27/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class FilterHistoryVC: UIViewController {

    //Outlets
    @IBOutlet var btnFilters: [UIButton]!

    var selectedIndex: Int = 0
    
    var filterHistory: ((Int)->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnFilters[selectedIndex].isSelected = true
        
    }
    
    // MARK: - Button Click Events

    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedIndex = sender.tag
        for btn in btnFilters {
            btn.isSelected = sender.tag == btn.tag ? true : false
        }
        if filterHistory != nil {
            filterHistory!(selectedIndex)
        }
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
