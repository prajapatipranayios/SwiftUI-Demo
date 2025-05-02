//
//  CustomVideoPlayer.swift
//  SwiftDemo1
//
//  Created by Auxano on 25/11/24.
//

import Foundation
import UIKit
import AVFoundation

class CustomVideoPlayerView: UIView {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItemContext = 0

    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaultHeight()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDefaultHeight()
    }

    // MARK: - Default height setup
    private func setupDefaultHeight() {
        translatesAutoresizingMaskIntoConstraints = false
        if let screenHeight = UIApplication.shared.windows.first?.bounds.height {
            let defaultHeight = screenHeight * 0.25
            heightConstraint = heightAnchor.constraint(equalToConstant: defaultHeight)
            heightConstraint?.isActive = true
        }
    }

    // MARK: - Public
    func playVideo(with url: URL) {
        player?.pause()
        playerLayer?.removeFromSuperlayer()

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        item.asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            DispatchQueue.main.async {
                if let videoTrack = asset.tracks(withMediaType: .video).first {
                    let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
                    let width = abs(size.width)
                    let height = abs(size.height)
                    self.updateHeightBasedOnVideoSize(videoWidth: width, videoHeight: height)
                }
            }
        }

        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        layer.insertSublayer(playerLayer!, at: 0)

        player?.play()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    private func updateHeightBasedOnVideoSize(videoWidth: CGFloat, videoHeight: CGFloat) {
        guard videoWidth > 0 else { return }
        let viewWidth = self.bounds.width
        let newHeight = (videoHeight / videoWidth) * viewWidth
        heightConstraint?.constant = newHeight
        layoutIfNeeded()
    }
}









/*
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
/// */
