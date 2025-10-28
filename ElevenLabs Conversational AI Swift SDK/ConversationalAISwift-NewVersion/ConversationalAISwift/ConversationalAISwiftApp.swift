
//
//  ConversationView.swift
//  ConversationalAISwift
//
//  Created by Auxano on 03/09/25.
//


import SwiftUI
import FirebaseCore

@main
struct ConversationalAISwiftApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
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
