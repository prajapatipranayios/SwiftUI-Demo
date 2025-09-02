//
//  ConversationView.swift
//  ConversationalAISwift
//
//  Created by Auxano on 01/09/25.
//


import SwiftUI
import ElevenLabs
import Combine
import LiveKit

struct ConversationView: View {
    @StateObject private var viewModel = ConversationViewModel()

    var agent : ObjAgent?
    var userId: String
    var baseUrl: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status
            Text(viewModel.connectionStatus)
                .font(.headline)
                .foregroundColor(viewModel.isConnected ? .green : .red)

            // Chat messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        MessageBubble(message: message)
                    }
                }
            }
            .frame(maxHeight: 400)

            // Controls
            HStack(spacing: 16) {
                Button(viewModel.isConnected ? "End" : "Start") {
                    Task {
                        if viewModel.isConnected {
                            await viewModel.endConversation()
                        } else {
                            await viewModel.startConversation()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button(viewModel.isMuted ? "Unmute" : "Mute") {
                    Task { await viewModel.toggleMute() }
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.isConnected)

                Button("Send Message") {
                    Task { await viewModel.sendTestMessage() }
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.isConnected)
            }

            // Agent state indicator
            if viewModel.isConnected {
                HStack {
                    Circle()
                        .fill(viewModel.agentState == .speaking ? .blue : .gray)
                        .frame(width: 10, height: 10)
                    Text(viewModel.agentState == .speaking ? "Agent speaking" : "Agent listening")
                        .font(.caption)
                }
            }
        }
        .padding()
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }

            VStack(alignment: .leading) {
                Text(message.role == .user ? "You" : "Agent")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.content)
                    .padding()
                    .background(message.role == .user ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(12)
            }

            if message.role == .agent { Spacer() }
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
    
    private var conversation: Conversation?
    private var cancellables = Set<AnyCancellable>()

    func startConversation() async {
        do {
            conversation = try await ElevenLabs.startConversation(
                agentId: "agent_5301k3zshq6neaxsyrxemxd9k5ch",
                config: ConversationConfig()
            )
            setupObservers()
        } catch {
            print("Failed to start conversation: \(error)")
            connectionStatus = "Failed to connect"
        }
    }

    func endConversation() async {
        await conversation?.endConversation()
        conversation = nil
        cancellables.removeAll()
    }

    func toggleMute() async {
        try? await conversation?.toggleMute()
    }

    func sendTestMessage() async {
        try? await conversation?.sendMessage("Hello from the app!")
    }

    private func setupObservers() {
        guard let conversation else { return }

        conversation.$messages
            .assign(to: &$messages)

        conversation.$state
            .map { state in
                switch state {
                case .idle: return "Disconnected"
                case .connecting: return "Connecting..."
                case .active: return "Connected"
                case .ended: return "Ended"
                case .error: return "Error"
                }
            }
            .assign(to: &$connectionStatus)

        conversation.$state
            .map { $0.isActive }
            .assign(to: &$isConnected)

        conversation.$isMuted
            .assign(to: &$isMuted)

        conversation.$agentState
            .assign(to: &$agentState)
    }
}


// MARK: - Welcome
//struct ObjAgent: Codable, Identifiable {
//    var id: Int?
//    var userID: Int?
//    var name: String?
//    var role: String?
//    var image: String?
//    var agentID: String?
//    var defaultLanguage: String?
//    var langFlagImage: String?
//    var langName: String?
//    var firstMessage: String?
//    var systemPrompt: String?
//    var isExternalKnowledge: Int?
//    var voiceID: String?
//    var duration: Int?
//    var noOfLanguages: Int?
//    var isActive: Int?
//    var createdAt: String?
//    var updatedAt: String?
//    var imagePath: String?
//    var agentLang: [AgentLang]?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userID = "userId"
//        case name, role, image
//        case agentID = "agentId"
//        case defaultLanguage, langFlagImage, langName, firstMessage, systemPrompt, isExternalKnowledge
//        case voiceID = "voiceId"
//        case duration, noOfLanguages, isActive
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case imagePath
//        case agentLang = "agent_lang"
//    }
//    
//    // ✅ Empty initializer
//    init() {
//        self.id = 0
//        self.userID = 0
//        self.name = "Darrell Steward"
//        self.role = ""
//        self.image = ""
//        //self.agentID = "agent_1901k3k9k4a3egv98f017dgsqc68"
//        self.agentID = "agent_5301k3zshq6neaxsyrxemxd9k5ch"
//        self.defaultLanguage = ""
//        self.langFlagImage = ""
//        self.langName = ""
//        self.firstMessage = ""
//        self.systemPrompt = ""
//        self.isExternalKnowledge = 0
//        self.voiceID = ""
//        self.duration = 0
//        self.noOfLanguages = 0
//        self.isActive = 0
//        self.createdAt = ""
//        self.updatedAt = ""
//        self.imagePath = "https://cdn.growy.app/agents/second.png"
//        self.agentLang = [
//            AgentLang(
//                id: 3,
//                userID: 10680,
//                agentID: 2,
//                languageCode: "hi",
//                langFlagImage: "https://storage.googleapis.com/eleven-public-cdn/images/flags/circle-flags/in.svg",
//                firstMessage: "",
//                voiceID: "iP95p4xoKVk53GoZ742B",
//                modelID: "",
//                firstMessageTranslation: "",
//                createdAt: "2025-08-26T13:36:37.000000Z",
//                updatedAt: "2025-08-27T13:31:13.000000Z",
//                langName: "Hindi"
//            ),
//            AgentLang(
//                id: 2,
//                userID: 10680,
//                agentID: 2,
//                languageCode: "it",
//                langFlagImage: "https://storage.googleapis.com/eleven-public-cdn/images/flags/circle-flags/it.svg",
//                firstMessage: "",
//                voiceID: "iP95p4xoKVk53GoZ742B",
//                modelID: "",
//                firstMessageTranslation: "",
//                createdAt: "2025-08-26T13:36:37.000000Z",
//                updatedAt: "2025-08-27T13:31:14.000000Z",
//                langName: "Italian"
//            )]
//    }
//}

// MARK: - AgentLang
//struct AgentLang: Codable, Identifiable, Hashable {
//    var id: Int?
//    var userID: Int?
//    var agentID: Int?
//    var languageCode: String?
//    var langFlagImage: String?
//    var firstMessage: String?
//    var voiceID: String?
//    var modelID: String?
//    var firstMessageTranslation: String?
//    var createdAt: String?
//    var updatedAt: String?
//    var langName: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case userID = "userId"
//        case agentID = "agentId"
//        case languageCode, langFlagImage, firstMessage
//        case voiceID = "voiceId"
//        case modelID = "modelId"
//        case firstMessageTranslation
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
//        case langName
//    }
//}
