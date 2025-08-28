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
                .scaleEffect(0.9 + CGFloat(audioLevel * 0.1)) // pulsing effect
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
    
    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .voiceChat,
                                    options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
            print("🎵 Audio session configured successfully")
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
        }
    }
    
    //var strUserProfile: String = ""
    var tempAgent = ObjAgent()   // blank object
    
    private func beginConversation(agent: Agent) {
        self.configureAudioSession()
        
        if status == .connected {
            conversation?.endSession()
            conversation = nil
        }
        else {
            Task {
                do {
                    let overrides = ElevenLabsSDK.ConversationConfigOverride(
                        agent: ElevenLabsSDK.AgentConfig(
                            prompt: ElevenLabsSDK.AgentPrompt(prompt: "You are a helpful assistant"),
                            language: ElevenLabsSDK.Language(rawValue: "\(selectedLang?.languageCode ?? "en")".uppercased())
                        )
                    )
                    
                    print("Lang changed or not code >>>>>>>>> \(selectedLang?.languageCode ?? "en")")
                    
//                    let config = ElevenLabsSDK.SessionConfig(agentId: agent.id, overrides: overrides)
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
                        DispatchQueue.main.async {
                            print("🔄 Mode changed: \(newMode)")
                            mode = newMode
                        }
                    }
                    callbacks.onVolumeUpdate = { newVolume in
                        audioLevel = newVolume
                    }
                    
                    conversation = try await ElevenLabsSDK.Conversation.startSession(config: config, callbacks: callbacks)
                    
                    // 👇 Force audio routing once session is active
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                        let session = AVAudioSession.sharedInstance()
                        do {
                            try session.overrideOutputAudioPort(.speaker)  // force speaker
                            try session.setActive(true)
                            print("🔊 Audio routed to speaker")
                        } catch {
                            print("⚠️ Failed to route audio: \(error)")
                        }
                    }
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
        }
        else {
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
    
    @State private var selectedLang: AgentLang? = nil
    //https://i.pinimg.com/736x/71/c6/53/71c653c58ad23ecf35e95a9ace954254.jpg
    let agentLanguages: [AgentLang] = [
            AgentLang(id: 1, userID: nil, agentID: nil,
                      languageCode: "en", langFlagImage: "flag.checkered", firstMessage: nil,
                      voiceID: nil, modelID: nil, firstMessageTranslation: nil,
                      langNameIFlutter5120: nil, createdAt: nil, updatedAt: nil,
                      langName: "English"),
            AgentLang(id: 2, userID: nil, agentID: nil,
                      languageCode: "hi", langFlagImage: "flag.square", firstMessage: nil,
                      voiceID: nil, modelID: nil, firstMessageTranslation: nil,
                      langNameIFlutter5120: nil, createdAt: nil, updatedAt: nil,
                      langName: "Hindi"),
            AgentLang(id: 3, userID: nil, agentID: nil,
                      languageCode: "it", langFlagImage: "flag.checkered.circle.fill", firstMessage: nil,
                      voiceID: nil, modelID: nil, firstMessageTranslation: nil,
                      langNameIFlutter5120: nil, createdAt: nil, updatedAt: nil,
                      langName: "Italian")
        ]
    
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 📌 Background Image
            Image("bgMain") // from Assets
                .resizable()
                .scaledToFill()
                .ignoresSafeArea() // makes it full screen
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
//                    Picker("Select Language", selection: $selectedLang) {
//                        ForEach(self.agentLanguages, id: \.id) { lang in
//                            HStack {
//                                if let flag = lang.langFlagImage,
//                                   let url = URL(string: flag) {
//                                    AsyncImage(url: url) { phase in
//                                        switch phase {
//                                        case .empty:
//                                            ProgressView()
//                                                .frame(width: 24, height: 24)
//                                        case .success(let image):
//                                            image.resizable()
//                                                .scaledToFill()
//                                                .frame(width: 24, height: 24)
//                                                .clipShape(Circle())
//                                        case .failure(_):
//                                            Image(systemName: "flag")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 24, height: 24)
//                                                .clipShape(Circle())
//                                        @unknown default:
//                                            EmptyView()
//                                        }
//                                    }
//                                }
//                                Text(lang.langName ?? "Unknown")
//                                    .foregroundColor(.white)
//                            }
//                            .tag(lang.languageCode ?? "")
//                        }
//                    }
//                    .pickerStyle(MenuPickerStyle()) // 👈 Dropdown style
//                    .padding(.top, 16)
//                    .padding(.horizontal, 20)
//                    .background(Color.black.opacity(0.3))
//                    .cornerRadius(12)
//                    
//                    // Just to debug
//                    if let selectedLang {
//                        Text("Selected: \(selectedLang.langName ?? "")")
//                            .foregroundColor(.white)
//                    }
                    
                    Picker(selection: $selectedLang) {
                        ForEach(agentLanguages, id: \.id) { lang in
                            HStack {
                                if let flag = lang.langFlagImage {
                                    Image(systemName: flag)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .clipShape(Circle())
                                        .tint(Color.black)
                                }
                                Text(lang.langName ?? "Unknown")
                            }
                            .tag(lang as AgentLang?)
                        }
                    } label: {
                        HStack {
                            if let flag = selectedLang?.langFlagImage {
                                Image(flag)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                            }
                            Text(selectedLang?.langName ?? "Select Language")
                                .foregroundColor(.white)
                                //.padding(.horizontal, 16)
                        }
                        .padding(8)
                        .background(Color.black) // 👈 works
                        .cornerRadius(8)
                    }
                    .pickerStyle(MenuPickerStyle()) // 👈 makes it dropdown
                    .tint(.white)
                    .background(Color.black.opacity(0.17))
                    .cornerRadius(10)
                    .onAppear {
                        if selectedLang == nil {
                            selectedLang = self.agentLanguages.first // 👈 Default selection
                        }
                    }
                    .disabled(status == .connected) // 👈 disable dropdown if connected
                    
                    Spacer()
                    //OrbView(mode: mode, audioLevel: audioLevel)
                    //    .padding(.bottom, 20)
                    ZStack {
                        RippleBackground(status: status)
                            .frame(width: 350, height: 350)
                        
                        if let url = URL(string: self.tempAgent.imagePath ?? "") { // your URL string
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView() // loading state
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 170)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: 0)
                                        )
                                        .shadow(radius: 5)
                                case .failure(_):
                                    Image("defaultUser")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 170)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: 0)
                                        )
                                        .shadow(radius: 5)
                                @unknown default:
                                    Image("defaultUser")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 170, height: 170)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white, lineWidth: 0)
                                        )
                                        .shadow(radius: 5)
                                }
                            }
                        } else {
                            // Fallback if URL string is nil/invalid
                            Image("defaultUser")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 170, height: 170)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 0)
                                )
                                .shadow(radius: 5)
                        }
                    }
                    //Spacer()
                    // 📌 Agent Name
                    Text(self.tempAgent.name ?? "")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 0)
                    // 📌 Connection Status
                    Text("Status: \(statusText)")
                        .font(.system(size: 13))
                        .foregroundColor(
                            status == .connected ? .green : .gray
                        )
                        .padding(.top, 0)
                    // 📌 Mode Status
                    if status == .connected {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(mode == .speaking ? Color.green : Color.gray) // Dot color
                                .frame(width: 7, height: 7)                      // Dot size
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1)          // White border
                                )
                            
                            Text(modeText)
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        }
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
    
