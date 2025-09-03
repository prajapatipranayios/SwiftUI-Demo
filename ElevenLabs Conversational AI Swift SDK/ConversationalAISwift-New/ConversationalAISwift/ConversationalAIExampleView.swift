import SwiftUI
import Combine
import ElevenLabs
import _Concurrency
import SDWebImageSwiftUI
import ImageIO
import UIKit
import SVGKit
import LiveKit

// MARK: - Conversational AI Example View
struct ConversationalAIExampleView: View {
    
    // MARK: - Props from previous screen
    var agent: ObjAgent?
    var userId: String
    var baseUrl: String
    
    init(agent: ObjAgent, userId: String, baseUrl: String) {
        self.agent = agent
        self.userId = userId
        self.baseUrl = baseUrl
    }
    
    // MARK: - State
    //@State private var arrMessages: [Message] = []
    @State private var arrMessages: [ChatMessage] = []
    @State private var isConnected = false
    @State private var isMuted = false
    @State private var agentState: AgentState = .listening
    @State private var connectionStatus = "Disconnected"
    
    //private var cancellables = Set<AnyCancellable>()
    @State private var cancellableStore = CancellableStore()
    @State private var conversation: Conversation?
    
    struct ChatMessage: Identifiable, Equatable {
        let id : String
        let role: String   // "user" or "assistant"
        let content: String
        let timestamp: Date
        
        enum Role: Sendable {
            case user
            case agent
        }
        
        init(id: String, role: String, content: String, timestamp: Date) {
            self.id = id
            self.role = role
            self.content = content
            self.timestamp = timestamp
        }
        
