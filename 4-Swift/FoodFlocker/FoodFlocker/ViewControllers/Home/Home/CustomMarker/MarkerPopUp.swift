//
//  MarkerPopUp.swift
//  FastMenu
//
//  Created by Auxano on 16/04/19.
//  Copyright © 2019 Jaimesh Patel. All rights reserved.
//

import UIKit

protocol  MarkerPopUpDelegate {
    func didPressMarker(index: Int)
}

class MarkerPopUp: UIView {

    var index = 0
    var delegate: MarkerPopUpDelegate?
    
    @IBOutlet weak var imgMarker : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgMarker.layer.cornerRadius = 3.0
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func onClickMarker(_ sender: Any) {
        delegate?.didPressMarker(index: index)
    }
}
