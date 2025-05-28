//
//  ViewPostVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 06/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import AVKit
import FloatingPanel
import FloatRatingView

class ViewPostVC: UIViewController, FloatRatingViewDelegate {

    //Outlets
    @IBOutlet weak var viewTop: UIView!

    @IBOutlet weak var cvFoodImgs: ImgSliderCV!
    @IBOutlet weak var pcFoodImgs: CustomImagePageControl!

    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblExpireTime: UILabel!
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var viewBottomContainer: UIView!
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnWriteReview: UIButton!
    @IBOutlet weak var viewWriteReview: UIView!
    @IBOutlet weak var rattingView: FloatRatingView!
    @IBOutlet weak var rattingDisplayView: FloatRatingView!
    
    var fpc: FloatingPanelController!
    var fpcOptions: FloatingPanelController!
    
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
    var blurView: UIVisualEffectView!

    var dictParams = Dictionary<String, Any>()
    var postId: Int = -1
    var isUpdated = 0
    var isDeleted = 0
    var postDetails: PostEventDetail?
    var ontapUpdateDelete: ((Int, Int)->Void)?
    
    var dictParamsGiveRating = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 20.0
        
        blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(blurView)
        blurView.isHidden = true

        screenSize = 180.0
        
        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        self.btnRequest.layer.cornerRadius = self.btnRequest.frame.size.height / 2
        self.btnPay.layer.cornerRadius = self.btnPay.frame.size.height / 2
        self.btnRequest.layer.borderWidth = 1.0
        
        cvFoodImgs.currentPage = { currentIndex in
            self.pcFoodImgs.currentPage = currentIndex
            self.pcFoodImgs.updateDots()
        }
        
        cvFoodImgs.playVideo = { videoURL in
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.player?.volume = 1.0
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        
        lblPrice.isHidden = true
        lblExpireTime.isHidden = true
        btnRequest.isHidden = true
        btnPay.isHidden = true
        lblStatus.isHidden = true
        viewWriteReview.isHidden = true
        rattingView.isHidden = true
        
        dictParams.updateValue("Post", forKey: "module")
        dictParams.updateValue(postId, forKey: "moduleId")
        getPostDetails()
    }
    
    func setupPostDetails() {
        
        if APIManager.sharedManager.user?.id == postDetails?.userId {
            self.viewBottomContainer.isHidden = true
        }else {
            self.viewBottomContainer.isHidden = false
        }
        
        //Setup Post Details
        let postDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsVC") as? PostDetailsVC
        postDetailsVC?.postDetails = postDetails
        fpc.set(contentViewController: postDetailsVC)
        fpc.track(scrollView: postDetailsVC?.svMain)
        fpc.addPanel(toParent: self, animated: true)

        view.bringSubviewToFront(viewBottomContainer)
        view.bringSubviewToFront(blurView)

        setBottomValue()
        
        if (postDetails?.medias!.count)! > 0 {
            
            cvFoodImgs.setupDataSource(medias: (postDetails?.medias)!)
            pcFoodImgs.isHidden = (postDetails?.medias?.count)! < 2
            pcFoodImgs.numberOfPages = (postDetails?.medias?.count)!
            
            let videos = postDetails?.medias!.filter { (mediaObj) -> Bool in
                mediaObj.mediaType == "Video"
            }
            var arrIndexs = Array<Int>()
            for video in videos! {
                arrIndexs.append((postDetails?.medias?.firstIndex{$0.id == video.id})!)
            }
            pcFoodImgs.videoIndex = arrIndexs
            pcFoodImgs.updateDots()
        }
    }
    
