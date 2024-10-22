//
//  TestPage.swift
//  GEClone-UI
//
//  Created by Auxano on 22/10/24.
//

import SwiftUI

struct TestPage: View {
    
    @State private var paddingCount: Int = 0
    
    let columns = [
        GridItem(.adaptive(minimum: (UIScreen.main.bounds.width - 60) / 2))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    
                    
                }
            }
        }
    }
}

#Preview {
    TestPage()
}