//    private var buttonIcon: String {
//        switch connectionStatus {
//        case .connected:
//            return "phone.down.fill"
//        case .connecting:
//            return "phone.arrow.up.right.fill"
//        case .disconnecting:
//            return "phone.arrow.down.left.fill"
//        default:
//            return "phone.fill"
//        }
//    }
    
    private var buttonImg: String {
        switch connectionStatus {
        case .connected:
            return "callEnd"
        case .connecting:
            return "call"
        case .disconnecting:
            return "callEnd"
        default:
            return "call"
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
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 60, height: 60)
                .shadow(radius: 5)
                .overlay(
                    Image(buttonImg)
                        .resizable() // for asset images
                        .scaledToFit()
                        //.frame(width: 24, height: 24)
                        //.foregroundColor(.white)
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
            RoundedRectangle(cornerRadius: 15)
                //.fill(isMicEnabled ? Color.green : Color.gray)
                .frame(width: 60, height: 60)
                .shadow(radius: 5)
                .overlay(
                    Image(isMicEnabled ? "unmute" : "unmute")
                        .resizable() // for asset images
                        .scaledToFit()
                        //.font(.system(size: 24, weight: .medium))
                        //.foregroundColor(.white)
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


// MARK: - SwiftUI Wrapper
struct RippleBackground: UIViewRepresentable {
    let status: ElevenLabsSDK.Status   // 👈 pass status from parent
    
    func makeUIView(context: Context) -> RippleBackgroundView {
        let view = RippleBackgroundView()
        return view
    }
    
    func updateUIView(_ uiView: RippleBackgroundView, context: Context) {
        if status == .connected || status == .connecting {
            uiView.start()
        } else {
            uiView.stop()
        }
    }
}

// MARK: - UIKit Ripple View
class RippleBackgroundView: UIView {
    
    private let rippleCount = 4
    private let rippleDuration: CFTimeInterval = 3
    private var isAnimating = false
    private var replicator: CAReplicatorLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    func start() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let replicator = CAReplicatorLayer()
        replicator.frame = bounds
        replicator.instanceCount = rippleCount
        replicator.instanceDelay = rippleDuration / Double(rippleCount)
        layer.addSublayer(replicator)
        self.replicator = replicator
        
        let rippleLayer = CAShapeLayer()
        rippleLayer.frame = bounds
        rippleLayer.path = UIBezierPath(
            ovalIn: bounds.insetBy(dx: bounds.width/3.5, dy: bounds.height/3.5)
        ).cgPath
        rippleLayer.fillColor = UIColor.clear.cgColor
        rippleLayer.strokeColor = Color.white.opacity(0.11).cgColor
        rippleLayer.lineWidth = 19.0
        rippleLayer.opacity = 0
        replicator.addSublayer(rippleLayer)
        
        // Animations
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 1.99
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.9
        opacity.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [scale, opacity]
        group.duration = rippleDuration
        group.repeatCount = .infinity
        
        rippleLayer.add(group, forKey: "ripple")
    }
    
    func stop() {
        replicator?.removeFromSuperlayer()
        isAnimating = false
    }
}






// MARK: - Welcome
struct ObjAgent: Codable, Identifiable {
    var id: Int?
    var userID: Int?
    var name: String?
    var role: String?
    var image: String?
    var agentID: String?
    var defaultLanguage: String?
    var langFlagImage: String?
    var langName: String?
    var firstMessage: String?
    var systemPrompt: String?
    var isExternalKnowledge: Int?
    var voiceID: String?
    var duration: Int?
    var noOfLanguages: Int?
    var isActive: Int?
    var createdAt: String?
    var updatedAt: String?
    var imagePath: String?
    var agentLang: [AgentLang]?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case name, role, image
        case agentID = "agentId"
        case defaultLanguage, langFlagImage, langName, firstMessage, systemPrompt, isExternalKnowledge
        case voiceID = "voiceId"
        case duration, noOfLanguages, isActive
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case imagePath
        case agentLang = "agent_lang"
    }
    
    // ✅ Empty initializer
    init() {
        self.id = 0
        self.userID = 0
        self.name = "Test Agent"
        self.role = ""
        self.image = ""
        self.agentID = ""
        self.defaultLanguage = ""
        self.langFlagImage = ""
        self.langName = ""
        self.firstMessage = ""
        self.systemPrompt = ""
        self.isExternalKnowledge = 0
        self.voiceID = ""
        self.duration = 0
        self.noOfLanguages = 0
        self.isActive = 0
        self.createdAt = ""
        self.updatedAt = ""
        self.imagePath = "https://cdn.growy.app/agents/second.png"
        self.agentLang = []
    }
}

// MARK: - AgentLang
struct AgentLang: Codable, Identifiable, Hashable {
    var id: Int?
    var userID: Int?
    var agentID: Int?
    var languageCode: String?
    var langFlagImage: String?
    var firstMessage: String?
    var voiceID: String?
    var modelID: String?
    var firstMessageTranslation: String?
    var langNameIFlutter5120: String?
    var createdAt: String?
    var updatedAt: String?
    var langName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case agentID = "agentId"
        case languageCode, langFlagImage, firstMessage
        case voiceID = "voiceId"
        case modelID = "modelId"
        case firstMessageTranslation
        case langNameIFlutter5120 = "langName I/flutter ( 5120): "
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case langName
    }
}
