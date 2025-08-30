import SwiftUI
import AVFAudio
import ElevenLabsSDK
import _Concurrency
import SDWebImageSwiftUI
import ImageIO
import UIKit

import SVGKitSwift
import SVGKit


// MARK: - Conversational AI Example View
struct ConversationalAIExampleView: View {
    @State private var conversation: ElevenLabsSDK.Conversation?
    @State private var audioLevel: Float = 0.0
    @State private var mode: ElevenLabsSDK.Mode = .listening
    @State private var status: ElevenLabsSDK.Status = .disconnected
    @State private var isMicEnabled: Bool = true   // mic state
    @State private var chatMessages: [ChatMessage] = []
    
    struct ChatMessage: Identifiable, Equatable {
        let id = UUID()
        let role: String   // "user" or "assistant"
        let text: String

        static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
            return lhs.id == rhs.id && lhs.role == rhs.role && lhs.text == rhs.text
        }
    }
    
//    let agents = [
//        Agent(
//            id: "agent_0501k361qpr1frkbqbe82v9rafym",
//            name: "Matilda",
//            description: "Math tutor"
//        )
//    ]
    
//    var agents = ObjAgent(
//        id: "agent_0501k361qpr1frkbqbe82v9rafym",
//        name: "Matilda",
//        description: "Math tutor"
//    )
    
    var agent : ObjAgent
    var userId: String
    var baseUrl: String
    
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
    //var tempAgent = ObjAgent()   // blank object
    
    private func beginConversation(agent: ObjAgent) {
        self.configureAudioSession()
        
        if status == .connected {
            conversation?.endSession()
            conversation = nil
        }
        else {
            Task {
                do {
                    
                    let langCode = (selectedLang?.languageCode ?? "en").lowercased()

                    guard let lang = ElevenLabsSDK.Language(rawValue: langCode) else {
                        print("⚠️ Invalid language code, falling back to English")
                        return
                    }
                    
                    let overrides = ElevenLabsSDK.ConversationConfigOverride(
                        agent: ElevenLabsSDK.AgentConfig(
                            prompt: ElevenLabsSDK.AgentPrompt(prompt: "You are a helpful assistant"),
                            language: lang
                        )
                    )
                    
                    let config = ElevenLabsSDK.SessionConfig(agentId: agent.agentID ?? "", overrides: overrides)
                    //let config = ElevenLabsSDK.SessionConfig(agentId: agent.id)
                    
                    var callbacks = ElevenLabsSDK.Callbacks()
                    callbacks.onConnect = { _ in
                        status = .connected
                    }
                    callbacks.onDisconnect = {
                        status = .disconnected
                    }
                    callbacks.onMessage = { message, role in
                        print("Message: \(role) >>> \(message)")
                        DispatchQueue.main.async {
                            let newMessage = ChatMessage(role: "\(role)", text: message)
                            chatMessages.append(newMessage)
                        }
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            self.backgroundView
            
            VStack(spacing: 0) {
                
                self.languagePicker
                
                self.avatarWithRipple
                
                // 📌 Agent Name
                Text(self.agent.name ?? "")
                    //.font(.headline)
                    .font(.custom("Rubik-Bold", size: 20)) // ✅ Bold
                    .foregroundColor(.white)
                    .padding(.top, 0)
                
                // 📌 Connection Status
                Text("Status: \(statusText)")
                    //.font(.system(size: 13))
                    .font(.custom("Rubik-Regular", size: 13)) // ✅ Regular
                    .foregroundColor(
                        status == .connected ? .green : .gray
                    )
                    .padding(.bottom, 10)
                
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
                            //.font(.system(size: 13))
                            .font(.custom("Rubik-Regular", size: 13)) // ✅ Regular
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 5)
                }
                
                // Buttons
                HStack(spacing: 0) {
                    
                    // Mic Button -> Only show when connected
//                    if status == .connected {
//                        AudioButton(
//                            isMicEnabled: isMicEnabled,
//                            action: toggleMic
//                        )
//                    }
                    
                    // Call Button -> Always visible
                    CallButton(
                        connectionStatus: status,
                        action: {
                            if status == .disconnected {
                                self.chatMessages.removeAll()
                            }
                            beginConversation(agent: agent)
                        }
                    )
                }
                .padding(.bottom, 5)
                
                communicationLog
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        AnyView(
            Group {
                if let url = URL(string: agent.imagePath ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .blur(radius: 10) // <-- Apply blur here
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "AA3789FF"),
                                            Color(hex: "AA051A37")
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .ignoresSafeArea()
                                )
                        case .failure(_):
                            defaultUserImage
                        @unknown default:
                            defaultUserImage
                        }
                    }
                } else {
                    defaultUserImage
                }
            }
        )
    }
    
    // MARK: - Default image with Gradient
    private var defaultUserImage: some View {
        AnyView(
            Image("defaultUser")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 10) // <-- Apply blur here
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "AA3789FF"),
                            Color(hex: "AA051A37")
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
        )
    }
    
    // MARK: - Default image for flag
    private func langFlagImage(_ urlString: String?) -> some View {
        Group {
            if let url = URL(string: urlString ?? "") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 24, height: 24)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .clipped()
                    case .failure(_):
                        defaultFlagImage
                    @unknown default:
                        defaultFlagImage
                    }
                }
            } else {
                defaultFlagImage
            }
        }
        .frame(width: 24, height: 24)   // ✅ guarantee final box
        .padding(.trailing, 8)
    }
    
    // MARK: - Default image with Gradient
    private var defaultFlagImage: some View {
        AnyView(
            Image(systemName: "flag")
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .clipped()
                .tint(.black)
        )
        .padding(.trailing, 8)
    }
    
    // Simple & safe version
    private var languagePicker: some View {
        Group {
            Picker(selection: $selectedLang) {
                ForEach(agent.agentLang ?? [], id: \.id) { lang in
                    HStack {
                        // ... your flag + text ...
                        langFlagImage(lang.langFlagImage ?? "") // ✅ load per-lang flag
                        Text(lang.langName ?? "Unknown")
                            .font(.custom("Rubik-Regular", size: 13)) // ✅ Bold
                            .foregroundColor(.white)
                    }
                    .tag(lang as AgentLang?)
                }
            } label: {
                HStack {
                    defaultUserImage
                    Text(selectedLang?.langName ?? "Select Language")
                        .font(.custom("Rubik-Regular", size: 13)) // ✅ Bold
                        .foregroundColor(.white)
                }
                .padding(0)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
            .tint(Color.white)
            .pickerStyle(.menu)
            .disabled(status == .connected)
            .onAppear {
                if selectedLang == nil { selectedLang = agent.agentLang?.first }
            }
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    // MARK: - Avatar with Ripple
    private var avatarWithRipple: some View {
        ZStack {
            RippleBackground(status: status)
                .frame(width: 300, height: 300)
            
            if let url = URL(string: agent.imagePath ?? "") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 170, height: 170)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    case .failure(_):
                        Image("defaultUser")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    @unknown default:
                        Image("defaultUser")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
            }
            else {
                Image("defaultUser")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 170)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }
    
    // MARK: - Communication Log
    private var communicationLog: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(chatMessages) { msg in
                            HStack(alignment: .top, spacing: 8) {
                                VStack(alignment: .leading) {
                                    Text(msg.role.lowercased() == "user" ? "\(self.agent.name ?? "") :" : "AI Response :")
                                        //.font(.system(size: 13).bold())
                                        .font(.custom("Rubik-Bold", size: 13)) // ✅ Bold
                                        .padding(.horizontal, 3)
                                        .padding(.vertical, 1)
                                        .foregroundColor(
                                            msg.role.lowercased() == "user" ? .red : .blue
                                        )
                                        .cornerRadius(6)
                                    
                                    Text(msg.text.isEmpty ? " " : msg.text)
                                        //.font(.system(size: 13))
                                        .font(.custom("Rubik-Regular", size: 13)) // ✅ Regular
                                        .foregroundColor(.white)
                                        .padding(1)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(msg.id) // ✅ give each message an id for scrolling
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                }
                .frame(width: UIScreen.main.bounds.width,
                       height: UIScreen.main.bounds.height / 4)
                .background(chatMessages.isEmpty ? .clear : Color.black.opacity(0.1) )
                .cornerRadius(12)
                .clipped()
                // 🔑 auto scroll when chatMessages changes
                .onChange(of: chatMessages.count) {
                    if let lastID = chatMessages.last?.id {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height / 4)
    }




}


// MARK: - Preview
struct ConvAIExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationalAIExampleView(agent: ObjAgent(), userId: "123", baseUrl: "Test Url")
    }
}


// MARK: - Call Button
struct CallButton: View {
    let connectionStatus: ElevenLabsSDK.Status
    let action: () -> Void
    
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
        .padding(.bottom, 10)
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
                    Image(isMicEnabled ? "mute" : "mute")
                        .resizable() // for asset images
                        .scaledToFit()
                        //.font(.system(size: 24, weight: .medium))
                        //.foregroundColor(.white)
                )
        }
        .tint(.clear)
        .padding(.bottom, 10)
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

