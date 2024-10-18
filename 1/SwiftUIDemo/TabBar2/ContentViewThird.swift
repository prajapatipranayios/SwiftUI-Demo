//
//  ContentViewThird.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct ContentViewThird: View {
    
    @State var selectedTab = 0
    
    var body: some View {
        VStack {
            TabView(selection:$selectedTab) {
                NavigationView {
                    VStack {
                        Text("Page One")
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 250, height: 250)
                    }
                }
                .tabItem({
                    Image(systemName: "calendar")
                })
                .tag(0)
                
                VStack {
                    Text("Page Two")
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 250, height: 250)
                }
                .tabItem({
                    Image(systemName: "house.fill")
                })
                .tag(1)
                
                VStack {
                    Text("Page Three")
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 250, height: 250)
                }
                .tabItem({
                    Image(systemName: "list.dash")
                })
                .tag(2)
            }
            .onAppear() {
                let standardAppearance = UITabBarAppearance()
                standardAppearance.backgroundColor = UIColor(Color.gray)
                standardAppearance.shadowColor = UIColor(Color.pink)
                //standardAppearance.backgroundImage = UIImage(named: "custom_bg")
                
                let itemAppearance = UITabBarItemAppearance()
                itemAppearance.normal.iconColor = UIColor(Color.gray)
                itemAppearance.selected.iconColor = UIColor(Color.init(hex: "#8A0702"))
                
                standardAppearance.inlineLayoutAppearance = itemAppearance
                standardAppearance.stackedLayoutAppearance = itemAppearance
                standardAppearance.compactInlineLayoutAppearance = itemAppearance
                UITabBar.appearance().standardAppearance = standardAppearance
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ContentViewThird()
}
