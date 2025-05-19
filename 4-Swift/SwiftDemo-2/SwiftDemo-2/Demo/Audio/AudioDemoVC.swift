//
//  AudioDemoVC.swift
//  SwiftDemo-2
//
//  Created by Auxano on 15/05/25.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer


// MARK: - Demo View Controllers
class AudioPlayerVC: UIViewController {
    
    // MARK: - UI Components
    
    private let posterImageView = UIImageView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let playPauseButton = UIButton()
    private let speedButton = UIButton()
    private let downloadButton = UIButton()
    private let sleepTimerButton = UIButton()

    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()

    private let skipForwardButton = UIButton()
    private let skipBackwardButton = UIButton()
    private let nextButton = UIButton()
    private let previousButton = UIButton()
    
    
    // MARK: - Player
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var isPlaying = false
    private var currentSpeedIndex = 0
    private let trackSpeeds: [Float] = [1.0, 1.5, 2.0, 3.0]
    private var isPremiumUser = false // Toggle based on actual login state
    private var sleepTimer: Timer?
    private var audioURLs: [URL] {  // Your audio list
        let arrTemp = [
            "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.wav",
            "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3",
            "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba-online-audio-converter.com_-1.wav",
            "https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg"
        ]
        return arrTemp.compactMap { URL(string: $0) }
    }
    private var currentAudioIndex: Int = 0
    private var timeObserverToken: Any?
    private var currentRate: Float = 1.0
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //setupUI_SecondOption()
        setupPlayer()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white

