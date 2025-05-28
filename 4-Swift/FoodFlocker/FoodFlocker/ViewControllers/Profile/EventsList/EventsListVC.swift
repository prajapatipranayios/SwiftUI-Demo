//
//  EventsListVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 10/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel
import FloatRatingView

class EventsListVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var viewOptionsContainer: UIView!
    
    @IBOutlet weak var tvContent: UITableView!
    @IBOutlet weak var viewEmptyData: UIView!
    
    @IBOutlet var btnOptions: [UIButton]!
    @IBOutlet var lblDots: [UILabel]!
    
    var selectedTabIndex = 0

    var dictParams = [String: Any]()
    
    var pageNoCreate = 1
    var pageNoConfirmed = 1
    var pageNoFavorite = 1
    
    var hasMoreCreate = -1
    var hasMoreConfirmed = -1
    var hasMoreFavorite = -1
    
    var eventsCreated = [PostEventDetail]()
    var eventsConfirmed = [PostEventDetail]()
    var eventsFavorite = [PostEventDetail]()
    
    var fpcOptions: FloatingPanelController?

    var dictParamsGiveRating = [String: Any]()
    
    var dictParam = [String: Any]()
    var indexToUpdate = -1
    
    var fpcConfirmEvent: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        onTapOptions(btnOptions[selectedTabIndex])
        
        tvContent.register(UINib(nibName: "EventTVCell", bundle: nil), forCellReuseIdentifier: "EventTVCell")
        tvContent.estimatedRowHeight = 118.0
        tvContent.rowHeight = UITableView.automaticDimension
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        for lbl in lblDots {
            lbl.layer.cornerRadius = lbl.frame.size.height / 2
            lbl.clipsToBounds = true
            lbl.backgroundColor = UIColor.white
        }
    }

    func setupUI() {
        viewTopContainer.roundCorners(radius: 20.0, arrCornersiOS11: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], arrCornersBelowiOS11: [.bottomRight , .bottomLeft])
        viewTopContainer.layer.masksToBounds = false
        viewTopContainer.layer.shadowRadius = 3.0
        viewTopContainer.layer.shadowOpacity = 0.3
        viewTopContainer.layer.shadowColor = UIColor.gray.cgColor
        viewTopContainer.layer.shadowOffset = CGSize(width: 0 , height:3)
        
        
        self.viewOptionsContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: Colors.themeGreen.returnColor())
        
    }
    
    // MARK: - Button Click Events
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapOptions(_ sender: UIButton) {
        selectedTabIndex = sender.tag
        if sender.tag == 0 {
            btnOptions[0].setTitleColor(UIColor.white, for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            btnOptions[2].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = false
            lblDots[1].isHidden = true
            lblDots[2].isHidden = true
            
            pageNoCreate = 1
            hasMoreCreate = -1
            eventsCreated.removeAll()
            tvContent.reloadData()
            dictParams.updateValue(pageNoCreate, forKey: "page")
            dictParams.updateValue("Create", forKey: "type")
            getEvents()
            
        } else if sender.tag == 1 {
            btnOptions[1].setTitleColor(UIColor.white, for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            btnOptions[2].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = false
            lblDots[2].isHidden = true
            
            pageNoConfirmed = 1
            hasMoreConfirmed = -1
            eventsConfirmed.removeAll()
            tvContent.reloadData()
            dictParams.updateValue(pageNoConfirmed, forKey: "page")
            dictParams.updateValue("Confirm", forKey: "type")
            getEvents()
            
        } else {
            btnOptions[2].setTitleColor(UIColor.white, for: .normal)
            btnOptions[0].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            btnOptions[1].setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
            lblDots[0].isHidden = true
            lblDots[1].isHidden = true
            lblDots[2].isHidden = false
            
            pageNoFavorite = 1
            hasMoreFavorite = -1
            eventsFavorite.removeAll()
            tvContent.reloadData()
            dictParams.updateValue(pageNoFavorite, forKey: "page")
            dictParams.updateValue("Save", forKey: "type")
            getEvents()
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
    
    // MARK: - Webservices

    func getEvents() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getEvents()
                }
            }
            return
        }
        
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_ALL_EVENTS, parameters: dictParams) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                if self.selectedTabIndex == 0 {
                    
                    self.eventsCreated.append(contentsOf: (response?.result?.eventList)!)
                    
                    if self.eventsCreated.count > 0 {
                        self.pageNoCreate += 1
                        self.hasMoreCreate = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                } else if self.selectedTabIndex == 1 {
                    self.eventsConfirmed.append(contentsOf: (response?.result?.eventList)!)
                    if self.eventsConfirmed.count > 0 {
                        self.pageNoConfirmed += 1
                        self.hasMoreConfirmed = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                } else {
                    self.eventsFavorite.append(contentsOf: (response?.result?.eventList)!)
                    if self.eventsFavorite.count > 0 {
                        self.pageNoFavorite += 1
                        self.hasMoreFavorite = (response?.result?.hasMore)!
                        DispatchQueue.main.async {
                            self.viewEmptyData.isHidden = true
                            self.tvContent.isHidden = false
                            self.tvContent.dataSource = self
                            self.tvContent.delegate = self
                            self.tvContent.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.tvContent.isHidden = true
                            self.viewEmptyData.isHidden = false
                        }
                    }
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func setReminder() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.setReminder()
                }
            }
            return
        }
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.SET_REMINDER, parameters: dictParam) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    self.tvContent.reloadData()
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
                
        showLoading()
        APIManager.sharedManager.postData(url: APIManager.sharedManager.DELETE_POST_EVENT, parameters: dictParam) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
                DispatchQueue.main.async {
                    self.eventsCreated.remove(at: self.indexToUpdate)
                    self.tvContent.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }
    
    func giveRating() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.giveRating()
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
                    self.eventsConfirmed[self.indexToUpdate].rate = (self.dictParamsGiveRating["rate"] as! Double)
                    self.tvContent.reloadData()
                }
            } else {
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
        }
    }

}

