//
//  CustomVideoPlayer.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/11/24.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    // Observers
    private var playerObserver: Any?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerLayer()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Setup Methods
    private func setupPlayerLayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    // MARK: - Public Methods
    func loadVideo(with url: URL) {
        removeObservers()
        
        playerItem = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: playerItem)
        
        addObservers()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    // MARK: - Observers
    private func addObservers() {
        guard let player = player else { return }
        playerObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            print("Current Time: \(currentTime)")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoDidEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
    }
    
    private func removeObservers() {
        if let observer = playerObserver {
            player?.removeTimeObserver(observer)
            playerObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification Handlers
    @objc private func videoDidEnd() {
        print("Video ended")
        stop() // Reset to start
    }
}
