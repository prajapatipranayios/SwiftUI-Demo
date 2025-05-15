//
//  VideoDemoVC.swift
//  SwiftDemo-2
//
//  Created by Auxano on 15/05/25.
//

import Foundation
import UIKit


// MARK: - Demo View Controllers
class VideoDemoVC: UIViewController {
    
    @IBOutlet weak var viewVideoPlayer: VideoPlayerView!
    //private var videoPlayer = VideoPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if let videoURL = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4") {
            viewVideoPlayer.configure(with: videoURL, shouldLoop: true)
            viewVideoPlayer.play()  
        }
        //  */
        let arrUrl: [String] = [
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4"
        ]
        
        let urls = arrUrl.compactMap { URL(string: $0) }
        
        viewVideoPlayer.configure(with: urls, startAt: 0)
        viewVideoPlayer.play()
    }
    
    private func setupVideoPlayer() {
        //view.addSubview(videoPlayer)
        //videoPlayer.translatesAutoresizingMaskIntoConstraints = false
        
//        NSLayoutConstraint.activate([
//            videoPlayer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            videoPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            videoPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            videoPlayer.heightAnchor.constraint(equalTo: videoPlayer.widthAnchor, multiplier: 9/16)
//        ])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //viewVideoPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewVideoPlayer.cleanUpPlayer()
    }
}
