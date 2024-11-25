//
//  CustomVideoPlayer.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/11/24.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class CustomVideoPlayer: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var isPipEnabled = false // Default PiP mode is off

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupPlayer(with url: URL, enablePiP: Bool = false) {
        // Set the PiP enable flag
        isPipEnabled = enablePiP

        // Initialize AVPlayer
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        // Setup Picture-in-Picture only if enabled
        if isPipEnabled, AVPictureInPictureController.isPictureInPictureSupported(), let playerLayer = playerLayer {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController?.delegate = self
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func togglePictureInPicture() {
        guard isPipEnabled, let pipController = pipController else {
            print("PiP is not enabled or supported")
            return
        }
        
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension CustomVideoPlayer: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP started")
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP stopped")
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Failed to start PiP: \(error.localizedDescription)")
    }
}
