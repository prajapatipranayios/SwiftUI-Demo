//
//  ViewEventVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import AVKit
import FloatingPanel
import FloatRatingView

class ViewEventVC: UIViewController, FloatRatingViewDelegate {

    //Outlets
    @IBOutlet weak var viewTop: UIView!

    @IBOutlet weak var cvMedias: ImgSliderCV!
    @IBOutlet weak var pcMedias: CustomImagePageControl!
    @IBOutlet weak var btnConfirmTicket: UIButton!
    @IBOutlet weak var viewSoldOut: UIView!
    @IBOutlet weak var viewBottomContainer: UIView!
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnWriteReview: UIButton!
    @IBOutlet weak var viewWriteReview: UIView!
    @IBOutlet weak var rattingView: FloatRatingView!
    @IBOutlet weak var rattingDisplayView: FloatRatingView!
    
    @IBOutlet weak var widthRatingMain: NSLayoutConstraint!
    @IBOutlet weak var widthRatingDisplay: NSLayoutConstraint!
    
    var dictParamsGiveRating = [String: Any]()
    
    var fpc: FloatingPanelController!
    var fpcConfirmEvent: FloatingPanelController!
    var fpcOptions: FloatingPanelController!
    var blurView: UIVisualEffectView!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var dictParams = Dictionary<String, Any>()
    var eventId: Int = -1
    var isDownloadTicket = false
    
    var eventDetails: PostEventDetail?
    
    var isUpdated = false
    
    var ontapUpdate: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 20.0
        
        screenSize = 203.0
        
        blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
        blurEffect.setValue(2, forKeyPath: "blurRadius")
        blurView.effect = blurEffect
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(blurView)
        blurView.isHidden = true

