//
//  EventDetailsVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 02/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit

class DownloadEventTicketVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTicket: UIView!
    @IBOutlet weak var viewTicketMain: UIView!
    
    @IBOutlet weak var lblEventTitle: UILabel!
    @IBOutlet weak var lblEventMonth: UILabel!
    @IBOutlet weak var lblEventDate: UILabel!

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblEventDateTime: UILabel!
    @IBOutlet weak var lblFoodCategory: UILabel!
    @IBOutlet weak var lblTickets: UILabel!

    @IBOutlet weak var btnDownload: UIButton!
    
    var eventDetails: PostEventDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    func setupUI() {
        
        btnDownload.layer.borderColor = Colors.orange.returnColor().cgColor
        btnDownload.layer.borderWidth = 1.0
        btnDownload.layer.cornerRadius = btnDownload.frame.size.height / 2
        
        viewTicket.layer.cornerRadius = 16.0
        
        lblEventTitle.text = eventDetails?.title
        let date = eventDetails?.startDate!.split(separator: " ")
        
        lblEventMonth.text = String(date![1])
        lblEventDate.text = String(date![0])
        
        lblLocation.text = eventDetails?.address
        lblEventDateTime.text = "\(eventDetails?.startDate ?? "") - \(eventDetails?.endDate ?? "")"
        lblFoodCategory.text = eventDetails?.category
        
        lblTickets.text = "\(eventDetails?.tickets ?? 0)"
        
        if !Utilities.checkPhotoLibraryPermission() {
            self.checkForPhotos()
        }
    }
    
    func captureScreen() -> UIImage {
        
//            self.viewMapMultiplerConstraints.setMultiplier(multiplier: 0.3)
        btnDownload.isHidden = true
        UIGraphicsBeginImageContextWithOptions(self.viewTicketMain.bounds.size, false, 0)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.viewTicketMain.frame.width, height: self.viewTicketMain.frame.height), false, 0)
        self.viewTicketMain.drawHierarchy(in: viewTicketMain.bounds, afterScreenUpdates: true)
        let snapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
//            self.viewMapMultiplerConstraints.setMultiplier(multiplier: 0.7)
        btnDownload.isHidden = false
        
        return snapshot
    }
    
    @IBAction func onTapDownload(_ sender: UIButton) {
        
        if Utilities.checkPhotoLibraryPermission() {
            _ = self.captureScreen()
            
            let successPopup = self.storyboard?.instantiateViewController(withIdentifier: "SuccessPopupVC") as! SuccessPopupVC
            successPopup.titleString = "Your ticket has been successfully downloaded in your gallery."
            successPopup.tapDone = {
                self.navigationController?.popViewController(animated: true)
            }
            
            successPopup.modalPresentationStyle = .overCurrentContext
            successPopup.modalTransitionStyle = .crossDissolve
            
            self.present(successPopup, animated: true, completion: nil)
        }else {
            self.checkForPhotos()
        }
    }
    
    @IBAction func onTapDismiss(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
