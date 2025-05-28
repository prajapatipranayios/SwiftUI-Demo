//
//  GiveRateReviewVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 05/05/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatRatingView

class GiveRateReviewVC: UIViewController {

    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    // MARK: - Controls

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblRatings: UILabel!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var tvReview: UITextView!

    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnSkip: UIButton!

    var ratings: Double = -1
    
    var moduleId: Int?
    var module: String?
    var toUserId: Int?
    var dictParamsGiveRating = [String: Any]()

    var ontapUpdate: ((String)->Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 20.0
        btnSubmit.layer.cornerRadius = btnSubmit.frame.size.height / 2
        
        ratingView.delegate = self
        ratingView.isUserInteractionEnabled = false
        tvReview.delegate = self
        
        tvReview.layer.cornerRadius = 8.0
        tvReview.layer.borderWidth = 1.0
        tvReview.layer.borderColor = Colors.lightGray.returnColor().cgColor
        
        tvReview.text = "Write your review"
        tvReview.textColor = Colors.lightGray.returnColor()
        
        lblRatings.text = "\(Int(ratings))"
        ratingView.rating = ratings
        
    }
    
    // MARK: - Button Click Events
        
    @IBAction func submitTapped(_ sender: UIButton) {
        
        if tvReview.text == "" || tvReview.text == "Write your review" {
            lblError.getEmptyValidationString("review")
            tvReview.layer.borderColor = Colors.red.returnColor().cgColor
        } else {
            lblError.text = ""
            tvReview.layer.borderColor = Colors.gray.returnColor().cgColor
            
            dictParamsGiveRating = ["moduleId": moduleId!,
                                "module" : module!,
                                "toUserId": toUserId!,
                                "rate": ratings,
                                "review": tvReview.text.trimmedString.encodeEmoji]
            giveReviewRating()
        }
        
    }
    
    @IBAction func skipTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
    func giveReviewRating() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.giveReviewRating()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GIVE_RATE_REVIEW, parameters: dictParamsGiveRating) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    if self.ontapUpdate != nil {
                        self.ontapUpdate!(self.tvReview.text!)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
}

extension GiveRateReviewVC: FloatRatingViewDelegate, UITextViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        self.ratings = rating
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString: NSString = textView.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString

        return newString.length <= TEXTVIEW_LIMIT
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write your review" {
            textView.text = ""
            textView.textColor = .black
        }
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write your review"
            textView.textColor = .lightGray
        }
    }
}
