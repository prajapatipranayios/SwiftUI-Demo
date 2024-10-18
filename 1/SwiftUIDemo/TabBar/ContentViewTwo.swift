//
//  ContentViewTwo.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct ContentViewTwo: View {
    
    // MARK: - Property
    
    @State private var selectedTab: TabBarItem = .home
    
    // MARK: - Body
    
    var body: some View {
        TabBarContainer(selection: $selectedTab) {
            ForEach(TabBarItem.allCases) { item in
                item.color
                    .tabBarItem(tab: item, selection: $selectedTab)
            }
        }
    }
}

#Preview {
    ContentViewTwo()
}
