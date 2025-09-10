//
//  BottomTabView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 09/04/24.
//

import SwiftUI

struct BottomTabView: View {
    var body: some View {
        HStack {
            VStack {
                Button {
                    print("Button Tussly Tap.")
                } label: {
                    Image("Home")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
                Text("Home")
            }
            .padding([.leading, .trailing], 1)
            
            Spacer()
            
            VStack {
                Button {
                    print("Button Tournament Tap.")
                } label: {
                    Image("Schedule")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
                Text("Schedule")
            }
            
            Spacer()
            
            VStack {
                Button {
                    print("Button Tournament Tap.")
                } label: {
                    Image("Chat")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
                Text("Chat")
            }
            
            Spacer()
            
            VStack {
                Button {
                    print("Button Tournament Tap.")
                } label: {
                    Image("Notifications")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
                Text("Notifications")
            }
            
            Spacer()
            
            VStack {
                Button {
                    print("Button Tournament Tap.")
                } label: {
                    Image("More")
                        .resizable()
                        .frame(width: 35, height: 30)
                }
                Text("More")
            }
            
        }
        .padding([.leading, .trailing, .top], 10)
    }
}

#Preview {
    BottomTabView()
}


//        TabView {
//            InitialViewCard()
//                .tabItem {
//                    Text("Home")
//                    Image("Home")
//                }.tag(0)
//
//            InitialViewCard()
//                .tabItem {
//                    Text("Schedule")
//                    Image("Schedule")
//                }.tag(1)
//
//            InitialViewCard()
//                .tabItem {
//                    Text("Chat")
//                    Image("Chat")
//                }.tag(2)
//
//            InitialViewCard()
//                .tabItem {
//                    Text("Notifications")
//                    Image("Notifications")
//                }.tag(3)
//
//            InitialViewCard()
//                .tabItem {
//                    Text("More")
//                    Image("More")
//                }.tag(4)
//        }.accentColor(.red)
