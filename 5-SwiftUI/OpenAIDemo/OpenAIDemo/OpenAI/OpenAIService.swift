//
//  OpenAIService.swift
//  OpenAIDemo
//
//  Created by Auxano on 29/12/25.
//


import Foundation

class OpenAIService {
    
    private let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    func sendPrompt(prompt: String) async throws -> String {
        
        let requestBody = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                Message(role: "system", content: "You are a helpful assistant."),
                Message(role: "user", content: prompt)
            ]
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(OpenAIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decoded.choices.first?.message.content ?? "No response"
    }
    
    func sendStructuredPrompt(prompt: String) async throws -> String {

        let messages = [
            Message(
                role: "system",
                content: """
                You are a fitness exercise data generator.
                Return ONLY valid JSON.
                NEVER remove any key.
                If a value is unknown, return empty string "".
                """
            ),
            Message(role: "user", content: prompt)
        ]

        let requestBody = ChatRequest(
            model: "gpt-4o-mini",
            messages: messages
        )

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(OpenAIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)

        return decoded.choices.first?.message.content ?? ""
    }

}
