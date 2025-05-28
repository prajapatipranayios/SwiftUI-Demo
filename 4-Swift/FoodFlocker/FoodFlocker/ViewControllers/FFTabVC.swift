//
//  HomeVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import FloatingPanel
import CropViewController

class FFTabVC: UIViewController {

    //Outlets
    @IBOutlet weak var viewTabContainer: UIView!
    @IBOutlet weak var viewContent: UIView!

    @IBOutlet var viewTabs: [UIView]!
    @IBOutlet var ivTabs: [UIImageView]!
    @IBOutlet var lblTabs: [UILabel]!
    @IBOutlet var topTabs: [NSLayoutConstraint]!
    @IBOutlet var btnTabs: [UIButton]!

    var module = ""
    var moduleId = 0
    
    var selectedTabIndex: Int = 0
    
    var viewControllers: [UINavigationController]!
    var homeNavVC: UINavigationController?
    var exploreNavVC: UINavigationController?
    var cameraNavVC: UINavigationController?
    var requestsNavVC: UINavigationController?
    var profileNavVC: UINavigationController?
    
    var tabIconImgs = ["Home",
                    "Explore",
                    "camera",
                    "Request",
                    "Profile"]
    
    var fpcOptions: FloatingPanelController!
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    var blurView: UIVisualEffectView!
    
    let imagePicker =  UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        loadTabsOfHomeScreen()
        
        imagePicker.mediaTypes = ["public.image", "public.movie"]

        //Set Default Value
        if (UserDefaults.standard.value(forKey: UserDefaultType.notification) == nil) {
            UserDefaults.standard.set(true, forKey: UserDefaultType.notification)
        }
        
