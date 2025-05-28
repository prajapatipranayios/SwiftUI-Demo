//
//  PublishImageVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 24/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class PublishImageVC: UIViewController {

    //Outlets
    @IBOutlet weak var ivMedia: UIImageView!
    @IBOutlet weak var btnPublish: UIButton!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        ivMedia.image = image
    }
    
    func setupUI() {
        self.btnPublish.layer.cornerRadius = self.btnPublish.frame.size.height / 2
    }

    // MARK: - Button Click Events
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func publishTapped(_ sender: Any) {
        addMediaPost()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Webservices

    func addMediaPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addMediaPost()
                }
            }
            return
        }
        
        let params = ["mediaType": "Image"]
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.ADD_MEDIA_POST, fileName: "media", image: image, movieDataURL: nil, params: params) { (status, response, message) in
            self.hideLoading()
            if status {
                Utilities.showPopup(title: message ?? "", type: .success)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }

}
