//
//  HomeView.swift
//  GEClone-UI
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct HomeView: View {
    //@AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    @State private var isSideBarOpened = false
    @State private var showMenu = false
    
    // Example data for the grid
    let items = Array(1...50)
    
    // Define grid columns layout
    let rows = [
        GridItem(.fixed(50)),
        GridItem(.fixed(50))
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main home content
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: rows, alignment: .center) {
                            ForEach(items, id: \.self) { item in
                                Image(systemName: "\(item).circle.fill")
                                    .font(.largeTitle)
                            }
                        }
                        .padding()
                        
                        Button(action: logout) {
                            Text("Logout")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                .navigationBarTitle("Home", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    withAnimation {
                        showMenu.toggle()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .imageScale(.large)
                })
                
                // Side menu
                if showMenu {
                    GeometryReader { _ in
                        EmptyView()
                    }
                    .background(Color.black.opacity(0.5))
                    .onTapGesture {
                        withAnimation {
                            showMenu = false
                        }
                    }
                    
                    //SideMenuView()
                    SideMenuView(isSidebarVisible: $showMenu)
                        //.frame(width: UIScreen.main.bounds.size.width * 0.7)
                        //.transition(.move(edge: .leading))
                }
            }
        }
    }
    
    func logout() {
        // Logic for logging out
        let loginManager = LoginManager()
        loginManager.isLoggedIn = false
    }
}

#Preview {
    HomeView()
}
