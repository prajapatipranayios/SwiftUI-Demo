//
//  ContentView4.swift
//  SwiftUIDemo
//
//  Created by Auxano on 11/04/24.
//

import SwiftUI

struct ContentView4: View {
    var body: some View {
        TabView {
//            NavigationStack {
//                //HomeView()
//                FirstView()
//                    .navigationTitle("Home")
//            }
//            .tabItem {
//                Label("Tab 1", systemImage: "1.circle")
//            }
            
            Text("First View")
                .tabItem {
                    Label("First", systemImage: "1.circle")
                }
            
            Text("Second View")
                .tabItem {
                    Label("Second", systemImage: "2.circle")
                    //Label("Second", image: "img3")
                }
        }
    }
}

#Preview {
    ContentView4()
}
