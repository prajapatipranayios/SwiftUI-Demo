//
//  CustomHeader.swift
//  Tussly
//
//  Created by Auxano on 04/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class CustomHeader: UITableViewHeaderFooterView {
    // MARK: - Controls
    
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var customImage: UIImageView!
    
    // MARK: - Variables
    
    static let reuseIdentifier = "CustomHeader"
    var onTapAddAccount: ((Int)->Void)?
    var sectionNumber: Int!

    @IBAction func didTapButton(_ sender: AnyObject) {
        if self.onTapAddAccount != nil {
            self.onTapAddAccount!(sectionNumber)
        }
    }

}
