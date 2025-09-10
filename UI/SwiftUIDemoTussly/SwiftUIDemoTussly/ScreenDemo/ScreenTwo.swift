//
//  ScreenTwo.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 09/04/24.
//

import SwiftUI

struct ScreenTwo: View {
    
    @EnvironmentObject var router: TabRouter
    
    var body: some View {
        ZStack {
            VStack {
                Text("Screen 2")
                    .bold()
                    .foregroundColor(.white)
                
                Button {
                    router.change(to: .one)
                } label: {
                    Text("Switch to screen 1")
                }
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .background(.pink)
        .clipped()
    }
}

#Preview {
    ScreenTwo()
        .environmentObject(TabRouter())
}
