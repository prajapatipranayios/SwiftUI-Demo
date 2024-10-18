//
//  FirstView.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

struct FirstView: View {
    var body: some View {
        
        ZStack{
            Color.gray
            
            VStack {
                //Rectangle()
                //                .foregroundColor(.orange)
                Text("First View")
                
                //Label("Second View", systemImage: "1.circle")
                //                Button {
                //                    SecondView()
                //                }
                
                Button (action: {
                    NavigationLink("SecondView") {
                        SecondView()
                    }
                }, label: {
                    Text("Second View")
                        .font(.title)
                })
                .frame(width: 200, height: 60)
                .background(Color.primary)
            }
        }
    }
}

#Preview {
    FirstView()
}
