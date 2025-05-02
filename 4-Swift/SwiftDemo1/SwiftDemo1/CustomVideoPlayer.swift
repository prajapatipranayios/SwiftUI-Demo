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
    private var timeObserverToken: Any?

    // UI Elements
    private let playPauseButton = UIButton(type: .custom)
    private let bottomControlsView = UIView()
    private let slider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private var controlsVisible = true
    private var controlsHideTimer: Timer?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }

    // MARK: - Public
    func playVideo(with url: URL) {
        player?.pause()
        playerLayer?.removeFromSuperlayer()

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        layer.insertSublayer(playerLayer!, at: 0)

        addPeriodicTimeObserver()
        player?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        scheduleAutoHide()
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds

        // Layout play/pause button centered in the view
        playPauseButton.frame.size = CGSize(width: 60, height: 60)
        playPauseButton.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        // Layout bottom control view
        bottomControlsView.frame = CGRect(x: 0, y: bounds.height - 50, width: bounds.width, height: 50)
        layoutBottomControls()

        // Ensure controls are above player layer
        bringSubviewToFront(playPauseButton)
        bringSubviewToFront(bottomControlsView)
    }

    private func layoutBottomControls() {
        let padding: CGFloat = 8
        let labelWidth: CGFloat = 50

        currentTimeLabel.frame = CGRect(x: padding, y: 0, width: labelWidth, height: 50)
        durationLabel.frame = CGRect(x: bottomControlsView.frame.width - labelWidth - padding, y: 0, width: labelWidth, height: 50)

        slider.frame = CGRect(
            x: currentTimeLabel.frame.maxX + padding,
            y: 0,
            width: durationLabel.frame.minX - currentTimeLabel.frame.maxX - 2 * padding,
            height: 50
        )
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Tap to toggle controls
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tap)

        // Play/Pause Button
        playPauseButton.tintColor = .white
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        playPauseButton.layer.cornerRadius = 30
        playPauseButton.clipsToBounds = true
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        playPauseButton.isUserInteractionEnabled = true // Make sure it's clickable!
        addSubview(playPauseButton)

        // Bottom controls container
        bottomControlsView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        addSubview(bottomControlsView)

        // Slider
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(didSlideSlider), for: .valueChanged)
        bottomControlsView.addSubview(slider)

        // Labels
        [currentTimeLabel, durationLabel].forEach {
            $0.textColor = .white
            $0.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            $0.textAlignment = .center
            bottomControlsView.addSubview($0)
        }

        currentTimeLabel.text = "00:00"
        durationLabel.text = "--:--"
    }

    // MARK: - Player Controls
    @objc private func didTapPlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        scheduleAutoHide()
    }

    @objc private func didSlideSlider() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: 600)
        player?.seek(to: seekTime)
        scheduleAutoHide()
    }

    @objc private func didTapView() {
        toggleControls()
    }

    private func toggleControls() {
        controlsVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.playPauseButton.alpha = self.controlsVisible ? 1 : 0
            self.bottomControlsView.alpha = self.controlsVisible ? 1 : 0
        }

        if controlsVisible {
            scheduleAutoHide()
        } else {
            controlsHideTimer?.invalidate()
        }
    }

    private func scheduleAutoHide() {
        controlsHideTimer?.invalidate()
        controlsHideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.hideControls()
        }
    }

    private func hideControls() {
        guard controlsVisible else { return }
        toggleControls()
    }

    // MARK: - Time Observer
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] currentTime in
            guard let self = self, let duration = player.currentItem?.duration else { return }

            let currentSeconds = CMTimeGetSeconds(currentTime)
            let totalSeconds = CMTimeGetSeconds(duration)

            if totalSeconds.isFinite {
                self.slider.value = Float(currentSeconds / totalSeconds)
                self.currentTimeLabel.text = self.formatTime(currentSeconds)
                self.durationLabel.text = self.formatTime(totalSeconds)
            }
        }
    }

    private func formatTime(_ seconds: Float64) -> String {
        guard seconds.isFinite else { return "--:--" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
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
