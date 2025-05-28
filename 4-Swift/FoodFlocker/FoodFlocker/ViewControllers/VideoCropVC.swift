//
//  VideoCropVC.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 28/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import UIKit
import ABVideoRangeSlider
import AVKit
import AVFoundation
import Photos

class VideoCropVC: UIViewController, ABVideoRangeSliderDelegate {

    //Outlets
    @IBOutlet weak var viewTopContainer: UIView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet var videoRangeSlider: ABVideoRangeSlider!

    var selectedUrl: URL?
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var selectedStart = 0.0
    var selectedEnd = 0.0
    var progressTime = 0.0
    
    var endTime = 0.0

    var shouldUpdateProgressIndicator = true
    var isSeeking = false

    var timeObserver: AnyObject!
    
    var videoPathToUpload: URL?
    var dictParamsVideoUpload = Dictionary<String, Any>()

    var dictUploadedVideo = Dictionary<String, String>()
    
    var updateVideoParams: ((Dictionary<String, String>)->Void)?
    
    var isUploadMedia = false

    var module = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        self.setSelectedVideoInPlayer(path: self.selectedUrl!)
//        videoRangeSlider.remo
        
    }
    
    func setupUI() {
        self.btnPlay.tag = 0
        self.btnPlay.setTitle("Play", for: .normal)
        self.btnPlay.layer.cornerRadius = self.btnPlay.frame.size.height / 2
        self.btnPublish.layer.cornerRadius = self.btnPublish.frame.size.height / 2

        self.viewTopContainer.roundCornersWithShadow(corners: [.bottomLeft,.bottomRight], radius: 20.0, bgColor: UIColor.white)
        
        videoRangeSlider.setStartIndicatorImage(image: UIImage(named: "LeftCrop")!)
        videoRangeSlider.setEndIndicatorImage(image: UIImage(named: "RightCrop")!)
        
        videoRangeSlider.startTimeView.backgroundColor = Colors.themeGreen.returnColor()
        videoRangeSlider.endTimeView.backgroundColor = Colors.themeGreen.returnColor()
        
        videoRangeSlider.setBorderImage(image: UIImage(named: "borderHorizontal")!)
    }

    // MARK: - Button Click Events
    
    @IBAction func onTapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapPublish(_ sender: UIButton) {
        //onTapCropVideo
//        let tempStart = String(format:"%.0f", selectedStart)
//        let tempEnd = String(format:"%.0f", selectedEnd)
        avPlayer.pause()
        btnPlay.tag = 0
        btnPlay.setTitle("Play", for: .normal)
        if selectedUrl != nil {
            self.cropVideo(sourceURL: selectedUrl!, start: selectedStart, end: selectedEnd)
        }
        
//        if (Int(tempEnd)! - Int(tempStart)!) == 180 || (Int(tempEnd)! - Int(tempStart)!) == 300 || (Int(tempEnd)! - Int(tempStart)!) == 480 {
//            avPlayer.pause()
//            btnPlay.isEnabled = true
//            if selectedUrl != nil {
//                self.cropVideo(sourceURL: selectedUrl!, start: selectedStart, end: selectedEnd)
//            }
//        } else {
//            let alertController = UIAlertController(title: "You must select video for 3,5 or 8 minute", message: nil, preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .default) { (complete) in
//            }
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion: nil)
//        }
    }
    
    @IBAction func onTapPlay(_ sender: UIButton) {
        if sender.tag == 0 {
            btnPlay.tag = 1
            avPlayer.play()
            btnPlay.setTitle("Pause", for: .normal)
        }else {
            btnPlay.tag = 0
            avPlayer.pause()
            btnPlay.setTitle("Play", for: .normal)
        }
        
    }
    
    // MARK: - Webservices
    
    func uploadVideo() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.uploadVideo()
                }
            }
            return
        }
        
        self.dictParamsVideoUpload.updateValue("Video", forKey: "mediaType")
        self.dictParamsVideoUpload.updateValue(module, forKey: "module")
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.UPLOAD_MEDIA, fileName: "media", image: nil, movieDataURL: videoPathToUpload, params: dictParamsVideoUpload) { (status, response, message) in
            self.hideLoading()
            if status {
                if response != nil {
                    self.dictUploadedVideo = ["mediaName": response!["fileName"] as! String, "mediaType": "Video"]
//                    self.uploadedMedias.append(dict)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            if self.updateVideoParams != nil {
                                self.updateVideoParams!(self.dictUploadedVideo)
                            }
                        }
                    }
                    
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
    
    func addMediaPost() {
        if !appDelegate.checkInternetConnection() {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addMediaPost()
                }
            }
            return
        }
        
        let params = ["mediaType": "Video"]
        
        showLoading()
        APIManager.sharedManager.uploadImageOrVideo(url: APIManager.sharedManager.ADD_MEDIA_POST, fileName: "media", image: nil, movieDataURL: videoPathToUpload, params: params) { (status, response, message) in
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
        
    func setSelectedVideoInPlayer(path: URL) {
        DispatchQueue.main.async {
            let playerItem = AVPlayerItem(url: path)
            self.avPlayer.replaceCurrentItem(with: playerItem)
            self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer)
            self.avPlayerLayer.frame = self.videoContainer.bounds
            
            self.videoContainer.layer.insertSublayer(self.avPlayerLayer, at: 0)
            self.videoContainer.layer.masksToBounds = true
            
            self.videoRangeSlider.setVideoURL(videoURL: path)
            self.videoRangeSlider.delegate = self
            self.videoRangeSlider.minSpace = 0.0
            self.videoRangeSlider.maxSpace = Float(CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)) < 10.0 ? Float(CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!)) : 10.0
            
            self.endTime = CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!) < 10.0 ? CMTimeGetSeconds((self.avPlayer.currentItem?.duration)!) : 10.0
            
            self.selectedStart = 0.0
            
            self.selectedEnd = (self.avPlayer.currentItem?.asset.duration.seconds ?? 0.0) < Double(10.0) ? (self.avPlayer.currentItem?.asset.duration.seconds ?? 0.0) : Double(10.0)
            
            self.videoRangeSlider.setEndPosition(seconds: Float((self.avPlayer.currentItem?.asset.duration.seconds ?? 0.0) < Double(10.0) ? (self.avPlayer.currentItem?.asset.duration.seconds ?? 0.0) : Double(10.0)))
            
            let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, preferredTimescale: 100)
            
            self.timeObserver = self.avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                            queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                                self.observeTime(elapsedTime: elapsedTime) } as AnyObject?
        }
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
        if (avPlayer.currentTime().seconds > self.selectedEnd){
            avPlayer.pause()
            btnPlay.tag = 0
            btnPlay.setTitle("Play", for: .normal)
//            btnPause.isEnabled = false
        }
        if self.shouldUpdateProgressIndicator{
            videoRangeSlider.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    func cropVideo(sourceURL: URL, start: Double, end: Double, completion: ((_ outputUrl: URL) -> Void)? = nil)
    {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent)")//.mp4
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let timeRange = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 1000),
                                    end: CMTime(seconds: end, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                self.videoPathToUpload = outputURL
                DispatchQueue.main.async {
//                    self.setSelectedVideoInPlayer(path: outputURL)
                    if self.isUploadMedia {
                        self.addMediaPost()
                    } else {
                        self.uploadVideo()
                    }
                }
                //                PHPhotoLibrary.shared().performChanges({
                //                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                //                }) { saved, error in
                //                    if saved {
                //                        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                //                        let defaultAction = UIAlertAction(title: "OK", style: .default) { (complete) in
                //                        }
                //                        alertController.addAction(defaultAction)
                //                        self.present(alertController, animated: true, completion: nil)
                //                    }
                //                }
                
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
    // MARK: - ABVideoRangeSliderDelegate

    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {

//        lblStart.text = startTime.formattedTime
//        lblEnd.text = endTime.formattedTime
        
        selectedStart = startTime
        selectedEnd = endTime
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
//        self.shouldUpdateProgressIndicator = false
        
        // Pause the player
        avPlayer.pause()
        btnPlay.tag = 0
        btnPlay.setTitle("Play", for: .normal)
        
        if self.progressTime != position {
            self.progressTime = position
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.progressTime, preferredTimescale: timescale!)
            if !self.isSeeking {
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero){_ in
                    self.isSeeking = false
                }
            }
        }
    }

}