        self.viewBottomContainer.roundCornersWithShadow(corners: [.topLeft,.topRight], radius: 20.0, bgColor: UIColor.white)
        self.viewBottomContainer.addShadow(offset: CGSize(width: 0, height: -5.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        self.btnConfirmTicket.layer.cornerRadius = self.btnConfirmTicket.frame.size.height / 2
        self.viewSoldOut.layer.cornerRadius = self.viewSoldOut.frame.size.height / 2
        
        cvMedias.currentPage = { currentIndex in
            self.pcMedias.currentPage = currentIndex
            self.pcMedias.updateDots()
        }
        
        cvMedias.playVideo = { videoURL in
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.player?.volume = 1.0
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
        
        dictParams.updateValue("Event", forKey: "module")
        dictParams.updateValue(eventId, forKey: "moduleId")
        
        btnConfirmTicket.isHidden = true
        viewSoldOut.isHidden = true
        lblStatus.isHidden = true
        viewWriteReview.isHidden = true
        rattingView.isHidden = true
        rattingView.delegate = self
        
        getEventDetails()
        
    }
    
    func setupEventDetails() {
        
        self.setBottomValue()
        
        //Setup Event Details
        let eventDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailsVC") as? EventDetailsVC
        eventDetailsVC?.eventDetails = eventDetails
        eventDetailsVC?.ontapTab = { index in
            if index == 0 {
                self.viewBottomContainer.isHidden = false
            }else {
                self.viewBottomContainer.isHidden = true
            }
        }
        fpc.set(contentViewController: eventDetailsVC)
        fpc.track(scrollView: eventDetailsVC?.svMain)
        fpc.addPanel(toParent: self, animated: true)

        view.bringSubviewToFront(viewBottomContainer)
        view.bringSubviewToFront(blurView)
        
        if (eventDetails?.medias!.count)! > 0 {
//            cvMedias.isCollectionType = false
            cvMedias.setupDataSource(medias: (eventDetails?.medias)!)
            pcMedias.isHidden = (eventDetails?.medias?.count)! < 2
            pcMedias.numberOfPages = (eventDetails?.medias?.count)!
                
            let videos = eventDetails?.medias!.filter { (mediaObj) -> Bool in
                mediaObj.mediaType == "Video"
            }
            var arrIndexs = Array<Int>()
            for video in videos! {
                arrIndexs.append((eventDetails?.medias?.firstIndex{$0.id == video.id})!)
            }
            pcMedias.videoIndex = arrIndexs
            pcMedias.updateDots()
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        dictParamsGiveRating = ["moduleId": eventDetails?.id ?? 0,
                                "module" : "Event",
                                "toUserId": eventDetails!.userId,
                                "rate": rating,
                                "review": ""]
        giveRating(rate: rating)
    }
    
    func setBottomValue() {
        
        btnConfirmTicket.isHidden = true
        viewSoldOut.isHidden = true
        lblStatus.isHidden = true
        viewWriteReview.isHidden = true
        rattingView.isHidden = true
        rattingView.delegate = self
        
        if self.eventDetails!.isExpire == 0 {
            if eventDetails?.isLimitedTicket == 1 && (eventDetails?.totalAvailbleTicket)! < 1 {
                btnConfirmTicket.isHidden = true
                viewSoldOut.isHidden = false
            }else {
                btnConfirmTicket.isHidden = false
                viewSoldOut.isHidden = true
            }
        }else {
            self.lblStatus.isHidden = false
            
            self.lblStatus.text = "Expire at \(eventDetails?.endDate ?? "")"
            self.lblStatus.textColor = Colors.gray.returnColor()
            
            if eventDetails?.isDownloadTicket == 1 {
                self.widthRatingMain.constant = 150.0
                self.widthRatingDisplay.constant = 110.0
                self.view.layoutIfNeeded()
                if self.eventDetails!.rate == 0 {
                    self.rattingView.isHidden = false
                    self.rattingView.isUserInteractionEnabled = true
                }else if self.eventDetails!.review == "" {
                    self.viewWriteReview.isHidden = false
                    self.rattingDisplayView.rating = Double(self.eventDetails?.rate ?? 0.0)
                    self.rattingDisplayView.isUserInteractionEnabled = false
                }else {
                    self.rattingView.isHidden = false
                    self.rattingView.rating = Double(self.eventDetails!.rate ?? 0.0)
                    self.rattingView.isUserInteractionEnabled = false
                }
            }else {
                self.widthRatingMain.constant = 0.0
                self.widthRatingDisplay.constant = 0.0
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    // MARK: - Button Click Events
        
    @IBAction func onTapBack(_ sender: UIButton) {
        if isUpdated {
            if ontapUpdate != nil {
                self.ontapUpdate!()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapReview(_ sender: UIButton) {
        let giveRateVC = self.storyboard?.instantiateViewController(withIdentifier: "GiveRateReviewVC") as! GiveRateReviewVC
        giveRateVC.module = "Event"
        giveRateVC.moduleId = eventDetails?.id
        giveRateVC.ratings = eventDetails?.rate ?? 0.0
        giveRateVC.toUserId = eventDetails?.userId
        giveRateVC.ontapUpdate = { review in
            self.eventDetails?.review = review
            self.setBottomValue()
        }
        giveRateVC.modalPresentationStyle = .overCurrentContext
        giveRateVC.modalTransitionStyle = .crossDissolve
        self.view!.ffTabVC.present(giveRateVC, animated: true, completion: nil)
        
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        fpcOptions = FloatingPanelController()
        fpcOptions.delegate = self
        fpcOptions.surfaceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        fpcOptions.surfaceView.cornerRadius = 20.0
        fpcOptions.isRemovalInteractionEnabled = true
        
            
//        if APIManager.sharedManager.user?.id == eventDetails?.userId {
//            screenSize = 225.0
//
//            //Setup Post Details
//            let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseEventOptionVC") as? ChooseEventOptionVC
//    //        chooseOptionVC?.module = "Post"
//    //        chooseOptionVC?.postEventDetails = postDetails
//            chooseOptionVC?.removePanel = { selectedIndex in
//                self.fpcOptions?.removePanelFromParent(animated: false)
//                self.blurView.isHidden = true
//
//                if selectedIndex == 0 {
//                    //Edit Event
//                    let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
//                    addEventVC.eventId = self.eventDetails!.id
//                    addEventVC.eventDetails = self.eventDetails!
//                    addEventVC.isComeForUpdate = true
//                    addEventVC.ontapUpdate = {
//                        self.getEventDetails()
//                        self.isUpdated = true
//                    }
//                    self.navigationController?.pushViewController(addEventVC, animated: true)
//                }else if selectedIndex == 1 {
//                    //Duplicate Event
//                    let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
//                    addEventVC.eventId = self.eventDetails!.id
//                    addEventVC.eventDetails = self.eventDetails!
//                    addEventVC.isComeForDuplicate = true
//                    addEventVC.ontapUpdate = {
//                        self.getEventDetails()
//                        self.isUpdated = true
//                    }
//                    self.navigationController?.pushViewController(addEventVC, animated: true)
//                }else {
//                    //Remove Event
//                    self.removeEvent()
//                }
//
//            }
//    //        postDetailsVC?.postDetails = postDetails
//            fpcOptions?.set(contentViewController: chooseOptionVC)
//    //        fpc.track(scrollView: postDetailsVC?.svMain)
//            fpcOptions?.addPanel(toParent: self, animated: true)
//            blurView.isHidden = false
//
//        } else {
            
            if eventDetails?.isDownloadTicket == 1 {
                screenSize = 225.0
                            
                //Setup Post Details
                let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseEventOptionVC") as? ChooseEventOptionVC
                chooseOptionVC?.isComeDownload = true
                chooseOptionVC?.removePanel = { selectedIndex in
                    self.fpcOptions?.removePanelFromParent(animated: false)
                    self.blurView.isHidden = true
                    
                    if selectedIndex == 0 {
                        //Report Post
                        let downloadTicketVC = self.storyboard?.instantiateViewController(withIdentifier: "DownloadEventTicketVC") as! DownloadEventTicketVC
                        downloadTicketVC.eventDetails = self.eventDetails
                        downloadTicketVC.modalPresentationStyle = .overCurrentContext
                        downloadTicketVC.modalTransitionStyle = .crossDissolve

                        self.navigationController?.pushViewController(downloadTicketVC, animated: true)
                    } else if selectedIndex == 1 {
                        //Share Post
                        let text = "Get it for free at \("App Name")"
                        let shareAll = [text] as [Any]
                        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true) {
                            
                        }
                    } else {
                        //Report Post
                        let reportPostVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportPostVC") as! ReportPostVC
                        reportPostVC.module = "Event"//module
                        reportPostVC.moduleId = self.eventDetails!.id
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
                chooseOptionVC?.postEventDetails = eventDetails
                chooseOptionVC?.removePanel = { selectedIndex in
                    self.fpcOptions.removePanelFromParent(animated: false)
                    self.blurView.isHidden = true
                    if selectedIndex == 0 {
                         //Share Post
                       let text = "Get it for free at \("App Name")"
                       let shareAll = [text] as [Any]
                       let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
                       activityViewController.popoverPresentationController?.sourceView = self.view
                       self.present(activityViewController, animated: true) {
                           
                       }
                    } else {
                        //Report Post
                        let reportPostVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportPostVC") as! ReportPostVC
                        reportPostVC.module = "Event"//module
                        reportPostVC.moduleId = self.eventDetails!.id
                        self.navigationController?.pushViewController(reportPostVC, animated: true)
                    }
                }
                
        //        postDetailsVC?.postDetails = postDetails
                fpcOptions.set(contentViewController: chooseOptionVC)
        //        fpc.track(scrollView: postDetailsVC?.svMain)
                fpcOptions.addPanel(toParent: self, animated: true)
                blurView.isHidden = false
            }
            
//        }
            
    }

    @IBAction func onTapConfirmTicket(_ sender: UIButton) {
        
        fpcConfirmEvent = FloatingPanelController()
        fpcConfirmEvent.delegate = self
        fpcConfirmEvent.surfaceView.backgroundColor = .clear
        fpcConfirmEvent.surfaceView.cornerRadius = 20.0
        fpcConfirmEvent.isRemovalInteractionEnabled = true
        
        screenSize = 203.0
        //Setup Post Details
        let selectTicketsVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectTicketsVC") as? SelectTicketsVC
        selectTicketsVC?.eventDetails = eventDetails
        selectTicketsVC?.removePanel = { ticketsCount in
            
            self.getEventDetails()
            self.eventDetails?.isDownloadTicket = 1
            
            self.fpcConfirmEvent.removePanelFromParent(animated: false, completion: {
                let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "EventBookedPopupVC") as! EventBookedPopupVC
                successPopup.modalPresentationStyle = .overCurrentContext
                successPopup.modalTransitionStyle = .crossDissolve
                self.present(successPopup, animated: true, completion: nil)
            })
            self.blurView.isHidden = true
        }
        fpcConfirmEvent.set(contentViewController: selectTicketsVC)
        fpcConfirmEvent.addPanel(toParent: self, animated: true)
        blurView.isHidden = false
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
    
    func getEventDetails() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getEventDetails()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_POST_EVENT_DETAILS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                print((response?.result?.eventDetail)!)
                self.eventDetails = (response?.result?.eventDetail)!
                DispatchQueue.main.async {
                    self.setupEventDetails()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func removeEvent() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.removeEvent()
                }
            }
            return
        }
        
        let params = ["moduleId": eventDetails!.id, "module": "Event"] as [String : Any]
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_POST_EVENT, parameters: params) { (response: ApiResponse?, error) in
            self.hideLoading()
            DispatchQueue.main.async {
                if response?.status == 1 {
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
                    self.eventDetails?.rate = rate
                    self.setBottomValue()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
}

extension ViewEventVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpc.surfaceView.borderWidth = 0.0
        fpc.surfaceView.borderColor = nil
        if vc.contentViewController is EventDetailsVC {
            return EventDetailsLayout()
        } else {
            return ConfirmEventLayout()
        }
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class EventDetailsLayout: FloatingPanelLayout {
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

public class ConfirmEventLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return screenSize
            default: return nil
        }
    }
}
