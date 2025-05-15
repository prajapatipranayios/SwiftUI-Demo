//
//  VideoPlayerView.swift
//  SwiftDemo-2
//
//  Created by Auxano on 15/05/25.
//

import Foundation
import AVKit
import UIKit

class VideoPlayerView: UIView {
    
    // MARK: - Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var isVideoPlaying = false
    private var shouldLoop = false
    
    public var isPlaying: Bool {
        return isVideoPlaying
    }   //  */
    
    
    
    // MARK: - UI Components
    private let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        return view
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handlePrevious), for: .touchUpInside)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .systemBlue
        slider.maximumTrackTintColor = .lightGray
        slider.setThumbImage(UIImage(), for: .normal)
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    let buttonSize: CGFloat = 64
    let spacing: CGFloat = 20
    private var videoURLs: [URL] = []
    private var currentIndex: Int = 0

    
        
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .black
        setupPlayerLayer()
        setupControls()
        setupGestureRecognizers()
    }
    
    private func setupPlayerLayer() {
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer!)
    }
    
    private func setupControls() {
        addSubview(controlsContainerView)
        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(previousButton)
        controlsContainerView.addSubview(nextButton)
        controlsContainerView.addSubview(currentTimeLabel)
        controlsContainerView.addSubview(progressSlider)
        controlsContainerView.addSubview(durationLabel)
        
        controlsContainerView.alpha = 0
    }
    
    private func setupGestureRecognizers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        controlsContainerView.frame = bounds
        
        let buttonSize: CGFloat = 64
        let spacing: CGFloat = 20

        playPauseButton.frame = CGRect(
            x: (bounds.width - buttonSize) / 2,
            y: (bounds.height - buttonSize) / 2,
            width: buttonSize,
            height: buttonSize
        )

        previousButton.frame = CGRect(
            x: playPauseButton.frame.minX - spacing - buttonSize,
            y: playPauseButton.frame.minY,
            width: buttonSize,
            height: buttonSize
        )

        nextButton.frame = CGRect(
            x: playPauseButton.frame.maxX + spacing,
            y: playPauseButton.frame.minY,
            width: buttonSize,
            height: buttonSize
        )
        
        currentTimeLabel.frame = CGRect(x: 16, y: bounds.height - 30, width: 50, height: 20)
        durationLabel.frame = CGRect(x: bounds.width - 66, y: bounds.height - 30, width: 50, height: 20)
        progressSlider.frame = CGRect(
            x: currentTimeLabel.frame.maxX + 8,
            y: bounds.height - 30,
            width: durationLabel.frame.minX - currentTimeLabel.frame.maxX - 16,
            height: 20
        )
    }
    
    // MARK: - Public Configuration
    func configure(with urls: [URL], startAt index: Int = 0, shouldLoop: Bool = false) {
        guard !urls.isEmpty else { return }
        self.videoURLs = urls
        self.shouldLoop = shouldLoop
        self.currentIndex = index
        loadVideo(at: currentIndex)
    }
    
    private func loadVideo(at index: Int) {
        guard index >= 0 && index < videoURLs.count else { return }
        
        player?.pause()
        playerLayer?.player = nil
        
        let url = videoURLs[index]
        player = AVPlayer(url: url)
        playerLayer?.player = player
        
        isVideoPlaying = false
        
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

        addPeriodicTimeObserver()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    public func play() {
        player?.play()
        isVideoPlaying = true
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    public func pause() {
        player?.pause()
        isVideoPlaying = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    public func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isVideoPlaying = false
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    @objc private func handlePrevious() {
        // Implement previous logic
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        loadVideo(at: currentIndex)
        play()
    }

    @objc private func handleNext() {
        // Implement next logic
        guard currentIndex < videoURLs.count - 1 else { return }
        currentIndex += 1
        loadVideo(at: currentIndex)
        play()
    }
    
    @objc func cleanUpPlayer() {
        pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer?.player = nil
        removePeriodicTimeObserver()
    }
    
    // MARK: - Time Observers
    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateUI()
        }
    }
    
    private func removePlayerObservers() {
        removePeriodicTimeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func removePeriodicTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - UI Update
    private func updateUI() {
        guard let currentTime = player?.currentTime(),
              let duration = player?.currentItem?.duration else { return }
        
        currentTimeLabel.text = currentTime.positionalTime
        durationLabel.text = duration.positionalTime
        
        let progress = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        progressSlider.value = progress
    }
    
    // MARK: - Actions
    @objc private func handlePlayPause() {
        isVideoPlaying ? pause() : play()
    }
    
    @objc private func handleSliderChange() {
        guard let duration = player?.currentItem?.duration else { return }
        let seconds = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: seekTime)
    }
    
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = self.controlsContainerView.alpha == 0 ? 1 : 0
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        if shouldLoop {
            player?.seek(to: .zero)
            play()
        } else {
            stop()
        }
    }
    
    // MARK: - Cleanup
    deinit {
        removePlayerObservers()
    }
}

// MARK: - CMTime Helper
private extension CMTime {
    var positionalTime: String {
        let total = CMTimeGetSeconds(self)
        guard !total.isNaN else { return "00:00" }
        let hrs = Int(total) / 3600
        let mins = (Int(total) / 60) % 60
        let secs = Int(total) % 60
        return hrs > 0 ? String(format: "%d:%02d:%02d", hrs, mins, secs) : String(format: "%02d:%02d", mins, secs)
    }
}