        if APIManager.sharedManager.user?.isNewUser == 1 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "GuidelineVC") as! GuidelineVC
            objVC.modalPresentationStyle = .fullScreen
            self.present(objVC, animated: true, completion: nil)
        }
        
        if moduleId != 0 {
            
            if module == "OtherUserDetail" {
                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                profileVC.userId = moduleId
                self.navigationController?.pushViewController(profileVC, animated: false)
            }
            
            if module == "Post" {
                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
                profileVC.postId = moduleId
                self.navigationController?.pushViewController(profileVC, animated: false)
            }
            
            if module == "Event" {
                let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewEventVC") as! ViewEventVC
                profileVC.eventId = moduleId
                self.navigationController?.pushViewController(profileVC, animated: false)
            }
            
        }
    }
    
    // MARK: - UI Methods
    func setupUI() {
        self.viewTabContainer.addShadow(offset: CGSize(width: 0, height: -2.0), color: Colors.gray.returnColor(), radius: 3.0, opacity: 0.25)
        
        for i in 0..<viewTabs.count {
            viewTabs[i].layer.cornerRadius = 10.0
            viewTabs[i].clipsToBounds = true
//            lblTabs[i].textColor = Colors.gray.returnColor()
        }
//        viewTabs[0].backgroundColor = Colors.themeGreen.returnColor()
//        lblTabs[0].textColor = UIColor.white
//        topTabs[0].constant = -8
    }
    
    func setupTabbar() {
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        homeNavVC = UINavigationController(rootViewController: homeVC)
        homeNavVC?.isNavigationBarHidden = true
        
        let exploreVC = self.storyboard?.instantiateViewController(withIdentifier: "ExploreVC") as! ExploreVC
        exploreNavVC = UINavigationController(rootViewController: exploreVC)
        exploreNavVC?.isNavigationBarHidden = true
        
        let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        cameraNavVC = UINavigationController(rootViewController: cameraVC)
        cameraNavVC?.isNavigationBarHidden = true
        
        let requestsVC = self.storyboard?.instantiateViewController(withIdentifier: "RequestsVC") as! RequestsVC
        requestsNavVC = UINavigationController(rootViewController: requestsVC)
        requestsNavVC?.isNavigationBarHidden = true
        
        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        profileNavVC = UINavigationController(rootViewController: profileVC)
        profileNavVC?.isNavigationBarHidden = true
    }
    
    func loadTabsOfHomeScreen() {
        setupTabbar()
        viewControllers = [homeNavVC!, exploreNavVC!, cameraNavVC!, requestsNavVC!, profileNavVC!]
        onTabChange(btnTabs[selectedTabIndex])
    }
    
    func updateTabSelection() {
        for i in 0..<viewTabs.count {
            lblTabs[i].textColor = i == selectedTabIndex ? UIColor.white : Colors.gray.returnColor()
            viewTabs[i].backgroundColor = i == selectedTabIndex ? Colors.themeGreen.returnColor() : UIColor.clear
            topTabs[i].constant = i == selectedTabIndex ? -8 : 0
            ivTabs[i].image = UIImage(named: i == selectedTabIndex ? tabIconImgs[i] + "Active" : tabIconImgs[i])
        }
    }
    
    // MARK: - Button Click Events
    
    @IBAction func onTabChange(_ sender: UIButton) {
        // Update ContentView
        if sender.tag == 2 {
            if fpcOptions == nil {
                fpcOptions = FloatingPanelController()
                fpcOptions.delegate = self
                fpcOptions.surfaceView.cornerRadius = 20.0
                fpcOptions.isRemovalInteractionEnabled = true
                imagePicker.delegate = self
                
                blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
                blurEffect.setValue(2, forKeyPath: "blurRadius")
                blurView.effect = blurEffect
                blurView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                self.view.addSubview(blurView)
                blurView.isHidden = true
            }
            
            let chooseOptionVC = self.storyboard?.instantiateViewController(withIdentifier: "ChooseOptionVC") as? ChooseOptionVC
            chooseOptionVC?.openMediaPicker = { option in
                self.fpcOptions.removePanelFromParent(animated: false)
                self.blurView.isHidden = true

                if option == 0 {
                    //"Take Photo/Video"
                    self.openCamera()
                } else {
                    //"Choose Photo/Video"
                    self.openGallary()
                }
            }
            
            chooseOptionVC?.chooseMedia = true
            fpcOptions.set(contentViewController: chooseOptionVC)
            fpcOptions.addPanel(toParent: self, animated: true)
            blurView.isHidden = false
        } else {
            selectedTabIndex = sender.tag
            updateTabSelection()
            
            let vc: UINavigationController = viewControllers[selectedTabIndex]
            vc.popToRootViewController(animated: false)
            vc.view.frame = viewContent.bounds
            viewContent.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
        //
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }else {
            openGallary()
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

}

extension FFTabVC: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        fpcOptions.surfaceView.borderWidth = 0.0
        fpcOptions.surfaceView.borderColor = nil
        return ChooseOptionLayout()
    }
    
    func floatingPanelDidEndRemove(_ vc: FloatingPanelController) {
        blurView.isHidden = true
    }
}

extension FFTabVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            let publishImgVC = self.storyboard?.instantiateViewController(withIdentifier: "PublishImageVC") as! PublishImageVC
            publishImgVC.modalPresentationStyle = .fullScreen
            publishImgVC.image = image
            self.present(publishImgVC, animated: true, completion: nil)
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            dismiss(animated: true) {
                let cropViewController = CropViewController(image: image)
                cropViewController.toolbarPosition = .top
                cropViewController.resetButtonHidden = true
                cropViewController.rotateButtonsHidden = true
                cropViewController.aspectRatioPickerButtonHidden = true
                cropViewController.aspectRatioPreset = .presetSquare
                cropViewController.aspectRatioLockEnabled = true

                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            }
        } else if let videoUrl = info[.mediaURL] as? URL {
            dismiss(animated: true) {
                DispatchQueue.main.async {
                    let videoCropVc = self.storyboard?.instantiateViewController(withIdentifier: "VideoCropVC") as! VideoCropVC
                    videoCropVc.modalPresentationStyle = .fullScreen
                    videoCropVc.selectedUrl = videoUrl
                    videoCropVc.isUploadMedia = true
                    self.present(videoCropVc, animated: true, completion: nil)
                }
            }
        } else {
            dismiss(animated:true, completion: nil)
            return
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
