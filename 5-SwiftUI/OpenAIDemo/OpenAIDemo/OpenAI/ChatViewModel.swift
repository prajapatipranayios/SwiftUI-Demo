//
//  ChatViewModel.swift
//  OpenAIDemo
//
//  Created by Auxano on 29/12/25.
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    
    @Published var prompt: String = ""
    @Published var response: String = ""
    @Published var isLoading = false
    
    private let service = OpenAIService()
    
    func send() {
        guard !prompt.isEmpty else { return }
        
        isLoading = true
        response = ""
        
        Task {
            do {
                let result = try await service.sendPrompt(prompt: prompt)
                response = result
            } catch {
                response = "Error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    func sendStructuredPrompt(prompt: String) async throws -> String {
        isLoading = true
        defer { isLoading = false } // ensure loading stops even if error occurs

        do {
            let result = try await service.sendStructuredPrompt(prompt: prompt)
            self.response = result
            return result
        } catch {
            self.response = "Error: \(error.localizedDescription)"
            throw error
        }
    }

}
