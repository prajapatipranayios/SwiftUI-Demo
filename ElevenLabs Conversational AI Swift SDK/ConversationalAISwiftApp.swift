import SwiftUI

//@main
struct ConversationalAISwiftApp: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ConversationalAIExampleView(
                agent: ObjAgent(),
                userId: "123",
                baseUrl: "https://api.example.com",
                callEndPopupTime: "30",
                apiCallTime: "300",
                authToken: "authToken",
                popupInfo: PopupInfo(
                    alertPopUpTitle: "Credit Limit Exceeded",
                    alertPopUpMessage: "You can't access this feature because your credit limit has been exceeded.",
                    infoPopUpTitle: "Information",
                    infoPopUpMessage: "Your call will end soon if credits run out."
                )
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
