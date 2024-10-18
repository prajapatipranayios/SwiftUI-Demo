//
//  ContentView2.swift
//  ExSwiftUI1
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct ContentView2: View {
    
    @State private var showMenu = false
    
    var body: some View {
            NavigationView {
                ZStack {
                    HomeView2() // The default view
                        .navigationBarTitle("Home", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        })

                    if showMenu {
                        GeometryReader { _ in
                            EmptyView()
                        }
                        .background(Color.black.opacity(0.5))
                        .onTapGesture {
                            withAnimation {
                                self.showMenu = false
                            }
                        }

                        SideMenuView()
                            .frame(width: 250)
                            .transition(.move(edge: .leading))
                    }
                }
            }
        }
}

#Preview {
    ContentView2()
}
