//
//  GEClone_UIApp.swift
//  GEClone-UI
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

@main
struct GEClone_UIApp: App {
    
    @StateObject private var loginManager = LoginManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginManager) // Provide login state globally
        }
    }
}
