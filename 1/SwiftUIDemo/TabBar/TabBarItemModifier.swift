//
//  TabBarItemsPreferenceKey.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

// MARK: - Tab Bar Items PreferenceKey

struct TabBarItemsPreferenceKey: PreferenceKey {
    
    static var defaultValue: [TabBarItem] = []
    
    static func reduce(value: inout [TabBarItem], nextValue: () -> [TabBarItem]) {
        value += nextValue()
    }
}

// MARK: - ViewModifier

struct TabBarItemModifier: ViewModifier {
    let tab: TabBarItem
    @Binding var selection: TabBarItem
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1.0 : 0.0)
            .preference(key: TabBarItemsPreferenceKey.self, value: [tab])
    }
}

// MARK: - Extension

extension View {
    func tabBarItem(tab: TabBarItem, selection: Binding<TabBarItem>) -> some View {
        self
            .modifier(TabBarItemModifier(tab: tab, selection: selection))
    }
}
