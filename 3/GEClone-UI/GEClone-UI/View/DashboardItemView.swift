//
//  DashboardItemView.swift
//  GEClone-UI
//
//  Created by Auxano on 21/10/24.
//

import SwiftUI

struct DashboardItemView: View {
    var label: String
    var count: String
    var iconName: String
    let destination: () -> AnyView
    
    var body: some View {
        
        return VStack {
            HStack() {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 0, trailing: 2))
                
                if !count.isEmpty {
                    Text(count)
                        .font(.title)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 1, trailing: 2))
            
            HStack {
                Text(label)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(EdgeInsets(top: 1, leading: 9, bottom: 2, trailing: 2))
        }
        .frame(width: (UIScreen.main.bounds.width - 60)/2, height: 85)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray, radius: 2, x: 0, y: 2)
        .onTapGesture {
            destination()
        }
    }
}

//#Preview {
    //DashboardItemView(label: "Label -1", count: "1", iconName: "Target")
//}
