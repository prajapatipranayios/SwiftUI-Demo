//
//  SwiftUIDemoTusslyApp.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 04/03/24.
//

import SwiftUI

enum Screen {
    case one
    case two
}

final class TabRouter: ObservableObject {
    @Published var screen: Screen = .one
    
    func change(to screen: Screen) {
        self.screen = screen
    }
}

@main
struct SwiftUIDemoTusslyApp: App {
    
    @StateObject var router = TabRouter()
    
    var body: some Scene {
        WindowGroup {
//            NavigationView {
//                ContentView()
//                //InitialViewCard()
//            }
            
            TabView(selection: $router.screen) {
                ScreenOne()
                    .tag(Screen.one)
                    .environmentObject(router)
                    .tabItem {
                        Label("Screen 1", systemImage: "calendar")
                    }
                ScreenTwo()
                    .tag(Screen.two)
                    .environmentObject(router)
                    .tabItem {
                        Label("Screen 2", systemImage: "house")
                    }
            }
        }
    }
}
