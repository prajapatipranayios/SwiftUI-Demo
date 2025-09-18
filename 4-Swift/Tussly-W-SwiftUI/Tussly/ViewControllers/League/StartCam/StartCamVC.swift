//
//  StartCamVC.swift
//  - Designed Camera screen for League Module

//  Tussly
//
//  Created by Jaimesh Patel on 14/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit
import AVFoundation
import CropViewController


@available(iOS 10.0, *)
class StartCamVC: UIViewController, AVCapturePhotoCaptureDelegate {

    // MARK: - Controls
    @IBOutlet weak var photoPreviewImageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnFlash: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgSquar: UIImageView!
    @IBOutlet weak var viewCapturePart: UIView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var btnRetake: UIButton!
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var imgCroped: UIImageView!
    
    // MARK: - Variables
    private let indicator = MaterialActivityIndicatorView()
    var score = 0
    var teamId = -1
    var matchId = -1
    var roundId = -1
    var timer = Timer()
    var isStop = false
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var dismiss: (()->Void)?
    var passImage: ((UIImage)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnFlash.isHidden = true
        self.btnCapture.isHidden = true
        self.imgSquar.isHidden = true
        self.viewCapturePart.isHidden = true
        self.imgCroped.isHidden = true
        self.btnRetake.isHidden = true
        self.btnUpload.isHidden = true
        self.btnClose.isUserInteractionEnabled = true
        
        self.btnUpload.layer.cornerRadius = self.btnUpload.frame.height/2.0
        
        appDelegate.myOrientation = .landscapeRight
        
        viewLoader.layer.cornerRadius = 15.0
        setupActivityIndicatorView()
        viewLoader.isHidden = true
        
        
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch (status)
        {
            case .authorized:
                DispatchQueue.main.async {
                    self.setUi()
                }
            case .notDetermined:
                DispatchQueue.main.async {
                    self.setUi()
                }
            case .denied:
                self.camDenied()
            case .restricted:
                self.camDenied()
        @unknown default:
            DispatchQueue.main.async {
                self.setUi()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //indicator.startAnimating()
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.setNewCamera()
            self.videoPreviewLayer?.frame = self.previewView.bounds
        }
    }
    
    // By Pranay
    override func viewWillDisappear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    //.
    
    // MARK: - Button Click Events
    @IBAction func onTapUpload(_ sender: UIButton) {
        //uploadOCRImage(image: self.imgCroped.image!)
        self.dismiss(animated: true, completion: {
            if self.passImage != nil {
                self.passImage!(self.imgCroped.image!)
            }
        })
        
//        appDelegate.myOrientation = .portrait
//        self.dismiss(animated: true, completion: nil)
//        DispatchQueue.main.async {
//            if self.dismiss != nil {
//                self.dismiss!()
//            }
//        }
    }
    
    @IBAction func onTapCapture(_ sender: UIButton) {
    
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        stillImageOutput!.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func onTapRetake(_ sender: UIButton) {
        setNewCamera()
    }
    
    @IBAction func onTapClose(_ sender: UIButton) {
        appDelegate.myOrientation = .portrait
        self.dismiss(animated: true, completion: {
            if self.dismiss != nil {
                self.dismiss!()
            }
        })
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if device.torchMode == .off {
                    device.torchMode = .on
                    btnFlash.setBackgroundImage(#imageLiteral(resourceName: "Flash"), for: .normal)
                } else {
                    device.torchMode = .off
                    btnFlash.setBackgroundImage(#imageLiteral(resourceName: "Flash_off"), for: .normal)
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    // MARK: - UI Methods
    func captureScreen() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.viewCapturePart.bounds.size, false, 0)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.viewCapturePart.frame.width, height: self.viewCapturePart.frame.height), false, 0)
        self.viewCapturePart.drawHierarchy(in: viewCapturePart.bounds, afterScreenUpdates: true)
        let snapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
//        UIImageWriteToSavedPhotosAlbum(snapshot, nil, nil, nil)
        return snapshot
    }
    
    func setNewCamera() {
        self.lblTitle.text = "Align the overlay and capture the scoreboard"
        self.btnFlash.isHidden = false
        self.btnCapture.isHidden = false
        self.imgSquar.isHidden = false
        
        self.viewCapturePart.isHidden = true
        self.imgCroped.isHidden = true
        self.btnRetake.isHidden = true
//        self.photoPreviewImageView.isHidden = true
        self.btnUpload.isHidden = true
    }
    
    func compressImage (_ image: UIImage) -> UIImage {
        let actualHeight:CGFloat = image.size.height
        let actualWidth:CGFloat = image.size.width
        let imgRatio:CGFloat = actualWidth/actualHeight
        let maxWidth:CGFloat = 1024.0
        let resizedHeight:CGFloat = maxWidth/imgRatio
        let compressionQuality:CGFloat = 0.7

        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData:Data = img.jpegData(compressionQuality: compressionQuality)!
        UIGraphicsEndImageContext()
        return UIImage(data: imageData)!
    }

    @objc func callTimer() {
        if isStop == false {
            self.getOCRResultStatus()
        } else {
            timer.invalidate()
        }
    }
    
    func setUi() {
        
        /*session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSession.Preset.photo
        stillImageOutput = AVCapturePhotoOutput()

        let device = AVCaptureDevice.default(for: AVMediaType.video)

        if let input = try? AVCaptureDeviceInput(device: device!) {
            if session!.canAddInput(input) {
                session!.addInput(input)
                if session!.canAddOutput(stillImageOutput!) {
                    session!.addOutput(stillImageOutput!)
                    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                    videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                    previewView.layer.addSublayer(videoPreviewLayer!)
                    session!.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }   //  */
         
        session = AVCaptureSession()
        session!.sessionPreset = .photo
        stillImageOutput = AVCapturePhotoOutput()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No camera device found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session!.canAddInput(input) {
                session!.addInput(input)
            }
            else {
                print("Unable to add input to session")
                return
            }
            
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
            videoPreviewLayer!.videoGravity = .resizeAspectFill
            videoPreviewLayer!.connection?.videoOrientation = .landscapeRight
            videoPreviewLayer!.frame = previewView.bounds // Set frame here
            
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            // Start session on a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.session?.startRunning()
            }
        }
        catch {
            print("Error setting up camera input: \(error)")
        }
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,  didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,  previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings:  AVCaptureResolvedPhotoSettings, bracketSettings:   AVCaptureBracketedStillImageSettings?, error: Error?) {

        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }

        if  let sampleBuffer = photoSampleBuffer,

            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.up)
                        
            self.lblTitle.text = "Your photo will be automatically submitted to the Administator"
            
            self.btnFlash.isHidden = true
            self.btnCapture.isHidden = true
            self.imgSquar.isHidden = true
            self.viewCapturePart.isHidden = false
            self.imgCroped.isHidden = false
            self.btnRetake.isHidden = false
            self.btnUpload.isHidden = false
            
            self.photoPreviewImageView.image = image
            let captureImage: UIImage = self.captureScreen()
            self.imgCroped.image = captureImage
            self.viewCapturePart.isHidden = true
            
        } else {
            print("some error here")
        }
    }
    
    func camDenied() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: Messages.accessCameraTitle, message: Messages.accessCameraMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: Messages.dontAllow, style: .default, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            let setting = UIAlertAction(title: Messages.allow, style: .default) { (action) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                    })
                }
            }
            alert.addAction(okAction)
            alert.addAction(setting)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}


// MARK: Webservices

@available(iOS 10.0, *)
extension StartCamVC {
    
    func uploadOCRImage(image:UIImage) {
        viewLoader.isHidden = false
        indicator.startAnimating()
        self.btnClose.isUserInteractionEnabled = false

        APIManager.sharedManager.uploadOCRImage(url: APIManager.sharedManager.DISPUTE_ROUND, fileName: "scoreImage", image: image,score: score,teamId: teamId,matchId: matchId,roundId: roundId) { (success, response, message) in
            self.hideLoading()
            if success {
                DispatchQueue.main.async {
                    if response!["status"] as! String == "success" {
                        self.viewLoader.isHidden = true
                        self.btnClose.isUserInteractionEnabled = true

                        self.indicator.stopAnimating()
                        appDelegate.myOrientation = .portrait
                        self.dismiss(animated: true, completion: {
                            if self.dismiss != nil {
                                self.dismiss!()
                            }
                        })
                    } else if response!["status"] as! String == "failed" {
                        self.viewLoader.isHidden = true
                        self.btnClose.isUserInteractionEnabled = true

                        self.indicator.stopAnimating()
                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "ErrorUploadStatVC") as! ErrorUploadStatVC
                        dialog.modalPresentationStyle = .overCurrentContext
                        dialog.modalTransitionStyle = .crossDissolve
                        dialog.tapOK = {
                            //Capture
                            self.setNewCamera()
                        }
                        self.present(dialog, animated: true, completion: nil)
                    } else if response!["status"] as! String == "dispute" {
                        self.viewLoader.isHidden = true
                        self.btnClose.isUserInteractionEnabled = true
                        self.indicator.stopAnimating()
                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "DisputePopupVC") as! DisputePopupVC
                        dialog.modalPresentationStyle = .overCurrentContext
                        dialog.modalTransitionStyle = .crossDissolve
                        dialog.tapOK = {
                            appDelegate.myOrientation = .portrait
                            self.dismiss(animated: true, completion: {
                                if self.dismiss != nil {
                                    self.dismiss!()
                                }
                            })
                        }
                        
                        self.present(dialog, animated: true, completion: nil)
                    }
                    else if response!["status"] as! String == "wait" {
                        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.callTimer), userInfo: nil, repeats: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.btnClose.isUserInteractionEnabled = true
                    self.viewLoader.isHidden = true
                    self.indicator.stopAnimating()
                    Utilities.showPopup(title: message ?? "", type: .error)
                    appDelegate.myOrientation = .portrait
                    self.dismiss(animated: true, completion: {
                        if self.dismiss != nil {
                            self.dismiss!()
                        }
                    })
                }
            }
        }
    }
    
    func getOCRResultStatus() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.getOCRResultStatus()
                }
            }
            return
        }
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.GET_OCR_RESULT_STATUS, parameters: ["roundId":roundId]) { (response: ApiResponse?, error) in
            if response?.status == 1 {
                DispatchQueue.main.async {
                    if response?.result?.status == "success" {
                        self.btnClose.isUserInteractionEnabled = true

                        self.timer.invalidate()
                        self.isStop = true
                        appDelegate.myOrientation = .portrait
                        self.dismiss(animated: true, completion: {
                            if self.dismiss != nil {
                                self.dismiss!()
                            }
                        })
                    } else if response?.result?.status == "dispute" {
                        self.timer.invalidate()
                        self.btnClose.isUserInteractionEnabled = true

                        self.isStop = true
                        let dialog = self.storyboard?.instantiateViewController(withIdentifier: "DisputePopupVC") as! DisputePopupVC
                        dialog.modalPresentationStyle = .overCurrentContext
                        dialog.modalTransitionStyle = .crossDissolve
                        dialog.tapOK = {
                            appDelegate.myOrientation = .portrait
                            self.dismiss(animated: true, completion: {
                                if self.dismiss != nil {
                                    self.dismiss!()
                                }
                            })
                        }
                        
                        self.present(dialog, animated: true, completion: nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.btnClose.isUserInteractionEnabled = true

                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    appDelegate.myOrientation = .portrait
                    self.dismiss(animated: true, completion: {
                        if self.dismiss != nil {
                            self.dismiss!()
                        }
                    })
                }
            }
        }
    }
    
}


@available(iOS 10.0, *)
extension StartCamVC {
    private func setupActivityIndicatorView() {
        viewLoader.addSubview(indicator)
        setupActivityIndicatorViewConstraints()
    }

    private func setupActivityIndicatorViewConstraints() {
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
