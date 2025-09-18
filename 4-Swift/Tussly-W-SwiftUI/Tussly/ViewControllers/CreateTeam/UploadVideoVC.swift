//
//  UploadVideoVC.swift
//  Tussly
//
//  Created by Auxano on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

class UploadVideoVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Controls
    
    @IBOutlet weak var lblUrlError : UILabel!
    @IBOutlet weak var lblCaptionError : UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnUpload : UIButton!
    @IBOutlet weak var btnCaption: UIButton!
    @IBOutlet weak var txtUrl : UITextField!
    @IBOutlet weak var txtCaption : UITextView!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - Variable
    
    var uploadYoutubeVideo: ((String,String,String,String,String)->Void)?
    var EditYoutubeVideo: ((String,String,Int)->Void)?
    var cancelVideo:(()-> Void)?
    var isEdit = false
    var videoId = ""
    var thumbLink = ""
    var videoUrl = ""
    var videoCaption = ""
    var index = -1
    var duration = ""
    var titleString = ""
    var isValid = false
    var captionText = ""
    var viewCount = ""
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleString
//        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurEffectView)
        let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        view.addSubview(blurView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        view.bringSubviewToFront(viewContainer)
        viewContainer.layer.cornerRadius = 15.0
        btnUpload.layer.cornerRadius = 15.0
        if isEdit {
            txtUrl.isUserInteractionEnabled = false
            txtUrl.text = videoUrl
            txtCaption.text = videoCaption
            self.txtCaption.becomeFirstResponder()
            self.txtCaption.resignFirstResponder()
            self.txtCaption.becomeFirstResponder()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleViewTap(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapUpload(_ sender: UIButton) {
        if isEdit {
            if txtCaption.text != "" {
                if self.EditYoutubeVideo != nil {
                    self.EditYoutubeVideo!(txtCaption.text,duration,index)
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                lblCaptionError.setLeftArrow(title: Empty_Caption)
            }
        } else {
            if txtUrl.text != "" && txtCaption.text != "" && isValid {
                if self.uploadYoutubeVideo != nil {
                    self.uploadYoutubeVideo!(txtCaption.text,txtUrl.text!,thumbLink,duration,viewCount)
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                if txtUrl.text == "" {
                    lblUrlError.getEmptyValidationString(txtUrl.placeholder ?? "")
                }
                if (txtCaption.text == "") {
                    lblCaptionError.setLeftArrow(title: Empty_Caption)
                }
            }
        }
    }
    
    @IBAction func onTapCancel(_ sender: UIButton) {
        if self.cancelVideo != nil {
            self.cancelVideo!()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapCaptionButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if txtUrl.text != "" {
            if sender.isSelected {
                if isEdit {
                    getYoutubeUrlData()
                } else {
                    txtCaption.text = captionText
                    self.txtCaption.becomeFirstResponder()
                    self.txtCaption.resignFirstResponder()
                    self.txtCaption.becomeFirstResponder()
                }
            }
        }
    }
    
    // MARK: APIs
    
    func getYoutubeUrlData() {
        videoId = videoId.getYoutubeVideoId(url: txtUrl.text!)
        showLoading()
        let strUrl = "https://www.googleapis.com/youtube/v3/videos?id=\(videoId)&key=\(AppInfo.YoutubeAPIKey.returnAppInfo())&part=snippet,contentDetails,statistics,status"
        APIManager.sharedManager.getYoutubeData(url: strUrl, parameters: nil) { (success, response, message) in
            self.hideLoading()
            DispatchQueue.main.async {
                let responseArray = response?["items"] as! [Dictionary<String, Any>]
                if responseArray.count > 0 {
                    let snippet = responseArray[0]["snippet"] as! Dictionary<String, Any>
                    let contentDetail = responseArray[0]["contentDetails"] as! Dictionary<String, Any>
                    let statisticsDetail = responseArray[0]["statistics"] as! Dictionary<String, Any>
                    self.duration = contentDetail["duration"]! as! String
                    self.isValid = true
                    self.thumbLink = ((snippet["thumbnails"] as! [String: Any])["medium"] as! [String: Any])["url"] as! String
                    self.captionText = (snippet["title"] as? String)!
                    self.viewCount = statisticsDetail["viewCount"]! as! String
                    //if self.isEdit {
                        if self.btnCaption.isSelected {
                            self.txtCaption.text = self.captionText
                            self.txtCaption.becomeFirstResponder()
                            self.txtCaption.resignFirstResponder()
                            self.txtCaption.becomeFirstResponder()
                        }
                    //}
                } else {
                    self.isValid = false
                    self.lblUrlError.getValidationString(self.txtUrl.placeholder ?? "")
                }
            }
        }    }
}

// MARK: UITextFieldDelegate

extension UploadVideoVC : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        isValid = false
        if textField.text == "" {
            lblUrlError.getEmptyValidationString(textField.placeholder ?? "")
        } else {
            lblUrlError.text = ""
            getYoutubeUrlData()
        }
    }
}

// MARK: UITextViewDelegate

extension UploadVideoVC : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            lblCaptionError.setLeftArrow(title: Empty_Caption)
        } else {
            lblCaptionError.text = ""
        }
    }
}
