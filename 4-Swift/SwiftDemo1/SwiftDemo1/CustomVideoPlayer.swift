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
    private var playerItem: AVPlayerItem?
    
    private let playPauseButton = UIButton(type: .custom)
    private let slider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let controlsContainerView = UIView()
    private let bottomControlsView = UIView()
    private let muteButton = UIButton(type: .custom)
    private let fullscreenButton = UIButton(type: .custom)
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private var isPlaying = false
    private var isMuted = false
    private var isFullscreen = false
    private var timeObserver: Any?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    deinit {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        playerItem?.removeObserver(self, forKeyPath: "status")
    }

    func playVideo(with url: URL) {
        activityIndicator.startAnimating()

        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        item.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)

        playerItem = item
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect

        if let layer = playerLayer {
            self.layer.insertSublayer(layer, at: 0)
        }

        setupTimeObserver()
        updatePlayPauseButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        controlsContainerView.frame = bounds
        layoutBottomControls()
        activityIndicator.center = center
    }

    private func setupUI() {
        backgroundColor = .black

        // Container View
        addSubview(controlsContainerView)
        controlsContainerView.backgroundColor = UIColor(white: 0, alpha: 0.4)

        // Activity Indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        addSubview(activityIndicator)

        // Play/Pause Button
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        controlsContainerView.addSubview(playPauseButton)

        // Bottom Controls
        bottomControlsView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        controlsContainerView.addSubview(bottomControlsView)

        // Time Labels
        currentTimeLabel.font = .systemFont(ofSize: 12)
        currentTimeLabel.textColor = .white
        currentTimeLabel.text = "00:00"
        bottomControlsView.addSubview(currentTimeLabel)

        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = .white
        durationLabel.text = "--:--"
        bottomControlsView.addSubview(durationLabel)

        // Slider
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        bottomControlsView.addSubview(slider)

        // Mute Button
        muteButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        muteButton.tintColor = .white
        muteButton.addTarget(self, action: #selector(didTapMute), for: .touchUpInside)
        bottomControlsView.addSubview(muteButton)

        // Fullscreen Button
        fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right"), for: .normal)
        fullscreenButton.tintColor = .white
        fullscreenButton.addTarget(self, action: #selector(didTapFullscreen), for: .touchUpInside)
        bottomControlsView.addSubview(fullscreenButton)
    }

    private func layoutBottomControls() {
        playPauseButton.frame = CGRect(x: (bounds.width - 50) / 2, y: (bounds.height - 50) / 2, width: 50, height: 50)

        let safeBottom: CGFloat = safeAreaInsets.bottom
        let padding: CGFloat = 8
        let buttonSize: CGFloat = 30
        let labelWidth: CGFloat = 40

        bottomControlsView.frame = CGRect(x: 0, y: bounds.height - 50 - safeBottom, width: bounds.width, height: 50 + safeBottom)

        muteButton.frame = CGRect(x: padding, y: 10, width: buttonSize, height: buttonSize)
        fullscreenButton.frame = CGRect(x: bottomControlsView.frame.width - buttonSize - padding, y: 10, width: buttonSize, height: buttonSize)

        currentTimeLabel.frame = CGRect(x: muteButton.frame.maxX + padding, y: 15, width: labelWidth, height: 20)
        durationLabel.frame = CGRect(x: fullscreenButton.frame.minX - labelWidth - padding, y: 15, width: labelWidth, height: 20)

        slider.frame = CGRect(
            x: currentTimeLabel.frame.maxX + padding,
            y: 15,
            width: durationLabel.frame.minX - currentTimeLabel.frame.maxX - 2 * padding,
            height: 20
        )
    }

    @objc private func didTapPlayPause() {
        guard let player = player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
        updatePlayPauseButton()
    }

    private func updatePlayPauseButton() {
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func setupTimeObserver() {
        guard let player = player else { return }

        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 2), queue: .main) { [weak self] time in
            guard let self = self,
                  let duration = self.player?.currentItem?.duration else { return }
            let currentSeconds = CMTimeGetSeconds(time)
            let totalSeconds = CMTimeGetSeconds(duration)
            self.slider.value = Float(currentSeconds / totalSeconds)
            self.currentTimeLabel.text = self.formatTime(seconds: currentSeconds)
            self.durationLabel.text = self.formatTime(seconds: totalSeconds)
        }
    }

    @objc private func sliderValueChanged() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(slider.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime)
    }

    private func formatTime(seconds: Float64) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    @objc private func didTapMute() {
        isMuted.toggle()
        player?.isMuted = isMuted
        let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
        muteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func didTapFullscreen() {
        guard let parentVC = findParentViewController() else { return }

        if isFullscreen {
            parentVC.dismiss(animated: true, completion: nil)
            isFullscreen = false
        } else {
            let fullscreenVC = UIViewController()
            fullscreenVC.modalPresentationStyle = .fullScreen
            fullscreenVC.view.backgroundColor = .black
            self.removeFromSuperview()
            fullscreenVC.view.addSubview(self)
            self.frame = fullscreenVC.view.bounds
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            parentVC.present(fullscreenVC, animated: true, completion: nil)
            isFullscreen = true
        }
    }

    private func findParentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let item = object as? AVPlayerItem,
           item.status == .readyToPlay {
            activityIndicator.stopAnimating()
        }
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
