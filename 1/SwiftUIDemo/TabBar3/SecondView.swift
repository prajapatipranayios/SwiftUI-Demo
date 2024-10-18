//
//  SecondView.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct SecondView: View {
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.yellow)
            Text("SecondView")
        }
    }
}

#Preview {
    SecondView()
}
