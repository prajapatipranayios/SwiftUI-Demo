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

//    var agent : ObjAgent?
//    var userId: String
//    var baseUrl: String
    
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
//            .receive(on: RunLoop.main)
            .sink { msgs in
                print("📩 Updated messages: \(msgs)")
            }
            .store(in: &cancellables)
//            .assign(to: &$messages)

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
