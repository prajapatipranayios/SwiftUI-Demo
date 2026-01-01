import SwiftUI

//@main
struct ConversationalAISwiftApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ConversationalAIExampleView(
                agent: ObjAgent(),                 // or your decoded agent
                userId: "123",                     // supply actual userId
                baseUrl: "https://api.example.com", // supply your URL
                callEndPopupTime: "30",
                apiCallTime: "300"
            ).onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .active:
                    print("App moved to foreground")
                case .background:
                    print("App moved to background")
                case .inactive:
                    print("App inactive")
                @unknown default: break
                }
            }
        }
    }
}
