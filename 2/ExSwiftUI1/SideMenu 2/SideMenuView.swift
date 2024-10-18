//
//  SideMenuView.swift
//  ExSwiftUI1
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: HomeView2()) {
                HStack {
                    Image(systemName: "house")
                    Text("Home")
                        .font(.headline)
                        .padding(.vertical, 10)
                }
                .padding(.leading, 10)
            }
            NavigationLink(destination: SettingsView2()) {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                        .font(.headline)
                        .padding(.vertical, 10)
                }
                .padding(.leading, 10)
            }
            Spacer()
        }
        .padding(.top, 50)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SideMenuView()
}
