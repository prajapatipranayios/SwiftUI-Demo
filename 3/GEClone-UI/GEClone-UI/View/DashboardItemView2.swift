//
//  DashboardItemView2.swift
//  GEClone-UI
//
//  Created by Auxano on 21/10/24.
//

import SwiftUI

struct DashboardItemView2: View {
    var label: String
    var count: String
    var iconName: String
    let destination: () -> AnyView
    
    var body: some View {
        var strText: String
        if label == "MTP" {
            strText = "Monthly Tour Plan"
        } else if label == "DVR" {
            strText = "Daily Visit Report"
        } else if label == "Expense" {
            strText = "Expense"
        } else {
            strText = ""
        }
        
        return VStack {
            HStack() {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 1, trailing: 2))
                    
                Spacer()
            }
            
            HStack {
                if !count.isEmpty {
                    Text(count)
                        //.font(.title)
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 1, leading: 8, bottom: 0, trailing: 2))
            
            HStack {
                Text(strText)
                    .font(.system(size: 11))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 9, bottom: 4, trailing: 2))
        }
        .frame(width: (UIScreen.main.bounds.width - 70)/3, height: 150)
        //.background(Color.pink.opacity(0.4))
        .cornerRadius(12)
        //.shadow(color: .gray, radius: 1, x: 0, y: 2)
        .onTapGesture {
            destination()
        }
    }
}

//#Preview {
    //DashboardItemView2(label: "Label -1", count: "MTP", iconName: "Target")
//}
