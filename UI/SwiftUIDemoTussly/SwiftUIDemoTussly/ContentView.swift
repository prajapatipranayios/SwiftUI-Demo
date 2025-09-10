//
//  ContentView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 04/03/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        Section {
            HeaderView()
            
            Spacer()

            BottomTabView()
        }
    }
}

#Preview {
    ContentView()
}

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}









//            TabView {
//                Text("Home")
//                    .tabItem {
//                        Label("Home", image: "Home")
//                    }
//
//                Text("Schedule")
//                    .tabItem {
//                        Label("Schedule", image: "Schedule")
//                    }
//
//                Text("Chat")
//                    .tabItem {
//                        Label("Chat", image: "Chat")
//                    }
//
//                Text("Notifications")
//                    .tabItem {
//                        Label("Notifications", image: "Notifications")
//                    }
//
//                Text("More")
//                    .tabItem {
//                        Label("More", image: "More")
//                    }
//            }
//            .accentColor(Color(red: 138.0/255.0, green: 7.0/255.0, blue: 2.0/255.0, opacity: 1.0))
