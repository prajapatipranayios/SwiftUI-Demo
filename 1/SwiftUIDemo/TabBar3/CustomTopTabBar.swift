//
//  CustomTopTabBar.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct CustomTopTabBar: View {
    
    @Binding var tabIndex: Int
    
    var body: some View {
        HStack(spacing: 20) {
            TabBarButton(text: "FirstView", isSelected: .constant(tabIndex == 0))
                .onTapGesture { onButtonTapped(index: 0) }
            TabBarButton(text: "SecondView", isSelected: .constant(tabIndex == 1))
                .onTapGesture { onButtonTapped(index: 1) }
            Spacer()
        }
        .border(width: 1, edges: [.bottom], color: .black)
    }
    
    private func onButtonTapped(index: Int) {
        withAnimation { tabIndex = index }
    }
}

#Preview {
    CustomTopTabBar(tabIndex: .constant(0))
}
