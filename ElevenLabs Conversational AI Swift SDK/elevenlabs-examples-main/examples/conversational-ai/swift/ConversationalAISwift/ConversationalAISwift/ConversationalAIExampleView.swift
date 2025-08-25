import SwiftUI
import AVFAudio
import ElevenLabsSDK
import _Concurrency
import SDWebImageSwiftUI
import ImageIO
import UIKit

// MARK: - Orb View
struct OrbView: View {
    let mode: ElevenLabsSDK.Mode
    let audioLevel: Float
    
    var body: some View {
        ZStack {
            GIFView(name: "voice")
                .frame(width: 80, height: 80)
                .scaleEffect(0.9 + CGFloat(audioLevel * 3)) // pulsing effect
        }
    }
}

// MARK: - Conversational AI Example View
struct ConversationalAIExampleView: View {
    @State private var currentAgentIndex = 0
    @State private var conversation: ElevenLabsSDK.Conversation?
    @State private var audioLevel: Float = 0.0
    @State private var mode: ElevenLabsSDK.Mode = .listening
    @State private var status: ElevenLabsSDK.Status = .disconnected
    @State private var isMicEnabled: Bool = true   // mic state
    
    let agents = [
        Agent(
            id: "agent_0501k361qpr1frkbqbe82v9rafym",
            name: "Matilda",
            description: "Math tutor"
        )
    ]
    
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Helpers
    private var statusText: String {
        switch status {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting..."
        @unknown default: return "Unknown"
        }
    }
    
    private var modeText: String {
        switch mode {
        case .listening: return "Listening"
        case .speaking: return "Speaking"
        default: return "Idle"
        }
    }
    
    
    private func beginConversation(agent: Agent) {
        if status == .connected {
            conversation?.endSession()
            conversation = nil
        }
        else {
            Task {
                do {
                    let config = ElevenLabsSDK.SessionConfig(agentId: agent.id)
                    var callbacks = ElevenLabsSDK.Callbacks()
                    
                    callbacks.onConnect = { _ in
                        status = .connected
                    }
                    callbacks.onDisconnect = {
                        status = .disconnected
                    }
                    callbacks.onMessage = { message, _ in
                        print("Message: \(message)")
                    }
                    callbacks.onError = { errorMessage, _ in
                        print("Error: \(errorMessage)")
                    }
                    callbacks.onStatusChange = { newStatus in
                        status = newStatus
                    }
                    callbacks.onModeChange = { newMode in
                        mode = newMode
                    }
                    callbacks.onVolumeUpdate = { newVolume in
                        audioLevel = newVolume
                    }
                    
                    conversation = try await ElevenLabsSDK.Conversation.startSession(config: config, callbacks: callbacks)
                } catch {
                    print("Error starting conversation: \(error)")
                }
            }
        }
    }
    
    // MARK: - Toggle mic
    private func toggleMic() {
        if isMicEnabled {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            print("🎙️ Mic is now OFF")
        } else {
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                // 👉 Send mic audio to ElevenLabs if supported
                // conversation?.sendAudio(buffer)
            }
            
            do {
                try audioEngine.start()
                print("🎙️ Mic is now ON")
            } catch {
                print("⚠️ Failed to start mic:", error)
            }
        }
        isMicEnabled.toggle()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    OrbView(mode: mode, audioLevel: audioLevel)
                        .padding(.bottom, 20)
                    
                    Spacer()
                    // 📌 Connection Status
                    Text("Status: \(statusText)")
                        .font(.headline)
                        .padding(.top, 40)
                    
                    // 📌 Mode Status
                    if status == .connected {
                        Text("Mode: \(modeText)")
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    // Buttons
                    HStack(spacing: 40) {
                        
                        // Mic Button -> Only show when connected
                        if status == .connected {
                            AudioButton(
                                isMicEnabled: isMicEnabled,
                                action: toggleMic
                            )
                        }
                        
                        // Call Button -> Always visible
                        CallButton(
                            connectionStatus: status,
                            action: { beginConversation(agent: agents[currentAgentIndex]) }
                        )
                    }
                    .padding(.bottom, 40)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

// MARK: - Call Button
struct CallButton: View {
    let connectionStatus: ElevenLabsSDK.Status
    let action: () -> Void
    
    private var buttonIcon: String {
        switch connectionStatus {
        case .connected:
            return "phone.down.fill"
        case .connecting:
            return "phone.arrow.up.right.fill"
        case .disconnecting:
            return "phone.arrow.down.left.fill"
        default:
            return "phone.fill"
        }
    }
    
    private var buttonColor: Color {
        switch connectionStatus {
        case .connected:
            return .red
        case .connecting, .disconnecting:
            return .gray
        default:
            return .black
        }
    }
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(buttonColor)
                .frame(width: 64, height: 64)
                .shadow(radius: 5)
                .overlay(
                    Image(systemName: buttonIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Audio Button (Mic Toggle)
struct AudioButton: View {
    let isMicEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isMicEnabled ? Color.green : Color.gray)
                .frame(width: 64, height: 64)
                .shadow(radius: 5)
                .overlay(
                    Image(systemName: isMicEnabled ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                )
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Agent model
struct Agent {
    let id: String
    let name: String
    let description: String
}

// MARK: - GIFView
struct GIFView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        if let path = Bundle.main.path(forResource: name, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let gifImage = UIImage.gifImageWithData(data) {
            imageView.image = gifImage
        }
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

// MARK: - UIImage Extension for GIF
extension UIImage {
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return UIImage.animatedImageWithSource(source)
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [UIImage]()
        var duration: Double = 0
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                duration += 0.1
            }
        }
        return UIImage.animatedImage(with: images, duration: duration)
    }
}

// MARK: - Preview
struct ConvAIExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationalAIExampleView()
    }
}