        static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
            return lhs.id == rhs.id && lhs.role == rhs.role && lhs.content == rhs.content
        }
    }
    
    // MARK: - Helpers
    
    
    
    @State private var selectedLang: AgentLang? = nil
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea()
            
            VStack(spacing: 0) {
                languagePicker
                avatarWithRipple
                
                if let tempAgent = agent {
                    Text(tempAgent.name ?? "Agent")
                        .font(.custom("Rubik-Bold", size: 20))
                        .foregroundColor(.white)
                } else {
                    Text("Loading failed")
                        .font(.custom("Rubik-Bold", size: 20))
                        .foregroundColor(.red)
                }
                
                
                Text("Status: \(connectionStatus)")
                    .font(.custom("Rubik-Regular", size: 13))
                    .foregroundColor(self.isConnected ? .green : .gray)
                    .padding(.bottom, 10)
                
                
                if self.isConnected {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(agentState == .speaking ? Color.green : Color.gray)
                            .frame(width: 7, height: 7)
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                        Text(agentState == .speaking ? "Speaking" : "Listening")
                            .font(.custom("Rubik-Regular", size: 13))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 5)
                }
                
                HStack(spacing: 0) {
                    
                    if self.isConnected {
                        AudioButton(isMute: self.isMuted) {
                            self.toggleMute()
                        }
                    }
                    
                    CallButton(conv: conversation) {
                        if isConnected {
                            Task { await endConversation() }
                        }
                        else {
                            arrMessages.removeAll()
                            Task { await startConversation() }
                        }
                    }
                }
                .padding(.bottom, 5)
                
                communicationLog
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: {
                    print("Back button press...")
                    if let vc = getHostingController() {
                        vc.navigationController?.popViewController(animated: true)
                    }
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 40, height: 40)
                        .shadow(radius: 5)
                        .overlay(Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .scaledToFit())
                        .tint(Color.black.opacity(0.3))
                }
                .disabled(self.isConnected)
                .opacity(self.isConnected ? 0.4 : 1.0)
                
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background(Color.clear)
        }
    }
    
    // MARK: - Conversation lifecycle
    private func startConversation() async {
        // Pick language (fall back to English)
        let langCode = (selectedLang?.languageCode ?? "en").lowercased()
        
        let agentOverrides = AgentOverrides(language: Language(rawValue: langCode))
        
        do {
            conversation = try await ElevenLabs.startConversation(
                agentId: agent?.agentID ?? "",
                config: ConversationConfig(agentOverrides: agentOverrides, userId: userId)
            )
            setupObservers()
        } catch {
            print("❌ Failed to start conversation: \(error)")
            connectionStatus = "Failed to connect"
        }
    }
    
    private func endConversation() async {
        await conversation?.endConversation()
    }
    
    private func toggleMute() {
        Task {
            do {
                try await conversation?.toggleMute()
            }
            catch {
                print("❌ Failed to toggle mute: \(error)")
            }
        }
    }
    
    // MARK: - Observers
    //private func setupObservers(_ conv: Conversation) {
    private func setupObservers() {
        conversation?.$messages
            .receive(on: RunLoop.main)
            .sink { msgs in
                //arrMessages = msgs
                print("message received: \(msgs)")
                if let last = msgs.last {
                    self.loadMessages(msg: last)
                }
            }
            .store(in: &cancellableStore.set)
        
        conversation?.$state
            .receive(on: RunLoop.main)
            .sink { state in
                switch state {
                case .idle:
                    self.connectionStatus = "Disconnected"
                    self.isConnected = false
                    print("Connection state: idle >>>>>>>> \(self.connectionStatus) >>>> isConnected: \(self.isConnected) ")
                case .connecting:
                    self.connectionStatus = "Connecting..."
                    self.isConnected = false
                    print("Connection state: idle >>>>>>>> \(self.connectionStatus) >>>> isConnected: \(self.isConnected) ")
                case .active:
                    self.connectionStatus = "Connected"
                    self.isConnected = true
                    print("Connection state: idle >>>>>>>> \(self.connectionStatus) >>>> isConnected: \(self.isConnected) ")
                case .ended:
                    // 👇 ignore — do nothing
                    self.connectionStatus = "Disconnected"
                    self.isConnected = false
                    self.isMuted = false
                    print("Connection state: ended >>>>>>>> \(self.connectionStatus) >>>> isConnected: \(self.isConnected) ")
                    //cancellableStore.set.removeAll()
                    //conversation = nil
                case .error:
                    self.connectionStatus = "Error"
                    self.isConnected = false
                    print("Connection state: idle >>>>>>>> \(self.connectionStatus) >>>> isConnected: \(self.isConnected) ")
                    break
                }
            }
            .store(in: &cancellableStore.set)
        
        conversation?.$isMuted
            .receive(on: RunLoop.main)
            .sink { muted in
                self.isMuted = muted
            }
            .store(in: &cancellableStore.set)
        
        conversation?.$agentState
            .receive(on: RunLoop.main)
            .sink { state in
                self.agentState = state
            }
            .store(in: &cancellableStore.set)
    }
    
    
    // MARK: - Background
    private var backgroundView: some View {
        AnyView(
            Group {
                if let url = URL(string: agent?.imagePath ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .blur(radius: 10)
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
    
    // Simple & safe version
    private var languagePicker: some View {
        Group {
            Picker(selection: $selectedLang) {
                ForEach(agent?.agentLang ?? [], id: \.id) { lang in
                    HStack {
                        // ... your flag + text ...
                        langFlagImage(lang.langFlagImage ?? "")
                            .clipShape(Circle())
                        Text("   \(lang.langName ?? "Unknown")")
                            .font(.custom("Rubik-Regular", size: 13))
                            .foregroundColor(.white)
                    }
                    .tag(lang as AgentLang?)
                }
            } label: {
                HStack(spacing: 8) {
                    langFlagImage(selectedLang?.langFlagImage ?? "")
                        .clipShape(Circle())
                    Text("   \(selectedLang?.langName ?? "Select Language")")
                        .font(.custom("Rubik-Regular", size: 13))
                        .foregroundColor(isConnected ? .black : .black)
                        .padding(.leading, 8)
                }
                .padding(8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }
            //.tint(Color.white)
            .foregroundStyle(self.isConnected ? Color.gray : Color.white)
            .tint(self.isConnected ? Color.gray : Color.white)
            .pickerStyle(.menu)
            .allowsHitTesting(!(self.isConnected))
            .onAppear {
                if selectedLang == nil { selectedLang = agent?.agentLang?.first }
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    // MARK: - Default image for flag
    private func langFlagImage(_ urlString: String?) -> some View {
        let size: CGFloat = 24

        return Group {
            if let s = urlString,
                let url = URL(string: s),
                s.lowercased().hasSuffix(".svg")
            {
                SVGImageView(urlString: urlString, size: size)
            }
            else if let s = urlString, let url = URL(string: s) {
                // your original raster flow
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: size, height: size)
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                            .clipped()
                    case .failure:
                        defaultFlagImage
                    @unknown default:
                        defaultFlagImage
                    }
                }
            }
            else {
                defaultFlagImage
            }
        }
        .clipShape(Circle())
        .clipped()
        .frame(width: size, height: size)
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
    
    // MARK: - Avatar with Ripple
    private var avatarWithRipple: some View {
        ZStack {
            RippleBackground(status: connectionStatus)
                .frame(width: 300, height: 300)
            
            if let url = URL(string: agent?.imagePath ?? "") {
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
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(arrMessages) { msg in
                        MessageRow(msg: msg, agentName: agent?.name)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(maxWidth: UIScreen.main.bounds.width)
            }
            .background(arrMessages.isEmpty ? Color.clear : Color.black.opacity(0.1))
            .cornerRadius(12)
            .clipped()
            .onChange(of: arrMessages) { _ in
                if let lastID = arrMessages.last?.id {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    struct MessageRow: View {
        let msg: ChatMessage
        let agentName: String?

        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(msg.role == "user" ? "Me :" : "\(agentName ?? "") :")
                        .font(.custom("Rubik-Bold", size: 14))
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .foregroundColor(msg.role == "user" ? .red : .blue)

                    Text(msg.content.isEmpty ? " " : msg.content)
                        .font(.custom("Rubik-Italic", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 3)
                        .padding(1)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
            .id(msg.id)
        }
    }
    
    func loadMessages(msg: Message) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
            self.arrMessages.append(ChatMessage.init(id: msg.id, role: (msg.role == .user ? "user" : "agent"), content: msg.content, timestamp: msg.timestamp))
        }
    }
    
    
}


// MARK: - Preview
struct ConvAIExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationalAIExampleView(agent: ObjAgent(), userId: "123", baseUrl: "Test Url")
        //ConversationalAIExampleView()
    }
}

// MARK: - Load SVG image from url
struct SVGImageView: View {
    let urlString: String?
    let size: CGFloat
    
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())       // makes it circular
                    .contentShape(Circle())    // touch shape is circular
            } else {
                ProgressView()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())   // ensures the container is circular
        .contentShape(Circle())    // touch shape is circular
        .clipped()
        .clipped(antialiased: true)
        .onAppear {
            loadSVG()
        }
    }
    
    private func loadSVG() {
        guard let urlString, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }
            if let svgImage = SVGKImage(data: data) {
                svgImage.size = CGSize(width: size, height: size) // important!
                DispatchQueue.main.async {
                    self.uiImage = svgImage.uiImage
                }
            }
        }.resume()
    }
}


// MARK: - Call Button
struct CallButton: View {
    //let connectionStatus: ElevenLabs.Status
    var conv: Conversation?
    //let connectionStatus: conversation?.$state
    let action: () -> Void
    
    private var buttonImg: String {
        switch conv?.state {
        case .connecting:
            return "call"
        case .active:
            return "callEnd"
        case .ended:
            return "call"
        default:
            return "call"
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
    let isMute: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 15)
                //.fill(isMicEnabled ? Color.green : Color.gray)
                .frame(width: 60, height: 60)
                .shadow(radius: 5)
                .overlay(
                    Image(!isMute ? "unmute" : "mute")
                        .resizable() // for asset images
                        .scaledToFit()
                        //.font(.system(size: 24, weight: .medium))
                        //.foregroundColor(.white)
                )
        }
        .tint(.clear)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
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
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgba: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgba) else { return nil }

        let r, g, b, a: Double
        switch hexSanitized.count {
        case 6: // RGB
            r = Double((rgba & 0xFF0000) >> 16) / 255
            g = Double((rgba & 0x00FF00) >> 8) / 255
            b = Double(rgba & 0x0000FF) / 255
            a = 1
        case 8: // ARGB
            a = Double((rgba & 0xFF000000) >> 24) / 255
            r = Double((rgba & 0x00FF0000) >> 16) / 255
            g = Double((rgba & 0x0000FF00) >> 8) / 255
            b = Double(rgba & 0x000000FF) / 255
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}


// MARK: - SwiftUI Wrapper
struct RippleBackground: UIViewRepresentable {
    let status: String?   // 👈 pass status from parent
    
    func makeUIView(context: Context) -> RippleBackgroundView {
        let view = RippleBackgroundView()
//        DispatchQueue.main.async {
//            view.start()
//        }
        return view
    }
    
    func updateUIView(_ uiView: RippleBackgroundView, context: Context) {
        if status == "Connected" || status == "Connecting..." {
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

class CancellableStore {
    var set = Set<AnyCancellable>()
}

 // Helper to access UIViewController
extension View {
    func getHostingController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController?
            .topMostViewController()
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
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
        //self.agentID = "agent_1901k3k9k4a3egv98f017dgsqc68"
        self.agentID = "agent_5301k3zshq6neaxsyrxemxd9k5ch"
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
                id: 1,
                userID: 10680,
                agentID: 1,
                languageCode: "en",
                langFlagImage: "https://storage.googleapis.com/eleven-public-cdn/images/flags/circle-flags/us.svg",
                firstMessage: "",
                voiceID: "iP95p4xoKVk53GoZ742B",
                modelID: "",
                firstMessageTranslation: "",
                createdAt: "2025-08-26T13:36:37.000000Z",
                updatedAt: "2025-08-27T13:31:13.000000Z",
                langName: "English"
            ),
            AgentLang(
                id: 3,
                userID: 10680,
                agentID: 3,
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
