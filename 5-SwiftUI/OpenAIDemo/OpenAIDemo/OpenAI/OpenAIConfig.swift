//
//  OpenAIConfig.swift
//  OpenAIDemo
//
//  Created by Auxano on 29/12/25.
//


struct OpenAIConfig {
    static let apiKey = "YOUR_API_KEY"
}


struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
}

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
}

struct ChatResponse: Codable {
    struct Choice: Codable {
        struct MessageContent: Codable {
            let content: String
        }
        let message: MessageContent
    }
    let choices: [Choice]
}


struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}
