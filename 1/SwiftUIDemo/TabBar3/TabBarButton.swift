//
//  TabBarButton.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct TabBarButton: View {
    
    let text: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Text(text)
            .fontWeight(isSelected ? .heavy : .regular)
            .font(.custom("Avenir", size: 16))
            .padding(.bottom,10)
            .border(width: isSelected ? 2 : 1, edges: [.bottom], color: .black)
    }
}

#Preview {
    TabBarButton(text: "", isSelected: .constant(true))
}
