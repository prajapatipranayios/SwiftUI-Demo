import SwiftUI

@main
struct ConversationalAISwiftApp: App {
    var body: some Scene {
        WindowGroup {
//            ConversationalAIExampleView(
//                agent: ObjAgent(),                 // or your decoded agent
//                userId: "123",                     // supply actual userId
//                baseUrl: "https://api.example.com" // supply your URL
//            )
            
            ConversationView(agent: ObjAgent(), userId: "123", baseUrl: "baseUrl")
        }
    }
}