extension EventsListVC: UITableViewDataSource, UITableViewDelegate, FloatRatingViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedTabIndex {
            case 0:
                return eventsCreated.count
            case 1:
                return eventsConfirmed.count
            default:
                return eventsFavorite.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTVCell", for: indexPath) as! EventTVCell
        
        var event: PostEventDetail?
        cell.btnEvent.tag = indexPath.row
        cell.btnEvent.addTarget(self, action: #selector(onTapPostEvent(_:)), for: .touchUpInside)
        if selectedTabIndex == 0 {
            event = eventsCreated[indexPath.row]
            cell.widthBtnOptions.constant = 25.0
            cell.btnOptions.isHidden = false
            cell.viewRatings.isHidden = true
            cell.btnReminder.isHidden = true
            cell.btnCancelTicket.isHidden = true
            cell.btnConfirmTicket.isHidden = true
            cell.viewRatings.isHidden = true
            cell.btnWriteReview.isHidden = true
            cell.btnOptions.tag = indexPath.row
            cell.btnOptions.addTarget(self, action: #selector(optionsTapped(_:)), for: .touchUpInside)
        } else if selectedTabIndex == 1 {
            event = eventsConfirmed[indexPath.row]
            
            
            if event!.isExpire == 1 {
                cell.btnOptions.isHidden = true
                cell.btnReminder.isHidden = true
                cell.btnCancelTicket.isHidden = true
                cell.btnConfirmTicket.isHidden = true
                cell.viewRatings.isHidden = false
                cell.btnWriteReview.isHidden = true
                
                if event?.rate == 0 {
                    cell.viewRatings.tag = indexPath.row
                    cell.viewRatings.isUserInteractionEnabled = true
                    cell.viewRatings.delegate = self
                    cell.btnWriteReview.isHidden = true
                    cell.widthViewRatings.constant = 120.0
                }else if event?.review == "" {
                    cell.viewRatings.isUserInteractionEnabled = false
                    cell.viewRatings.rating = Double(event!.rate!)
                    cell.widthViewRatings.constant = 100.0
                    cell.btnWriteReview.isHidden = false
                    cell.btnWriteReview.isEnabled = true
                    cell.btnWriteReview.tag = indexPath.row
                    cell.btnWriteReview.addTarget(self, action: #selector(reviewTapped(_:)), for: .touchUpInside)
                }else {
                    cell.viewRatings.tag = indexPath.row
                    cell.viewRatings.isUserInteractionEnabled = false
                    cell.viewRatings.rating = event?.rate as! Double
                    cell.viewRatings.delegate = self
                    cell.btnWriteReview.isHidden = true
                    cell.widthViewRatings.constant = 120.0
                }
                
            }else {
                cell.widthBtnOptions.constant = 0
                cell.btnOptions.isHidden = true
                cell.btnReminder.isHidden = false
                cell.btnCancelTicket.isHidden = false
                cell.btnConfirmTicket.isHidden = true
                cell.viewRatings.isHidden = true
                cell.btnWriteReview.isHidden = true
                cell.btnCancelTicket.tag = indexPath.row
                cell.btnCancelTicket.addTarget(self, action: #selector(cancelTicketTapped(_:)), for: .touchUpInside)
                cell.btnReminder.tag = indexPath.row
                cell.btnReminder.addTarget(self, action: #selector(reminderTapped(_:)), for: .touchUpInside)
            }
            
        } else {
            event = eventsFavorite[indexPath.row]
            
            if event!.isExpire == 1 {
                cell.btnOptions.isHidden = true
                cell.btnReminder.isHidden = true
                cell.btnCancelTicket.isHidden = true
                cell.btnConfirmTicket.isHidden = true
                cell.viewRatings.isHidden = true
                cell.btnWriteReview.isHidden = true
            }else {
                cell.widthBtnOptions.constant = 0
                cell.btnOptions.isHidden = true
                cell.btnReminder.isHidden = true
                cell.btnConfirmTicket.isHidden = false
                cell.btnCancelTicket.isHidden = true
                cell.viewRatings.isHidden = true
                cell.btnWriteReview.isHidden = true
                cell.btnCancelTicket.tag = indexPath.row
                cell.btnCancelTicket.addTarget(self, action: #selector(cancelTicketTapped(_:)), for: .touchUpInside)
                cell.btnConfirmTicket.tag = indexPath.row
                cell.btnConfirmTicket.addTarget(self, action: #selector(confirmTicketTapped(_:)), for: .touchUpInside)
            }
                        
        }
        
        cell.ivEvent.setImage(imageUrl: event!.mediaImage!)
        cell.lblEventTitle.text = event!.title
        cell.lblEventDateTime.text = event!.startDate
        cell.lblEventDateTime.textColor = event!.isExpire == 1 ? Colors.red.returnColor() : Colors.themeGreen.returnColor()
        cell.lblEventLocation.text = event!.address

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedTabIndex == 0 {
            if indexPath.row == eventsCreated.count - 1 {
                if hasMoreCreate == 1 {
                    getEvents()
                }
            }
        } else if selectedTabIndex == 1 {
            if indexPath.row == eventsConfirmed.count - 1 {
                if hasMoreConfirmed == 1 {
                    getEvents()
                }
            }
        } else {
            if indexPath.row == eventsFavorite.count - 1 {
                if hasMoreFavorite == 1 {
                    getEvents()
                }
            }
        }
    }
    
    @objc func onTapPostEvent(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
        switch selectedTabIndex {
            case 0:
                vc.ontapUpdate = {
                    self.pageNoCreate = 1
                    self.hasMoreCreate = -1
                    self.eventsCreated.removeAll()
                    self.tvContent.reloadData()
                    self.dictParams.updateValue(self.pageNoCreate, forKey: "page")
                    self.dictParams.updateValue("Create", forKey: "type")
                    self.getEvents()
                }
                vc.eventId = eventsCreated[sender.tag].id
            case 1:
                vc.eventId = eventsConfirmed[sender.tag].id
            default:
                vc.eventId = eventsFavorite[sender.tag].id
        }
        
        self.view.ffTabVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func reviewTapped(_ sender: UIButton) {
        let event = eventsConfirmed[sender.tag]
        
        let giveRateVC = self.storyboard?.instantiateViewController(withIdentifier: "GiveRateReviewVC") as! GiveRateReviewVC
        giveRateVC.module = "Event"
        giveRateVC.moduleId = event.id
        giveRateVC.ratings = event.rate ?? 0.0
        giveRateVC.toUserId = event.userId
        giveRateVC.ontapUpdate = { review in
            self.eventsConfirmed[sender.tag].review = review
            self.tvContent.reloadData()
        }
        giveRateVC.modalPresentationStyle = .overCurrentContext
        giveRateVC.modalTransitionStyle = .crossDissolve
        self.view!.ffTabVC.present(giveRateVC, animated: true, completion: nil)
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        let event = eventsConfirmed[ratingView.tag]
        indexToUpdate = ratingView.tag
        dictParamsGiveRating = ["moduleId": event.id,
                                "module" : "Event",
                                "toUserId": event.userId,
                                "rate": rating,
                                "review": ""]
        giveRating()
    }
    
    @objc func optionsTapped(_ sender: UIButton) {
        
        fpcOptions = FloatingPanelController()
        fpcOptions?.delegate = self
        fpcOptions?.surfaceView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        fpcOptions?.surfaceView.cornerRadius = 20.0
        fpcOptions?.isRemovalInteractionEnabled = true
        
        if blurView == nil {
            blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
            blurEffect.setValue(2, forKeyPath: "blurRadius")
            blurView.effect = blurEffect
            blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            self.view.addSubview(blurView)
            blurView.isHidden = true
        }
        
        //Setup Post Details
        let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseEventOptionVC") as? ChooseEventOptionVC
//        chooseOptionVC?.module = "Post"
//        chooseOptionVC?.postEventDetails = postDetails
        chooseOptionVC?.removePanel = { selectedIndex in
            self.fpcOptions?.removePanelFromParent(animated: false)
            self.blurView.isHidden = true
            
            if selectedIndex == 0 {
                //Edit Event
                let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
                addEventVC.eventId = self.eventsCreated[sender.tag].id
                addEventVC.eventDetails = self.eventsCreated[sender.tag]
                addEventVC.isComeForUpdate = true
                addEventVC.ontapUpdate = {
                    self.pageNoCreate = 1
                    self.hasMoreCreate = -1
                    self.eventsCreated.removeAll()
                    self.tvContent.reloadData()
                    self.dictParams.updateValue(self.pageNoCreate, forKey: "page")
                    self.dictParams.updateValue("Create", forKey: "type")
                    self.getEvents()
                }
                self.navigationController?.pushViewController(addEventVC, animated: true)
            }else if selectedIndex == 1 {
                //Duplicate Event
                let addEventVC = self.storyboard?.instantiateViewController(withIdentifier: "AddEventVC") as! AddEventVC
                addEventVC.eventId = self.eventsCreated[sender.tag].id
                addEventVC.eventDetails = self.eventsCreated[sender.tag]
                addEventVC.isComeForDuplicate = true
                addEventVC.ontapUpdate = {
                    self.pageNoCreate = 1
                    self.hasMoreCreate = -1
                    self.eventsCreated.removeAll()
                    self.tvContent.reloadData()
                    self.dictParams.updateValue(self.pageNoCreate, forKey: "page")
                    self.dictParams.updateValue("Create", forKey: "type")
                    self.getEvents()
                }
                self.navigationController?.pushViewController(addEventVC, animated: true)
            }else {
                //Remove Event
                self.dictParam.removeAll()
                self.dictParam.updateValue(self.eventsCreated[sender.tag].id, forKey: "moduleId")
                self.dictParam.updateValue("Event", forKey: "module")
                self.indexToUpdate = sender.tag
                self.removeEvent()
            }
            
        }
//        postDetailsVC?.postDetails = postDetails
        fpcOptions?.set(contentViewController: chooseOptionVC)
//        fpc.track(scrollView: postDetailsVC?.svMain)
        fpcOptions?.addPanel(toParent: self, animated: true)
        blurView.isHidden = false

    }
    
    @objc func cancelTicketTapped(_ sender: UIButton) {
        
        if fpcConfirmEvent ==  nil {
            fpcConfirmEvent = FloatingPanelController()
            fpcConfirmEvent.delegate = self
            fpcConfirmEvent.surfaceView.backgroundColor = .clear
            fpcConfirmEvent.surfaceView.cornerRadius = 20.0
            fpcConfirmEvent.isRemovalInteractionEnabled = true
            
            if blurView == nil {
                blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
                blurEffect.setValue(2, forKeyPath: "blurRadius")
                blurView.effect = blurEffect
                blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                self.view.addSubview(blurView)
                blurView.isHidden = true
            }
        }
        
        screenSize = 203.0
        //Setup Post Details
        let selectTicketsVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectTicketsVC") as? SelectTicketsVC
        selectTicketsVC?.isComeForCancel = true
        selectTicketsVC?.eventDetails = eventsConfirmed[sender.tag]
        selectTicketsVC?.removePanel = { ticketsCount in
            self.eventsConfirmed[sender.tag].tickets = self.eventsConfirmed[sender.tag].tickets! - ticketsCount
            
            if self.eventsConfirmed[sender.tag].tickets! < 1 {
                self.eventsConfirmed.remove(at: sender.tag)
                self.tvContent.reloadData()
            }
            
            self.fpcConfirmEvent.removePanelFromParent(animated: false, completion: {
                let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupVC") as! SuccessPopupVC
                successPopup.titleString = "Your ticket has been successfully canceled."
                successPopup.tapDone = {
//                    self.navigationController?.popViewController(animated: true)
                }
                
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
    
    @objc func reminderTapped(_ sender: UIButton) {
        var event: PostEventDetail?
        if selectedTabIndex == 1 {
            event = eventsConfirmed[sender.tag]
        } else {
            event = eventsFavorite[sender.tag]
        }
        
        dictParam.removeAll()
        dictParam.updateValue(event!.id, forKey: "eventId")
        dictParam.updateValue(1, forKey: "isSetReminder")
        indexToUpdate = sender.tag
        setReminder()
    }
    
    @objc func confirmTicketTapped(_ sender: UIButton) {
        var event = eventsFavorite[sender.tag]
        
        if fpcConfirmEvent ==  nil {
            fpcConfirmEvent = FloatingPanelController()
            fpcConfirmEvent.delegate = self
            fpcConfirmEvent.surfaceView.backgroundColor = .clear
            fpcConfirmEvent.surfaceView.cornerRadius = 20.0
            fpcConfirmEvent.isRemovalInteractionEnabled = true
            
            if blurView == nil {
                blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
                blurEffect.setValue(2, forKeyPath: "blurRadius")
                blurView.effect = blurEffect
                blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                self.view.addSubview(blurView)
                blurView.isHidden = true
            }
        }
        
        screenSize = 203.0
        //Setup Post Details
        let selectTicketsVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectTicketsVC") as? SelectTicketsVC
        selectTicketsVC?.eventDetails = event
        selectTicketsVC?.removePanel = { ticketsCount in
            
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
    
}

extension EventsListVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions?.surfaceView.borderWidth = 0.0
        fpcOptions?.surfaceView.borderColor = nil
        if vc.contentViewController is SelectTicketsVC {
            return ConfirmEventLayout()
        } else {
            return ChooseEventOptionLayout()
        }
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

public class ChooseEventOptionLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .half
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.half]
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
            case .half: return 225.0
            default: return nil
        }
    }
}
