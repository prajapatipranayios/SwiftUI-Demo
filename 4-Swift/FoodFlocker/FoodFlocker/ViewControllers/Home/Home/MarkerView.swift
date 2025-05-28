//
//  MarkerView.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 07/05/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class MarkerView: UIView {

    // MARK: - Variables
    var img: UIImage!
    
    init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        self.img = image
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Methods
    func setupViews() {
        let imgView = UIImageView(image: img)
        //self.backgroundColor = UIColor.red
        //imgView.backgroundColor = UIColor.black
        imgView.frame = CGRect(x: 3, y: 3, width: 30, height: 50)
        imgView.contentMode = .scaleAspectFit
        //imgView.clipsToBounds = true
        self.addSubview(imgView)
    }

}
