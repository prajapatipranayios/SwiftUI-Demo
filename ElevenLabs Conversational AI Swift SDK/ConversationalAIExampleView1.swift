//
//  ConversationView.swift
//  ConversationalAISwift
//
//  Created by Auxano on 03/09/25.
//


import SwiftUI
import ElevenLabs
import Combine
import LiveKit
import SVGKit
import FirebaseFirestore

struct ConversationalAIExampleView: View {
    
    var agent: ObjAgent?
    var userId: String
    var baseUrl: String
    var callEndPopupTime: String
    var apiCallTime: String
    var authToken: String
    
    @StateObject private var objViewModel = ConversationViewModel()
    
    @State private var isBtnTap: Bool = true
    
    struct ChatMessage: Identifiable, Equatable {
        let id = UUID()
        let role: String   // "user" or "assistant"
        let text: String
        
        static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
            return lhs.id == rhs.id && lhs.role == rhs.role && lhs.text == rhs.text
        }
    }
    @State private var chatMessages: [ChatMessage] = []
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    
    @State private var listener: ListenerRegistration? = nil
    @State private var totalCallSecond: Int = 0
    @State private var showPopup: Bool = false
    @State private var popupMessage: String = ""
    @State private var apiCallTimer: Timer? = nil
    @State private var tempApiCallRemainingSeconds: Int = 0
    @State private var callEndTask: Task<Void, Never>? = nil
    
    
    init(agent: ObjAgent?, userId: String, baseUrl: String, callEndPopupTime: String, apiCallTime: String, authToken: String) {
        self.agent = agent
        self.userId = userId
        self.baseUrl = baseUrl
        self.callEndPopupTime = callEndPopupTime
        self.apiCallTime = apiCallTime
        self.authToken = authToken
    }
    
    var body: some View {
        ZStack {
            // 1) Background only ignores safe area
            backgroundView
                .ignoresSafeArea()
            
            // 2) Main content fills the screen and stays inside safe area
            VStack(spacing: 0) {
                languagePicker
                avatarWithRipple
                agentHeader
                agentStateIndicator
                controls
                // 3) CHAT LOG: expands to fill remaining space
                communicationLog
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 20)
            // Ensure the VStack itself is allowed to fill the screen
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
        }
        // 🔹 Popup overlay here (always on top of ZStack)
        .overlay(
            Group {
                if showPopup {
                    ZStack {
                        // Dimmed background
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            // Title
                            Text("Alert!") // replace with dynamic title if needed
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            // Message
                            Text(popupMessage)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                            
                            // OK Button
                            Button(action: {
                                showPopup = false
                            }) {
                                Text("OK")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 16) // left-right padding
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                        .frame(maxWidth: 300)
                    }
                }
            }
        )
        // 4) BACK BUTTON: safe and always tappable; sits above content
        .safeAreaInset(edge: .top) {
            HStack {
                Button(action: {
                    print("Back button press...")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 40, height: 40)
                        .shadow(radius: 5)
                        .overlay(Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .scaledToFit())
                        .tint(Color.black.opacity(0.3))
                }
                .disabled(objViewModel.isConnected)
                .opacity(objViewModel.isConnected ? 0.4 : 1.0)
                .allowsHitTesting(self.isBtnTap)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8) // small offset below the status bar
            .background(Color.clear)
        }
        .onDisappear {
            self.listener?.remove()
            
            NotificationCenter.default.removeObserver(self)
            AppUtility.lockOrientation(.all) // restore others
        }
        .onAppear(perform: {
            AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
            objViewModel.agent = agent
            objViewModel.userId = userId
            
            self.setupFirebaseListener(userId: "\(agent?.userID ?? 0)")
            
            NotificationCenter.default.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                print("App moved to background")
                Task {
                    await self.endConnection()
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { _ in
                print("App moved to foreground")
                self.isBtnTap = true
            }
        })
        .onChange(of: objViewModel.connectionStatus) { oldValue, newValue in
            
            if self.isBtnTap {
                Task {
                    await self.endConnection(isAutoDisconnect: true)
                }
                print("On Button tap >>>>>> false")
            }
            
            switch newValue {
            case "Disconnected", "Connected":
                isBtnTap = true
            case "Connecting...", "Disconnecting":
                isBtnTap = false
            default:
                isBtnTap = false
            }
            
            if newValue == "Connected" {
                objViewModel.startTimer(seconds: Int(apiCallTime) ?? 0) { remainSecond in
                //objViewModel.startTimer(seconds: 10) { remainSecond in
                    tempApiCallRemainingSeconds = remainSecond
                    print("remainSecond >>>>>>>>> \(remainSecond)")
                } onComplete: {
                    //Task { await self.endConnection() }
                    APIService.shared.sendRequest(
                        urlString: "\(baseUrl)agent/wallet-second-decrease",
                        method: .post,
                        body: ["second": self.apiCallTime],
                        //body: ["second": "10"],
                        token: authToken
                    ) { result in
                        switch result {
                        case .success(let response):
                            print("✅ POST Response:", response)
                        case .failure(let error):
                            print("❌ wallet-second-decrease Error:", error.localizedDescription)
                        }
                    }
                }
            } else if newValue == "Disconnected" {
                objViewModel.stopTimer()
            }
        }
        .onChange(of: objViewModel.messages.count) { oldValue, newValue in
            if let last = objViewModel.messages.last {
                let newChatMessage = ChatMessage(
                    role: last.role == .user ? "user" : "assistant",
                    text: last.content
                )
                if chatMessages.last != newChatMessage {
                    chatMessages.append(newChatMessage)
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                print("App moved to foreground")
                
                self.isBtnTap = true
            case .background:
                print("App moved to background")
                Task {
                    await self.endConnection()
                }
            case .inactive:
                print("App inactive (transitioning)")
            @unknown default:
                break
            }
        }
        .onChange(of: totalCallSecond) { oldValue, newValue in
            if newValue <= 0 {
                if objViewModel.connectionStatus == "Disconnected" {
                    print("Time is over and disconnected...")
                    //self.showPopupMessage("Your can't access this feature because your credit limit has been exceeded.")
                }
                else if objViewModel.connectionStatus == "Connected" {
                    self.showPopupMessage("Your call will automatically end in \(callEndPopupTime) seconds as your credit limit has been exceeded.")
                    
                    callEndTask?.cancel() // cancel any previous one before starting new
                    
                    if let seconds = UInt64(callEndPopupTime) {
                        callEndTask = Task {
                            do {
                                try await Task.sleep(nanoseconds: seconds * 1_000_000_000)
                                try Task.checkCancellation()
                                await MainActor.run {
                                    self.showPopupMessage(nil)
                                }
                                await self.endConnection()
                            } catch {
                                print("⏹ Call end task was cancelled")
                            }
                        }
                    } else {
                        print("⚠️ callEndPopupTime is not a valid number: \(callEndPopupTime)")
                    }
                }
            }
            
        }
        
    }
    
    func endConnection(isAutoDisconnect: Bool = false) async {
        callEndTask?.cancel()
        callEndTask = nil
        
        APIService.shared.sendRequest(
            urlString: "\(baseUrl)agent/create-conversations",
            method: .post,
            body: ["conversationId": objViewModel.getConversationID()]
        ) { result in
            switch result {
            case .success(let response):
                print("✅ POST Response:", response)
            case .failure(let error):
                print("❌ create-conversations Error:", error.localizedDescription)
            }
        }
        
        APIService.shared.sendRequest(
            urlString: "\(baseUrl)agent/wallet-second-decrease",
            method: .post,
            body: ["second": "\((Int(self.apiCallTime) ?? 0) - tempApiCallRemainingSeconds)"],
            //body: ["second": "10"],
            token: authToken
        ) { result in
            switch result {
            case .success(let response):
                print("✅ POST Response:", response)
            case .failure(let error):
                print("❌ wallet-second-decrease Error:", error.localizedDescription)
            }
        }
        
        if !isAutoDisconnect {
            await objViewModel.endConversation()
        }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        AnyView(
            Group {
                if let url = URL(string: agent?.imagePath ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            //ProgressView()
                            defaultUserImage
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .ignoresSafeArea()
                                .blur(radius: 10)
                                .overlay(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "AA3789FF") ?? .black,
                                            Color(hex: "AA051A37") ?? .black
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
    
    // MARK: - AgentHeader
    private var agentHeader: some View {
        VStack(spacing: 4) {
            Text(agent?.name ?? "Loading failed")
                .font(.custom("Rubik-Bold", size: 20))
                .foregroundColor(agent == nil ? .red : .white)

            Text("Status: \(objViewModel.connectionStatus)")
                .font(.custom("Rubik-Regular", size: 13))
                .foregroundColor(statusColor)
                .padding(.bottom, 10)
        }
    }
    private var statusColor: Color {
        switch objViewModel.connectionStatus {
        case "Connected":
            return .green
        case "Connecting...":
            return Color(hex: "E1A500") ?? .yellow
        default:
            return .gray
        }
    }
    
    // MARK: - AgentStateIndicator
    private var agentStateIndicator: some View {
        Group {
            if objViewModel.isConnected {
                HStack(spacing: 6) {
                    Circle()
                        .fill(objViewModel.agentState == .speaking ? Color.green : Color.gray)
                        .frame(width: 7, height: 7)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                    
                    Text(objViewModel.agentState == .speaking ? "Speaking" : "Listening")
                        .font(.custom("Rubik-Regular", size: 13))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 5)
            }
        }
    }
    
    // MARK: - Controls
    private var controls: some View {
        HStack(spacing: 0) {
            if objViewModel.isConnected {
                AudioButton(isMicEnabled: objViewModel.isMuted) {
                    Task { await objViewModel.toggleMute() }
                }
                .padding(.trailing, 16)
            }
            
            CallButton(
                connectionStatus: objViewModel.connectionStatus,
                action: {
                    if totalCallSecond <= 0 && objViewModel.connectionStatus == "Disconnected" {
                        self.showPopupMessage("You can't access this feature because your credit limit has been exceeded.")
                    } else {
                        if objViewModel.connectionStatus == "Disconnected" {
                            chatMessages.removeAll()
                        }
                        
                        if self.isBtnTap {
                            self.isBtnTap = false
                            Task {
                                if objViewModel.isConnected {
                                    await self.endConnection()
                                } else {
                                    await objViewModel.startConversation()
                                }
                            }
                        }
                    }
                }
            )
        }
        .padding(.bottom, 5)
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
                            Color(hex: "AA3789FF") ?? .black,
                            Color(hex: "AA051A37") ?? .black
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
        )
    }
    
    // MARK: - Language Picker
    private var languagePicker: some View {
        Group {
            Picker(selection: $objViewModel.selectedLang) {
                ForEach(agent?.agentLang ?? [], id: \.id) { lang in
                    languageRow(lang)
                        .tag(lang as AgentLang?)
                }
            } label: {
                HStack(spacing: 8) {
                    langFlagImage(objViewModel.selectedLang?.langFlagImage ?? "")
                        .clipShape(Circle())
                    Text("   \(objViewModel.selectedLang?.langName ?? "Select Language")")
                        .font(.custom("Rubik-Regular", size: 13))
                        .foregroundColor(.black)
                        .padding(.leading, 8)
                }
                .padding(8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
            }
            .foregroundStyle(objViewModel.isConnected ? .gray : .white)
            .tint(objViewModel.isConnected ? .gray : .white)
            .pickerStyle(.menu)
            .allowsHitTesting(!objViewModel.isConnected)
            .onAppear {
                if objViewModel.selectedLang == nil {
                    objViewModel.selectedLang = agent?.agentLang?.first
                }
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        .frame(width: UIScreen.main.bounds.width)
    }
    
    // Separate subview for a language row
    private func languageRow(_ lang: AgentLang) -> some View {
        HStack {
            langFlagImage(lang.langFlagImage ?? "")
                .clipShape(Circle())
            Text("   \(lang.langName ?? "Unknown")")
                .font(.custom("Rubik-Regular", size: 13))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Default image for flag
    private func langFlagImage(_ urlString: String?) -> some View {
        let size: CGFloat = 24
        
        return Group {
            if let s = urlString,
               let _ = URL(string: s),
               s.lowercased().hasSuffix(".svg")
            {
                SVGImageView(urlString: urlString, size: size)
            }
            else if let s = urlString, let url = URL(string: s) {
                // your original raster flow
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        //ProgressView().frame(width: size, height: size)
                        defaultFlagImage
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
            RippleBackground(status: objViewModel.connectionStatus)
                .frame(width: 300, height: 300)
            
            if let url = URL(string: agent?.imagePath ?? "") {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        //ProgressView().frame(width: 170, height: 170)
                        Image("defaultUser")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 5)
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
                LazyVStack(alignment: .leading) {
                    ForEach(chatMessages) { msg in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(msg.role.lowercased() == "user" ? "Me :" : "\(agent?.name ?? "") :")
                                    .font(
                                        .custom("Rubik-Bold", size: 14)
                                    )
                                    .padding(.horizontal, 1)
                                    .padding(.vertical, 1)
                                    .foregroundColor(msg.role.lowercased() == "user" ? .red : .blue)
                                
                                Text(msg.text.isEmpty ? " " : msg.text)
                                    .font(
                                        .custom("Rubik-Italic", size: 13)
                                    )
                                    .foregroundColor(.white)
                                    .padding(1)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                        .id(msg.id)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .frame(maxWidth: UIScreen.main.bounds.width)
            }
            .background(chatMessages.isEmpty ? Color.clear : Color.black.opacity(0.1))
            .cornerRadius(12)
            .clipped()
            .onChange(of: chatMessages.count) {
                if let lastID = chatMessages.last?.id {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Show popup func
    private func showPopupMessage(_ message: String?) {
        if let message = message {
            popupMessage = message
            showPopup = true
        } else {
            showPopup = false // Passing nil closes popup manually
        }
    }
    
    // MARK: - Firebase Listener
    private func setupFirebaseListener(userId: String) {
        let db = Firestore.firestore()
        
        self.listener = db.collection("agent")
            .document(userId)
            //.collection("\(self.objViewModel.agent?.userID ?? 0)")
            //.order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                guard let document = snapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                
                if let totalSeconds = data["totalSeconds"] as? Int {
                    //self.remainingCallSecond = totalSeconds
                    totalCallSecond = totalSeconds
                    print("Remaining seconds: \(totalSeconds)")
                }
            }
    }
}


@MainActor
class ConversationViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isConnected = false
    @Published var isMuted = false
    @Published var agentState: AgentState = .listening
    @Published var connectionStatus = "Disconnected"
    @Published var selectedLang: AgentLang? = nil
    @Published var strConversationId: String? = ""
    @Published var ongoingTask: Task<Void, Never>? = nil
    
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()
    
    var agent: ObjAgent?
    var userId: String?
    
    @Published var apiCallRemainingSeconds: Int = 0
    private var apiCallTimer: Timer?
    
    
    func startConversation() async {
        ongoingTask?.cancel()  // cancel any previous task
        ongoingTask = Task {
            do {
                try Task.checkCancellation()
                await startConversationSafe()   // ✅ call the safe function
                ongoingTask = nil
                print("Conversation task >>>>> startConversation")
            } catch {
                print("Conversation task cancelled or failed")
            }
        }
    }
    
    func startConversationSafe() async {
        do {
            conversation = nil       // ✅ clear old reference
            cancellables.removeAll() // ✅ clear old bindings

            let langCode = (selectedLang?.languageCode ?? "en").lowercased()
            let agentOverrides = AgentOverrides(language: Language(rawValue: langCode))

            conversation = try await ElevenLabs.startConversation(
                agentId: agent?.agentID ?? "",
                config: ConversationConfig(agentOverrides: agentOverrides,
                                           userId: userId ?? "")
            )
            setupObservers()
        } catch {
            print("Failed to start conversation: \(error)")
            connectionStatus = "Failed to connect"
        }
    }
    
    func endConversation() async {
        ongoingTask?.cancel()
        ongoingTask = Task {
            await endConversationSafe()
            ongoingTask = nil
        }
    }
    
    func endConversationSafe() async {
        await conversation?.endConversation()
        conversation = nil
        cancellables.removeAll()
    }
    
    func toggleMute() async {
        try? await conversation?.toggleMute()
    }
    
    func getConversationID() -> String {
        if let metadata = conversation?.conversationMetadata {
            print("Conversation ID >>>>>>>>>>>> ", metadata.conversationId)
            return metadata.conversationId
        }
        return "NoConvID"
    }
    
    private func setupObservers() {
        cancellables.removeAll()   // ✅ clear old subscriptions
        
        guard let conversation else { return }

        conversation.$messages
            .receive(on: DispatchQueue.main)   // ✅ ensure UI updates on main thread
            .assign(to: &$messages)

        conversation.$state
            .map { state in
                switch state {
                case .idle: return "Disconnected"
                case .connecting: return "Connecting..."
                case .active:
                    if let metadata = conversation.conversationMetadata {
                        self.strConversationId = metadata.conversationId
                    }
                    return "Connected"
                case .ended: return "Disconnected"
                case .error: return "Error"
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionStatus)

        conversation.$state
            .map { $0.isActive }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)

        conversation.$isMuted
            .receive(on: DispatchQueue.main)
            .assign(to: &$isMuted)

        conversation.$agentState
            .receive(on: DispatchQueue.main)
            .assign(to: &$agentState)
    }
    
    func startTimer(seconds: Int, onTick: @escaping (Int) -> Void, onComplete: @escaping () -> Void) {
        stopTimer()
        apiCallRemainingSeconds = seconds
        
        apiCallTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if self.apiCallRemainingSeconds > 0 {
                self.apiCallRemainingSeconds -= 1
                onTick(self.apiCallRemainingSeconds)
            }
            
            if self.apiCallRemainingSeconds == 0 {
                self.stopTimer()
                onComplete()
                self.startTimer(seconds: seconds, onTick: onTick, onComplete: onComplete)
            }
        }
        
        RunLoop.current.add(apiCallTimer!, forMode: .common)
    }
    
    func stopTimer() {
        apiCallTimer?.invalidate()
        apiCallTimer = nil
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
    let connectionStatus: String
    let action: () -> Void
    
    private var buttonImg: String {
        switch connectionStatus {
        case "Connected":
            return "callEnd"
        case "Connecting...":
            return "call"
        case "Disconnecting":
            return "callEnd"
        case "Disconnected":
            return "call"
        default:
            return "call"
        }
    }
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 45, height: 45)
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
                .frame(width: 45, height: 45)
                .shadow(radius: 5)
                .overlay(
                    Image(isMicEnabled ? "mute" : "unmute")
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
    let status: String   // 👈 pass status from parent
    
    func makeUIView(context: Context) -> RippleBackgroundView {
        let view = RippleBackgroundView()
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
    
    private let rippleCount = 3
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
        rippleLayer.lineWidth = 25.0
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
        token: String? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue   // ✅ use enum
        
        // ✅ add Authorization header if token exists
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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

class AppUtility {
 
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
                                andRotateTo rotateOrientation:UIInterfaceOrientation? = nil) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
        
        if let rotateOrientation = rotateOrientation {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }
}

