//
//  APVideoPlayer.swift
//  SwiftDemo1
//
//  Created by Auxano on 08/05/25.
//

import UIKit
import AVFoundation

protocol APVideoPlayerDelegate: AnyObject {
    func didToggleFullScreen(from player: APVideoPlayer)
}

class APVideoPlayer: UIView {
    
    // MARK: - UI Components
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserverToken: Any?
    
    private let playPauseButton = UIButton(type: .system)
    private let slider = UISlider()
    private let speedButton = UIButton(type: .system)
    private let fullScreenButton = UIButton(type: .system)

    weak var delegate: APVideoPlayerDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayer()
        setupControls()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
        setupControls()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        layoutControls()
    }

    // MARK: - Setup
    private func setupPlayer() {
        player = AVPlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            layer.insertSublayer(playerLayer, at: 0)
        }

        // Add observer for slider updates
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main, using: { [weak self] time in
            self?.updateSlider()
        })
    }

    private func setupControls() {
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)

        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        speedButton.setTitle("1x", for: .normal)
        speedButton.addTarget(self, action: #selector(changeSpeed), for: .touchUpInside)

        fullScreenButton.setTitle("⤢", for: .normal)
        fullScreenButton.addTarget(self, action: #selector(toggleFullScreen), for: .touchUpInside)

        [playPauseButton, slider, speedButton, fullScreenButton].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func layoutControls() {
        let padding: CGFloat = 10
        let buttonHeight: CGFloat = 30
        
        NSLayoutConstraint.activate([
            playPauseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            playPauseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            playPauseButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            slider.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: padding),
            slider.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            speedButton.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: padding),
            speedButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            speedButton.widthAnchor.constraint(equalToConstant: 40),

            fullScreenButton.leadingAnchor.constraint(equalTo: speedButton.trailingAnchor, constant: padding),
            fullScreenButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            fullScreenButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            fullScreenButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Playback Control
    func playVideo(from url: URL) {
        let item = AVPlayerItem(url: url)
        player?.replaceCurrentItem(with: item)
        player?.play()
        playPauseButton.setTitle("Pause", for: .normal)
    }

    func playVideo(fromLocalPath path: String) {
        let url = URL(fileURLWithPath: path)
        playVideo(from: url)
    }

    func pause() {
        player?.pause()
        playPauseButton.setTitle("Play", for: .normal)
    }

    func play() {
        player?.play()
        playPauseButton.setTitle("Pause", for: .normal)
    }

    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        playPauseButton.setTitle("Play", for: .normal)
    }

    @objc private func togglePlayPause() {
        if player?.timeControlStatus == .playing {
            pause()
        } else {
            play()
        }
    }

    @objc private func sliderChanged() {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
        let newTime = CMTime(seconds: Double(slider.value) * duration, preferredTimescale: 600)
        player?.seek(to: newTime)
    }

    private func updateSlider() {
        guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
        let currentTime = player?.currentTime().seconds ?? 0
        slider.value = Float(currentTime / duration)
    }

    @objc private func changeSpeed() {
        guard let currentRate = player?.rate else { return }
        let nextRate: Float
        switch currentRate {
        case 1.0: nextRate = 1.5
        case 1.5: nextRate = 2.0
        default: nextRate = 1.0
        }
        player?.rate = nextRate
        if player?.timeControlStatus != .playing {
            player?.play()
        }
        speedButton.setTitle("\(nextRate)x", for: .normal)
    }

    @objc private func toggleFullScreen() {
        delegate?.didToggleFullScreen(from: self)
    }

    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
    }
}
