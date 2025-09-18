//
//  ViewImageVideoVC.swift
//  Tussly
//
//  Created by Jaimesh Patel on 13/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import SDWebImage
//import ShipBookSDK

class ViewImageVideoVC: UIViewController {
    
    // MARK: - Variables
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var meiaURL: String?
    var tapOk: ((Bool)->Void)? // false = close dialog manually, true = opponent confirm score
    let db = Firestore.firestore()
    var listner: ListenerRegistration?
    var doc:DocumentSnapshot?
    var arrFire : FirebaseInfo?
    var roundVC = ArenaRoundResultVC()
//    fileprivate let log = ShipBook.getLogger(ViewImageVideoVC.self)
    
    // MARK: - Outlets
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var ivMedia: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgMedia: SDAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // By Pranay
        imgMedia = SDAnimatedImageView()
        btnClose.backgroundColor = .white
        btnClose.layer.cornerRadius = btnClose.frame.width / 2
        //.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.bringSubviewToFront(viewBG)
        
//        ivMedia.setImage(imageUrl: meiaURL ?? "")
        // By Pranay
        showLoading()
        let urlImg : URL = URL(string: meiaURL ?? "")!
        ivMedia.sd_setImage(with: urlImg, placeholderImage: UIImage(named: "default_character"), options: SDWebImageOptions(rawValue: 0)) { image, error, cacheType, imageURL in
            self.hideLoading()
        }
        //.
        
        viewBG.layer.cornerRadius = 15
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.closeBtn))
        viewBG.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
//        self.log.i("ViewImageVideoVC - get error while get data in listner -- \(APIManager.sharedManager.user?.userName ?? "")")  //  By Pranay.
        listner = db.collection((APIManager.sharedManager.match?.league?.leagueSlug)!).document(APIManager.sharedManager.firebaseId ?? "").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
//                self.log.e("ViewImageVideoVC - get error while get data in listner -- \(APIManager.sharedManager.user?.userName ?? "") -- Error-> \(err)")  //  By Pranay.
                print("Error getting documents: \(err)")
            } else {
                self.doc =  querySnapshot!
                if self.doc?.data()?["status"] as? String == Messages.scoreConfirm  {
                    self.listner?.remove()
                    self.dismiss(animated: true, completion: {
                        if self.tapOk != nil {
                            self.tapOk!(true)
                        }
                    })
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: - UI Methods
    @objc func willResignActive() {
        listner?.remove()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeBtn(_sender: UITapGestureRecognizer) {
        self.listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(false)
            }
        })
    }
    
    // MARK: - Button Click Events
    @IBAction func closeTapped(_ sender: UIButton) {
        self.listner?.remove()
        self.dismiss(animated: true, completion: {
            if self.tapOk != nil {
                self.tapOk!(false)
            }
        })
    }
}
