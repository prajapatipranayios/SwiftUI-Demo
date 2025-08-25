//
//  ViewController.swift
//  ConversationalAI-ElevanLabs
//
//  Created by Auxano on 21/08/25.
//

import UIKit
import ImageIO
import AVFoundation
import ElevenLabs

class ViewController: UIViewController {

    // MARK: - Outlet
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var ivVoice: UIImageView!
    
    @IBOutlet weak var lblAIConnectionStatus: UILabel!
    @IBOutlet weak var lblAIStatus: UILabel!
    
    @IBOutlet weak var viewButtonConnectDisconnect: UIView!
    
    @IBOutlet weak var btnConnectDisconnect: UIButton!
    @IBOutlet weak var constraintLeadingBtnConnectToSuper: NSLayoutConstraint!
    @IBOutlet weak var btnMute: UIButton!
    
    // MARK: - Variable
    
    var status: ElevenLabs.AgentState = .listening
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.constraintLeadingBtnConnectToSuper.priority = .required
        
        self.ivVoice.contentMode = .scaleAspectFit
        self.ivVoice.image = UIImage.animatedImageFromGIF(named: "voice") // sample.gif in bundle
        
        self.lblAIConnectionStatus.text = "Status: Disconnected"
        self.lblAIStatus.text = ""
        self.lblAIStatus.isHidden = true
        
        self.requestMicrophonePermission()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func requestMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        print("✅ Microphone permission granted")
                    } else {
                        print("❌ Microphone permission denied")
                    }
                }
            }
        case .denied:
            print("❌ Microphone access previously denied. Guide user to Settings.")
        case .granted:
            print("✅ Microphone access already granted")
        @unknown default:
            break
        }
    }
    
    @IBAction func btnConnectDisconnectTap(_ sender: UIButton) {
        Task {
            do {
                try await ElevenLabs.startConversation(agentId: "agent_0501k361qpr1frkbqbe82v9rafym") {
                    self.lblAIConnectionStatus.text = "Status: Connected"
                    //self.lblAIStatus.text = ElevenLabs.AgentState ...
                    //self.lblAIStatus.isHidden = true
                    print("Conection successfull")
                } onDisconnect: {
                    print("Disconection successfull")
                    self.lblAIConnectionStatus.text = "Status: Disconnected"
                }
            } catch {
                // Handle error here
                print("Failed to start conversation: \(error)")
                self.lblAIConnectionStatus.text = "Status: Error"
            }
        }
    }
    
    @IBAction func btnMuteTap(_ sender: UIButton) {
        
    }
    
}

extension UIImage {
    static func animatedImageFromGIF(named name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }

            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as Dictionary?,
               let gifDict = properties[kCGImagePropertyGIFDictionary] as? NSDictionary,
               let delayTime = gifDict[kCGImagePropertyGIFDelayTime] as? Double {
                duration += delayTime
            }
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }
}