    func setBottomValue() {
        
        lblPrice.isHidden = true
        lblExpireTime.isHidden = true
        btnRequest.isHidden = true
        btnPay.isHidden = true
        lblStatus.isHidden = true
        viewWriteReview.isHidden = true
        rattingView.isHidden = true
        rattingView.delegate = self
        
        if self.postDetails!.requestStatus == "" || self.postDetails!.requestStatus == "Pending" {
            
            lblPrice.isHidden = false
            btnRequest.isHidden = false
            
            lblPrice.text = postDetails!.amount! == "$0" ? "Free" : postDetails!.amount!
            
            if postDetails!.expiringDate! != "" {
                lblExpireTime.isHidden = false
                
                let str = "Expire in " + postDetails!.expiringDate!
                let attributedString = NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.font: Fonts.Regular.returnFont(size: 12.0)])
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.gray.returnColor(), range: NSRange(location: 0, length: str.trimmedString.count))
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Colors.red.returnColor(), range: NSRange(location: 10, length: postDetails!.expiringDate!.count))
                
                lblExpireTime.attributedText = attributedString
                
            }
            
            self.btnRequest.setTitle((self.postDetails!.isRequested != nil && self.postDetails!.isRequested == 1) ? "Requested" : "Request", for: .normal)
            
            self.btnRequest.layer.borderColor = (self.postDetails!.isRequested != nil && self.postDetails!.isRequested == 1) ? Colors.gray.returnColor().cgColor : Colors.orange.returnColor().cgColor
            self.btnRequest.layer.backgroundColor = (self.postDetails!.isRequested != nil && self.postDetails!.isRequested == 1) ? UIColor.white.cgColor : Colors.orange.returnColor().cgColor
            
            self.btnRequest.setTitleColor((self.postDetails!.isRequested != nil && self.postDetails!.isRequested == 1) ? Colors.gray.returnColor() : UIColor.white, for: .normal)
            
        }else if self.postDetails!.requestStatus == "Accepted" && self.postDetails!.type != "Donate" {
            
            if (APIManager.sharedManager.user?.id == postDetails?.createdBy && postDetails?.type == "Buy") || (APIManager.sharedManager.user?.id != postDetails?.createdBy && postDetails?.type == "Sell") {
                
                btnPay.isHidden = false
                btnPay.setTitle("Pay \(postDetails!.amount!)", for: .normal)
            }else {
                self.viewBottomContainer.isHidden = true
            }
        }else if self.postDetails!.requestStatus == "Paid" || self.postDetails!.requestStatus == "Donate" {
            self.lblStatus.isHidden = false
            
            
            if (APIManager.sharedManager.user?.id == postDetails?.createdBy && postDetails?.type == "Buy") || (APIManager.sharedManager.user?.id != postDetails?.createdBy && postDetails?.type == "Sell") {
                
               self.lblStatus.text = self.postDetails!.amount == "$0" ? "Free" : "Paid"
            }else {
                self.lblStatus.text = self.postDetails!.amount == "$0" ? "Free" : "Receive"
            }
            
            if self.postDetails!.rate == 0 {
                self.rattingView.isHidden = false
                self.rattingView.isUserInteractionEnabled = true
            }else if self.postDetails!.review == "" {
                self.viewWriteReview.isHidden = false
                self.rattingDisplayView.rating = Double(self.postDetails!.rate ?? 0.0)
                self.rattingDisplayView.isUserInteractionEnabled = false
            }else {
                self.rattingView.isHidden = false
                self.rattingView.rating = Double(self.postDetails!.rate ?? 0.0)
                self.rattingView.isUserInteractionEnabled = false
            }
        }
    }

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        dictParamsGiveRating = ["moduleId": postDetails?.id ?? 0,
                                "module" : "Post",
                                "toUserId": APIManager.sharedManager.user?.id == postDetails!.createdBy ? (postDetails!.requestUserId ?? 0) : (postDetails!.createdBy ?? 0),
                                "rate": rating,
                                "review": ""]
        giveRating(rate: rating)
    }
    
    func savePdf(urlString:String, fileName:String) {
            DispatchQueue.main.async {
                let url = URL(string: urlString)
                let pdfData = try? Data.init(contentsOf: url!)
                let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
                let pdfNameFromUrl = "YourAppName-\(fileName).pdf"
                let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
                do {
                    try pdfData?.write(to: actualPath, options: .atomic)
                    print("pdf successfully saved!")
                } catch {
                    print("Pdf could not be saved")
                }
            }
        }

    func showSavedPdf(url:String, fileName:String) {
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).pdf") {
                       // its your file! do what you want with it!
                        
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
    }
    
    func save(urlString: String) {
        let url = URL(string: urlString)
        let df = DateFormatter()
        df.dateFormat = "dd_hh_mm_ss"
        let currentDate = df.string(from: Date())
        
        let fileName = "\(currentDate)\(String((url!.lastPathComponent)) as NSString)"
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        //Create URL to the source file you want to download
        let fileURL = URL(string: urlString)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL!)
        
        showLoading()
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                self.hideLoading()
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    do {
                        //Show UIActivityViewController to save the downloaded file
                        
                        let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        for indexx in 0..<contents.count {
                            if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                                let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                DispatchQueue.main.async {
                                    self.present(activityViewController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    catch (let err) {
                        print("error: \(err)")
                    }
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                self.hideLoading()
                print("Error took place while downloading a file. Error description: \(error?.localizedDescription ?? "")")
            }
        }
        task.resume()
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTapBack(_ sender: UIButton) {
        if self.ontapUpdateDelete != nil {
            self.ontapUpdateDelete!(isUpdated, isDeleted)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapPay(_ sender: Any) {
        
        let checkoutVC = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutVC") as! CheckoutVC
        checkoutVC.amount = postDetails!.amount!
        checkoutVC.toUserId = postDetails!.userId
        checkoutVC.moduleId = postDetails?.id ?? 0
        checkoutVC.ontapUpdate = {
            self.postDetails?.requestStatus = "Paid"
            self.setBottomValue()
        }
        
        self.view!.ffTabVC.navigationController?.pushViewController(checkoutVC, animated: true)
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        
        fpcOptions = FloatingPanelController()
        fpcOptions.delegate = self
        fpcOptions.surfaceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        fpcOptions.surfaceView.cornerRadius = 20.0
        fpcOptions.isRemovalInteractionEnabled = true
        
        if postDetails?.requestStatus == "Paid" || (self.postDetails!.requestStatus == "Donate" && self.postDetails?.amount != "$0" && self.postDetails?.amount != "") {
            screenSize = 225.0
                        
            //Setup Post Details
            let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseEventOptionVC") as? ChooseEventOptionVC
            chooseOptionVC?.isComeDownloadReceipt = true
            chooseOptionVC?.removePanel = { selectedIndex in
                self.fpcOptions?.removePanelFromParent(animated: false)
                self.blurView.isHidden = true
                
                if selectedIndex == 0 {
                    //Share Post
                    let text = "Get it for free at \("App Name")"
                    let shareAll = [text] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                    activityViewController.popoverPresentationController?.sourceView = self.view
                    self.present(activityViewController, animated: true) {
                        
                    }
                } else if selectedIndex == 1 {
//                    self.savePdf(urlString: (self.postDetails?.receipt)!, fileName: "hkfjhkfhasdf")
                    self.save(urlString: (self.postDetails?.receipt)!)
                } else {
                    //Report Post
                    let reportPostVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportPostVC") as! ReportPostVC
                    reportPostVC.module = "Event"//module
                    reportPostVC.moduleId = self.postDetails!.id
                    self.navigationController?.pushViewController(reportPostVC, animated: true)
                }
            }
            
            fpcOptions?.set(contentViewController: chooseOptionVC)
            fpcOptions?.addPanel(toParent: self, animated: true)
            blurView.isHidden = false

        }else {
            screenSize = 180.0
                    
                    //Setup Post Details
                    let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionVC") as? ChooseOptionVC
            //        chooseOptionVC?.module = "Post"
                    chooseOptionVC?.postEventDetails = postDetails
                    chooseOptionVC?.removePanel = { selectedIndex in
                        self.fpcOptions.removePanelFromParent(animated: false)
                        self.blurView.isHidden = true
                        if selectedIndex == 0 {
                            if self.postDetails?.createdBy == APIManager.sharedManager.user?.id {
                                //Edit Post
                                let addPostVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as! AddPostVC
                                addPostVC.postDetails = self.postDetails
                                addPostVC.ontapUpdate = {
                                    self.isUpdated = 1
                                    self.getPostDetails()
                                }
                                self.navigationController?.pushViewController(addPostVC, animated: true)
                            } else {
                                //Share Post
                                let text = "Get it for free at \("App Name")"
                                let shareAll = [text] as [Any]
                                let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                                activityViewController.popoverPresentationController?.sourceView = self.view
                                self.present(activityViewController, animated: true) {
                                    
                                }
                            }
                        } else {
                            if self.postDetails?.createdBy == APIManager.sharedManager.user?.id {
                                //Delete Post
                                self.removePost()
                            } else {
                                //Report Post
                                let reportPostVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportPostVC") as! ReportPostVC
                                reportPostVC.module = "Post"//module
                                reportPostVC.moduleId = self.postDetails!.id
                                self.navigationController?.pushViewController(reportPostVC, animated: true)
                            }
                        }
                    }
            //        postDetailsVC?.postDetails = postDetails
                    fpcOptions.set(contentViewController: chooseOptionVC)
            //        fpc.track(scrollView: postDetailsVC?.svMain)
                    fpcOptions.addPanel(toParent: self, animated: true)
                    blurView.isHidden = false
        }


    }
    
    @IBAction func onTapRequest(_ sender: UIButton) {
        sendRequest()
        
    }
    
    @IBAction func onTapReview(_ sender: UIButton) {
        let giveRateVC = self.storyboard?.instantiateViewController(withIdentifier: "GiveRateReviewVC") as! GiveRateReviewVC
        giveRateVC.module = "Post"
        giveRateVC.moduleId = postDetails?.id
        giveRateVC.ratings = postDetails?.rate ?? 0.0
        giveRateVC.toUserId = APIManager.sharedManager.user?.id == postDetails!.createdBy ? (postDetails!.requestUserId ?? 0) : (postDetails!.createdBy ?? 0)
        giveRateVC.ontapUpdate = { review in
            self.postDetails?.review = review
            self.setBottomValue()
        }
        giveRateVC.modalPresentationStyle = .overCurrentContext
        giveRateVC.modalTransitionStyle = .crossDissolve
        self.view!.ffTabVC.present(giveRateVC, animated: true, completion: nil)
        
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

    func getPostDetails() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getPostDetails()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_POST_EVENT_DETAILS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                self.postDetails = (response?.result?.postDetail)!
                DispatchQueue.main.async {
                    self.setupPostDetails()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func sendRequest() {
        
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.sendRequest()
                }
            }
            
            return
        }
        
        let dictParams = ["postId": postDetails!.id] as Dictionary<String, Any>
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SEND_REQUEST_FOR_POST, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    
                    if let isReq = self.postDetails?.isRequested {
                        self.postDetails?.isRequested = 1 - isReq
                    }
                                        
                    self.setBottomValue()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func removePost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removePost()
                }
            }
            return
        }
        
        let params = ["moduleId": postDetails!.id, "module": "Post"] as [String : Any]
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_POST_EVENT, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
                    self.isDeleted = 1
                    if self.ontapUpdateDelete != nil {
                        self.ontapUpdateDelete!(self.isUpdated, self.isDeleted)
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                } else {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                }
            }
        }
    }
    
    func giveRating(rate: Double) {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.giveRating(rate: rate)
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
                    self.postDetails?.rate = rate
                    self.setBottomValue()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension ViewPostVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        if vc.contentViewController is ChooseOptionVC {
            fpcOptions.surfaceView.borderWidth = 0.0
            fpcOptions.surfaceView.borderColor = nil
            return ChooseOptionLayout()
        }else if vc.contentViewController is ChooseEventOptionVC {
            fpcOptions.surfaceView.borderWidth = 0.0
            fpcOptions.surfaceView.borderColor = nil
            return ConfirmEventLayout()
        } else {
            fpc.surfaceView.borderWidth = 0.0
            fpc.surfaceView.borderColor = nil
            return SearchPanelLandscapeLayout()
        }
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class SearchPanelLandscapeLayout: FloatingPanelLayout {
    
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .full: return 64
        case .half: return UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.width - (Utilities.isIphoneXAbove() ? 0.0 : 40.0))
            default: return nil
        }
    }
}

public class ChooseOptionLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return 180.0
            default: return nil
        }
    }
}
