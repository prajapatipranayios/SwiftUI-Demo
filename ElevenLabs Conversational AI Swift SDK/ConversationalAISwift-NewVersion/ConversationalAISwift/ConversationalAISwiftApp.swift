import SwiftUI

@main
struct ConversationalAISwiftApp: App {
    
    var body: some Scene {
        WindowGroup {
            ConversationalAIExampleView(
                agent: ObjAgent(),
                userId: "12345",
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
            )
        }
    }
}
