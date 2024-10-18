//
//  ContentView.swift
//  ExSwiftUI1
//
//  Created by Auxano on 17/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isSideBarOpened = false
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    ForEach(0..<8) { _ in
                        AsyncImage(
                            url: URL(
                                string: "https://picsum.photos/600"
                            )) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 240)
                            } placeholder: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.gray.opacity(0.6))
                                        .frame(height: 240)
                                    ProgressView()
                                }
                            }
                            .aspectRatio(3 / 2, contentMode: .fill)
                            .cornerRadius(12)
                            .padding(.vertical)
                            .shadow(radius: 4)
                    }
                }
                .toolbar {
                    Button {
                        isSideBarOpened.toggle()
                    } label: {
                        Label("Toggle SideBar",
                              systemImage: "line.3.horizontal.circle.fill")
                    }
                }
                .listStyle(.inset)
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
            }
            //Sidebar(isSidebarVisible: $isSideBarOpened)
            SideMenu(isSidebarVisible: $isSideBarOpened)
        }
    }
}

#Preview {
    ContentView()
}
