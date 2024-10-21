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
    let items_1 = [
            ("Product History", "2234", "Product-History", "1"),
            ("Business Partner", "11323", "Business-Partner", "1"),
            ("Sales Order", "2456234", "Sales-Order", "1"),
            ("Sample Request", "134534", "Sample-Request", "1"),
            ("Quotations", "123", "Quotations", "1"),
            ("Proforma Invoice", "13632", "Proforma-Invoice", "1"),
            ("Follow Up", "340", "Follow-Up", "1"),
            ("Draft Sales Order", "4430", "Draft-Sales-Order", "1"),
            ("Dashboard", "", "Dashboard", "1"),
            ("Commission", "", "Commission", "1"),
            ("Target", "", "Target", "1"),
            ("Sales Performance", "", "Sales-Performance", "1")
        ]
    let items_2 = [
            ("MTP", "MTP", "MTP", "1"),
            ("DVR", "DVR", "DVR", "1"),
            ("Expense", "Expense", "Expense", "1")
        ]
    
    // Define grid columns layout
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let columns2 = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        HStack {
            Button(action: logout) {
                Image("Sidemenu")
                    .resizable()
                    .frame(width: 30, height: 28)
            }
            .frame(width: 35, height: 35)
            
            Spacer()
            
            Button(action: logout) {
                Image("Chat")
                    .resizable()
                    .frame(width: 30, height: 28)
            }
            .frame(width: 35, height: 35)
            .padding(.trailing, 2)
            
            Button(action: logout) {
                Image("Notifications")
                    .resizable()
                    .frame(width: 30, height: 28)
            }
            .frame(width: 35, height: 35)
            
        }
        .frame(height: 40)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items_1, id: \.0) { item in
                    if item.3 == "1" {
                        DashboardItemView(label: item.0, count: item.1, iconName: item.2) {
                            AnyView {
                                if item.0 == "Item 1" {
                                    print("Item --> \(item.0)")
                                } else if item.0 == "Item 2" {
                                    print("Item --> \(item.0)")
                                } else {
                                    print("Item --> \(item.0)")
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            
            LazyVGrid(columns: columns2, spacing: 20) {
                ForEach(items_2, id: \.0) { item in
                    if item.3 == "1" {
                        DashboardItemView2(label: item.0, count: item.1, iconName: item.2) {
                            
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    /*var body: some View {
        NavigationView {
            ZStack {
                // Main home content
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(items, id: \.self) { item in
                                ZStack {
                                    Image(systemName: "")
                                        .font(.largeTitle)
                                        .frame(width: (UIScreen.main.bounds.width - 50)/2, height: 90)
                                        .background(.blue)
                                        .cornerRadius(15)
                                    VStack {
                                        HStack {
                                            Image(systemName: "macpro.gen2")
                                            Text("12345")
                                        }
                                        .frame(alignment: .leading)
                                        
                                        Text("Product History")
                                    }
                                    .frame(alignment: .leading)
                                }
                                .frame(alignment: .leading)
                            }
                        }
                        .padding()
                        
                        /*Button(action: logout) {
                            Text("Logout")
                                .foregroundColor(.red)
                                .padding()
                        }   //  */
                    }
                }
                //.frame(maxHeight: 300)
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
    }   //  */
    
    func logout() {
        // Logic for logging out
        let loginManager = LoginManager()
        loginManager.isLoggedIn = false
    }
}

#Preview {
    HomeView()
}