// MARK: - Hex to Color
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex

        var rgba: UInt64 = 0
        scanner.scanHexInt64(&rgba)

        let a = Double((rgba & 0xFF000000) >> 24) / 255
        let r = Double((rgba & 0x00FF0000) >> 16) / 255
        let g = Double((rgba & 0x0000FF00) >> 8) / 255
        let b = Double(rgba & 0x000000FF) / 255

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - SwiftUI Wrapper
struct RippleBackground: UIViewRepresentable {
    let status: ElevenLabsSDK.Status   // 👈 pass status from parent
    
    func makeUIView(context: Context) -> RippleBackgroundView {
        let view = RippleBackgroundView()
        DispatchQueue.main.async {
            view.start()
        }
        return view
    }
    
    func updateUIView(_ uiView: RippleBackgroundView, context: Context) {
//        if status == .connected || status == .connecting {
//            uiView.start()
//        } else {
//            uiView.stop()
//        }
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
        rippleLayer.strokeColor = Color.white.opacity(0.31).cgColor
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
        self.name = "Darrell Steward"
        self.role = ""
        self.image = ""
        self.agentID = "agent_1901k3k9k4a3egv98f017dgsqc68" //"agent_1901k3k9k4a3egv98f017dgsqc68"
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
        self.agentLang = [
            AgentLang(
                id: 3,
                userID: 10680,
                agentID: 2,
                languageCode: "hi",
                langFlagImage: "https://storage.googleapis.com/eleven-public-cdn/images/flags/circle-flags/in.svg",
                firstMessage: "",
                voiceID: "iP95p4xoKVk53GoZ742B",
                modelID: "",
                firstMessageTranslation: "",
                createdAt: "2025-08-26T13:36:37.000000Z",
                updatedAt: "2025-08-27T13:31:13.000000Z",
                langName: "Hindi"
            ),
            AgentLang(
                id: 2,
                userID: 10680,
                agentID: 2,
                languageCode: "it",
                langFlagImage: "https://storage.googleapis.com/eleven-public-cdn/images/flags/circle-flags/it.svg",
                firstMessage: "",
                voiceID: "iP95p4xoKVk53GoZ742B",
                modelID: "",
                firstMessageTranslation: "",
                createdAt: "2025-08-26T13:36:37.000000Z",
                updatedAt: "2025-08-27T13:31:14.000000Z",
                langName: "Italian"
            )]
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
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case langName
    }
}



enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
    case head    = "HEAD"
    case options = "OPTIONS"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

struct APIService {
    
    static let shared = APIService()
    
    /// Generic API request with dynamic HTTP method
    func sendRequest(
        urlString: String,
        method: HTTPMethod,
        body: [String: Any]? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue   // ✅ use enum

        // Only attach body for POST/PUT/PATCH/DELETE (not GET/HEAD/OPTIONS)
        switch method {
        case .post, .put, .patch, .delete:
            if let body = body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        default:
            break
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            completion(.success(data))
        }.resume()
    }
}

//APIService.shared.request(
//    urlString: "https://yourapi.com/endpoint",
//    method: .post,
//    body: ["myString": "Hello API"]
//) { result in
//    switch result {
//    case .success(let response):
//        print("✅ POST Response:", response)
//    case .failure(let error):
//        print("❌ Error:", error.localizedDescription)
//    }
//}

//APIService.shared.request(
//    urlString: "https://yourapi.com/endpoint",
//    method: .get
//) { result in
//    switch result {
//    case .success(let response):
//        print("✅ GET Response:", response)
//    case .failure(let error):
//        print("❌ Error:", error.localizedDescription)
//    }
//}

//APIService.shared.request(
//    urlString: "https://yourapi.com/update",
//    method: .put,
//    body: ["id": 123, "value": "Updated"]
//) { result in
//    switch result {
//    case .success(let response):
//        print("✅ PUT Response:", response)
//    case .failure(let error):
//        print("❌ Error:", error.localizedDescription)
//    }
//}