        // MARK: Poster Image
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.image = UIImage(named: "audio_poster") ?? UIImage(systemName: "music.note")
        view.addSubview(posterImageView)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Thumbnail Image
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.image = UIImage(named: "audio_thumbnail") ?? UIImage(systemName: "music.note")
        view.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Title Label
        titleLabel.text = "Audio Title"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 1
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Description Label
        descriptionLabel.text = "Audio description goes here. This is a short summary."
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .darkGray
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Speed Button
        speedButton.setTitle("1x", for: .normal)
        speedButton.addTarget(self, action: #selector(changeSpeed), for: .touchUpInside)
        //speedButton.backgroundColor = .systemBlue
        speedButton.setTitleColor(.black, for: .normal)
        view.addSubview(speedButton)
        speedButton.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Sleep Timer Button
        sleepTimerButton.setTitle("⏰", for: .normal)
        sleepTimerButton.addTarget(self, action: #selector(setSleepTimer), for: .touchUpInside)
        view.addSubview(sleepTimerButton)
        sleepTimerButton.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Download Button
        downloadButton.setTitle("⬇️", for: .normal)
        downloadButton.isEnabled = isPremiumUser
        view.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Progress Slider
        progressSlider.addTarget(self, action: #selector(seekAudio), for: .valueChanged)
        view.addSubview(progressSlider)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Time Labels
        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        // MARK: Playback Buttons
        playPauseButton.setSymbolImage("play.fill", tintColor: .systemBlue)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        setButtonSize(playPauseButton, width: 60, height: 60)
        
        skipForwardButton.setSymbolImage("goforward.10", pointSize: 25, tintColor: .systemBlue)
        skipForwardButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        setButtonSize(skipForwardButton, width: 40, height: 40)
        
        skipBackwardButton.setSymbolImage("gobackward.10", pointSize: 25, tintColor: .systemBlue)
        skipBackwardButton.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
        setButtonSize(skipBackwardButton, width: 40, height: 40)
        
        nextButton.setSymbolImage("forward.end.alt.fill", pointSize: 25, tintColor: .systemBlue)
        nextButton.addTarget(self, action: #selector(playNextAudio), for: .touchUpInside)
        setButtonSize(nextButton, width: 40, height: 40)
        
        previousButton.setSymbolImage("backward.end.alt.fill", pointSize: 25, tintColor: .systemBlue)
        previousButton.addTarget(self, action: #selector(playPreviousAudio), for: .touchUpInside)
        setButtonSize(previousButton, width: 40, height: 40)

        [playPauseButton, skipForwardButton, skipBackwardButton, nextButton, previousButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        sleepTimerButton.setTitle("⏰", for: .normal)
        sleepTimerButton.addTarget(self, action: #selector(setSleepTimer), for: .touchUpInside)
        
        // MARK: Constraints
        setupConstraints()
    }
    
    private func setButtonSize(_ button: UIButton, width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    private func setupUI_SecondOption() {
        view.backgroundColor = .white

        // MARK: - Configure Elements
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.image = UIImage(named: "audio_poster") ?? UIImage(systemName: "music.note")

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.image = UIImage(named: "audio_thumbnail") ?? UIImage(systemName: "music.note")
        thumbnailImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true

        titleLabel.text = "Audio Title"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 1

        descriptionLabel.text = "Audio description goes here. This is a short summary."
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .darkGray

        speedButton.setTitle("1x", for: .normal)
        speedButton.addTarget(self, action: #selector(changeSpeed), for: .touchUpInside)

        sleepTimerButton.setTitle("⏰", for: .normal)
        sleepTimerButton.addTarget(self, action: #selector(setSleepTimer), for: .touchUpInside)

        downloadButton.setTitle("⬇️", for: .normal)
        downloadButton.isEnabled = isPremiumUser

        playPauseButton.setTitle("▶️", for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)

        //skipForwardButton.setTitle("⏩10s", for: .normal)
        skipForwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        skipForwardButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)

        //skipBackwardButton.setTitle("⏪10s", for: .normal)
        skipBackwardButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        skipBackwardButton.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)

        nextButton.setTitle("⏭", for: .normal)
        previousButton.setTitle("⏮", for: .normal)

        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"

        progressSlider.addTarget(self, action: #selector(seekAudio), for: .valueChanged)

        // MARK: - Stack Views

        let thumbnailStack = UIStackView(arrangedSubviews: [thumbnailImageView, titleLabel])
        thumbnailStack.axis = .horizontal
        thumbnailStack.spacing = 8
        thumbnailStack.alignment = .center

        let controlButtonStack = UIStackView(arrangedSubviews: [speedButton, sleepTimerButton, downloadButton])
        controlButtonStack.axis = .horizontal
        controlButtonStack.spacing = 20
        controlButtonStack.distribution = .equalSpacing
        controlButtonStack.alignment = .center

        let timeLabelStack = UIStackView(arrangedSubviews: [currentTimeLabel, UIView(), durationLabel])
        timeLabelStack.axis = .horizontal

        let transportControlStack = UIStackView(arrangedSubviews: [previousButton, skipBackwardButton, playPauseButton, skipForwardButton, nextButton])
        transportControlStack.axis = .horizontal
        transportControlStack.spacing = 20
        transportControlStack.alignment = .center
        transportControlStack.distribution = .equalCentering

        // Main vertical stack
        let mainStack = UIStackView(arrangedSubviews: [
            posterImageView,
            thumbnailStack,
            descriptionLabel,
            controlButtonStack,
            progressSlider,
            timeLabelStack,
            transportControlStack
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        // MARK: - Constraints
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalToConstant: 150),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        sleepTimerButton.setTitle("⏰", for: .normal)
        sleepTimerButton.addTarget(self, action: #selector(setSleepTimer), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = 20

        // Poster Image
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            posterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),
            posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor)
        ])

        // Thumbnail, Title, Desc
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            thumbnailImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 30),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),

            descriptionLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])

        // Speed, Sleep, Download
        [speedButton, sleepTimerButton, downloadButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            speedButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            speedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),

            sleepTimerButton.centerYAnchor.constraint(equalTo: speedButton.centerYAnchor),
            sleepTimerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            downloadButton.centerYAnchor.constraint(equalTo: speedButton.centerYAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin)
        ])

        // Slider and Time
        [progressSlider, currentTimeLabel, durationLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            progressSlider.topAnchor.constraint(equalTo: speedButton.bottomAnchor, constant: 30),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),

            durationLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            durationLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor)
        ])

        // Playback Control Row
        [previousButton, skipBackwardButton, playPauseButton, skipForwardButton, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 30),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            skipBackwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            skipBackwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -20),

            skipForwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            skipForwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20),

            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: skipBackwardButton.leadingAnchor, constant: -20),

            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: skipForwardButton.trailingAnchor, constant: 20)
        ])
    }
    
    private func setupPlayer() {
        //guard let url = URL(string: "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.wav") else { return }
        //player = AVPlayer(url: url)
        //addPeriodicTimeObserver()
        
        self.loadAudio(at: currentAudioIndex)
    }
    
    // MARK: - Actions
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            playPauseButton.setSymbolImage("play.fill", tintColor: .systemBlue)
        } else {
            player.play()
            player.rate = currentRate
            playPauseButton.setSymbolImage("pause.fill", tintColor: .systemBlue)
        }
        isPlaying.toggle()
    }
    
    @objc private func changeSpeed() {
        currentSpeedIndex = (currentSpeedIndex + 1) % trackSpeeds.count
        let speed = trackSpeeds[currentSpeedIndex]
        currentRate = trackSpeeds[currentSpeedIndex]
        speedButton.setTitle("\(currentRate)x", for: .normal)
        
        if isPlaying {
            player?.rate = speed
        }
    }

    @objc private func skipForward() {
        seekBy(seconds: 10)
    }

    @objc private func skipBackward() {
        seekBy(seconds: -10)
    }
    
    private func seekBy(seconds: Float64) {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(seconds, preferredTimescale: 1))
        player?.seek(to: newTime)
    }
    
    @objc private func playNextAudio() {
        guard currentAudioIndex + 1 < audioURLs.count else { return }
        currentAudioIndex += 1
        loadAudio(at: currentAudioIndex)
    }
    
    @objc private func playPreviousAudio() {
        guard currentAudioIndex - 1 >= 0 else { return }
        currentAudioIndex -= 1
        loadAudio(at: currentAudioIndex)
    }
    
    private func loadAudio(at index: Int) {
        guard index >= 0, index < audioURLs.count else { return }
        
        // Pause old player and remove observer
        player?.pause()
        removePeriodicTimeObserver()
        
        // Set up new player
        let url = audioURLs[index]
        player = AVPlayer(url: url)
        
        // Start observing and playing
        addPeriodicTimeObserver()
        player?.play()
        isPlaying = true
        
        // Update play button image
        playPauseButton.setSymbolImage("pause.fill", tintColor: .systemBlue) // Using your global function
        
        // Optionally update UI: title, description, etc.
        updateAudioUI(for: index)
    }
    
    private func setupNowPlaying(title: String, artist: String = "Unknown Artist", duration: TimeInterval) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds ?? 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? currentRate : 0

        // Optional: Add artwork
        if let image = UIImage(named: "audio_thumbnail") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.player?.play()
            self?.player?.rate = self?.currentRate ?? 1.0
            self?.isPlaying = true
            self?.updateNowPlayingPlaybackRate()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.player?.pause()
            self?.isPlaying = false
            self?.updateNowPlayingPlaybackRate()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNextAudio()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPreviousAudio()
            return .success
        }
    }
    
    private func updateNowPlayingPlaybackRate() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? currentRate : 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime().seconds ?? 0
    }
    
    private func updateAudioUI(for index: Int) {
        titleLabel.text = "Audio \(index + 1)"
        // descriptionLabel.text = ...
        // posterImageView.image = ...
    }
    
    @objc private func setSleepTimer() {
        let alert = UIAlertController(title: "Set Sleep Timer",
                                      message: "Select duration (in minutes)",
                                      preferredStyle: .actionSheet)

        if sleepTimer != nil {
            alert.addAction(UIAlertAction(title: "Cancel Timer", style: .destructive, handler: { [weak self] _ in
                self?.sleepTimer?.invalidate()
                self?.sleepTimer = nil
                print("Sleep timer cancelled.")
            }))
        }

        let durations: [Int] = [15, 20, 30, 45, 60]
        for duration in durations {
            alert.addAction(UIAlertAction(title: "\(duration) minutes", style: .default, handler: { [weak self] _ in
                self?.startSleepTimer(minutes: duration)
            }))
        }

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sleepTimerButton
            popover.sourceRect = sleepTimerButton.bounds
        }

        present(alert, animated: true, completion: nil)
    }
    
    private func startSleepTimer(minutes: Int) {
        sleepTimer?.invalidate()

        sleepTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
            self?.player?.pause()
            self?.isPlaying = false
            self?.playPauseButton.setTitle("▶️", for: .normal)
            print("Sleep timer completed. Audio paused.")
        }

        print("Sleep timer set for \(minutes) minutes.")
    }

    @objc private func seekAudio() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(progressSlider.value) * totalSeconds
        player?.seek(to: CMTime(seconds: value, preferredTimescale: 600))
    }

    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            self.updateProgress(seconds: seconds)
        }
    }

    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func updateProgressUI() {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let currentTime = player.currentTime()
        currentTimeLabel.text = currentTime.positionalTime
        durationLabel.text = duration.positionalTime

        let total = CMTimeGetSeconds(duration)
        let current = CMTimeGetSeconds(currentTime)
        progressSlider.value = Float(current / total)
    }
    
    private func updateProgress(seconds: Double) {
        currentTimeLabel.text = formatTime(seconds)
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            durationLabel.text = formatTime(totalSeconds)
            progressSlider.value = Float(seconds / totalSeconds)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    deinit {
        //if let observer = timeObserver {
        //    player?.removeTimeObserver(observer)
        //}
        
        removePeriodicTimeObserver()
    }
}

// MARK: - CMTime Helper
private extension CMTime {
    var positionalTime: String {
        guard !CMTimeGetSeconds(self).isNaN else { return "00:00" }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension UIButton {
    func setSymbolImage(_ systemName: String,
                        pointSize: CGFloat = 30,
                        weight: UIImage.SymbolWeight = .regular,
                        tintColor: UIColor = .black,
                        state: UIControl.State = .normal) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        if let image = UIImage(systemName: systemName, withConfiguration: config) {
            self.setImage(image, for: state)
            self.tintColor = tintColor
        }
    }
}
