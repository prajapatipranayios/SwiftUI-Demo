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

struct ConversationView: View {
    
    var agent: ObjAgent?
    var userId: String
    var baseUrl: String
    
    @StateObject private var objViewModel = ConversationViewModel()

    init(agent: ObjAgent?, userId: String, baseUrl: String) {
        self.agent = agent
        self.userId = userId
        self.baseUrl = baseUrl
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Connection status
            Text(objViewModel.connectionStatus)
                .font(.headline)
                .foregroundColor(objViewModel.isConnected ? .green : .red)

            // Chat messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(objViewModel.messages, id: \.id) { message in
                        MessageBubble(message: message)
                    }
                }
            }
            .frame(maxHeight: 400)

            // Controls
            HStack(spacing: 16) {
                Button(objViewModel.isConnected ? "End" : "Start") {
                    Task {
                        if objViewModel.isConnected {
                            await objViewModel.endConversation()
                        } else {
                            await objViewModel.startConversation()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button(objViewModel.isMuted ? "Unmute" : "Mute") {
                    Task { await objViewModel.toggleMute() }
                }
                .buttonStyle(.bordered)
                .disabled(!objViewModel.isConnected)

                Button("Send Message") {
                    Task { await objViewModel.sendTestMessage() }
                }
                .buttonStyle(.bordered)
                .disabled(!objViewModel.isConnected)
            }

            // Agent state indicator
            if objViewModel.isConnected {
                HStack {
                    Circle()
                        .fill(objViewModel.agentState == .speaking ? .blue : .gray)
                        .frame(width: 10, height: 10)
                    Text(objViewModel.agentState == .speaking ? "Agent speaking" : "Agent listening")
                        .font(.caption)
                }
            }
        }
        .padding()
        .onAppear {
            objViewModel.agent = self.agent
        }
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

    var agent: ObjAgent?

//    init(agent: ObjAgent? = nil) {  // 👈 optional default
//        self.agent = agent
//    }
    
    func startConversation() async {
        do {
            conversation = try await ElevenLabs.startConversation(
                agentId: agent?.agentID ?? "",
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
