//
//  Dashboard.swift
//  GEClone-UI
//
//  Created by Auxano on 22/10/24.
//

import SwiftUI

enum UserRole {
    case superAdmin
    case admin
    case manager
    case user
}

struct GridItemData: Identifiable {
    let id = UUID()
    let title: String
    let fullTitle: String?
    let count: String?
    let iconName: String
    let destination: AnyView
    let allowedRoles: [UserRole] // Roles that are allowed to see this item
}

let gridData = [
    GridItemData(
        title: "Product History", fullTitle: "",
        count: "2",
        iconName: "Product-History",
        destination: AnyView(ProductHistoryView()),
        allowedRoles: [.admin, .manager]),
    
    GridItemData(title: "Business Partner", fullTitle: "", count: "624941", iconName: "Business-Partner", destination: AnyView(BusinessPartnerView()), allowedRoles: [.admin, .user]),
    GridItemData(title: "Sales Order", fullTitle: "", count: "56341", iconName: "Sales-Order", destination: AnyView(SalesOrderView()), allowedRoles: [.admin, .user]),
    GridItemData(title: "Sample Request", fullTitle: "", count: "123", iconName: "Sample-Request", destination: AnyView(SampleRequestView()), allowedRoles: [.admin]),
    GridItemData(title: "Quotations", fullTitle: "", count: "532", iconName: "Quotations", destination: AnyView(QuotationView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Proforma Invoice", fullTitle: "", count: "2345", iconName: "Proforma-Invoice", destination: AnyView(ProformaInvoiceView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Follow Up", fullTitle: "", count: "34", iconName: "Follow-Up", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Draft Sales Order", fullTitle: "", count: "234", iconName: "Draft-Sales-Order", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Dashboard", fullTitle: "", count: "", iconName: "Dashboard", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Target", fullTitle: "", count: "", iconName: "Target", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "Sales Performance", fullTitle: "", count: "", iconName: "Sales-Performance", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    GridItemData(title: "CRM", fullTitle: "", count: "", iconName: "CRM", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    
    //GridItemData(title: "Follow Up", count: "0", iconName: "calendar.badge.clock", destination: AnyView(FollowUpView()), allowedRoles: [.admin, .manager, .user]),
    // Add other items similarly...
]

let gridData2 = [
    GridItemData(
        title: "MTP",
        fullTitle: "Monthly Tour Plan",
        count: "",
        iconName: "MTP",
        destination: AnyView(MTPView()),
        allowedRoles: [.admin, .manager]),
    GridItemData(title: "DVR", fullTitle: "Daily Visit Report", count: "", iconName: "DVR", destination: AnyView(DVRView()), allowedRoles: [.admin, .user]),
    GridItemData(title: "Expense", fullTitle: "Expense", count: "", iconName: "Expense", destination: AnyView(ExpenseView()), allowedRoles: [.admin, .user]),
]

struct Dashboard: View {
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    let columns2 = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    // Set the user role (you can set this dynamically based on login or other conditions)
    var userRole: UserRole = .admin
    
    var filteredData: [GridItemData] {
        gridData.filter { $0.allowedRoles.contains(userRole) }
    }
    
    var body: some View {
        
        NavigationStack {
            
            HStack {
                Button(action: logout) {
                    Image("Sidemenu")
                        .resizable()
                        .frame(width: 25, height: 23)
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
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(filteredData) { item in
                        NavigationLink(destination: item.destination) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(item.iconName)
                                        .resizable()
                                        //.scaledToFit()
                                        .frame(width: 45, height: 45)
                                        .font(.largeTitle)
                                        .padding(.bottom, 8)
                                        .padding(.leading, 8)
                                    
                                    if !(item.count ?? "0").isEmpty {
                                        Text(item.count!)
                                            .foregroundColor(Color.black)
                                            .font(.system(size: 25))
                                            .bold()
                                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                                    }
                                    Spacer()
                                }
                                Text(item.title)
                                    .foregroundColor(Color.black)
                                    .font(.body)
                                    .bold()
                                    .frame(alignment: .leading)
                                    //.background(Color.blue)
                                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 4))
                            }
                            .frame(width: (UIScreen.main.bounds.width - 60) / 2, height: 95)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding()
                
                HStack {
                    Text("TA & DA")
                        .padding(EdgeInsets(top: 12, leading: 24, bottom: 0, trailing: 0))
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Spacer()
                }
                
                LazyVGrid(columns: columns2, spacing: 0) {
                    ForEach(gridData2) { item in
                        NavigationLink(destination: item.destination) {
                            VStack(alignment: .leading) {
                                Image(item.iconName)
                                    .resizable()
                                    .frame(width: 65, height: 65)
                                    .padding(.bottom, 0)
                                    .padding(.leading, 8)
                                    .padding(.top, 0)
                                
                                Text(item.title)
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 19))
                                    .padding(.leading, 8)
                                    .bold()
                                
                                Text(item.fullTitle ?? "")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.black)
                                    //.bold()
                                    .frame(alignment: .leading)
                                //.background(Color.blue)
                                    .padding(.leading, 8)
                                
                            }
                            .frame(width: (UIScreen.main.bounds.width - 80) / 3, height: 110)
                            .background(Color.white)
                            .cornerRadius(10)
                            //.shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("")
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func logout() {
        // Logic for logging out
        let loginManager = LoginManager()
        loginManager.isLoggedIn = false
    }
}

#Preview {
    Dashboard()
}


// Dummy destination views
struct ProductHistoryView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationStack {
            
            HStack {
                Button(action: logout) {
                    Image("Sidemenu")
                        .resizable()
                        .frame(width: 25, height: 23)
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
            
            Spacer()
            
            VStack {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                NavigationLink(destination: BusinessPartnerView()) {
                    Text("Go to Next")
                }
                
                Text("Product History")
            }
        }
        .navigationBarHidden(true)
    }
    
    func logout() {
        // Logic for logging out
        let loginManager = LoginManager()
        loginManager.isLoggedIn = false
    }
}

struct BusinessPartnerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        NavigationStack {
            
            HStack {
                Button(action: logout) {
                    Image("Sidemenu")
                        .resizable()
                        .frame(width: 25, height: 23)
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
            
            Spacer()
            
            VStack {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                NavigationLink(destination: SalesOrderView()) {
                    Text("Go to Next")
                }
                
                Text("Business Partners")
            }
        }
        .navigationBarHidden(true)
    }
    
    func logout() {
        // Logic for logging out
        let loginManager = LoginManager()
        loginManager.isLoggedIn = false
    }
}

struct SalesOrderView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View { 
        
        VStack {
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(destination: SampleRequestView()) {
                Text("Go to Next")
            }
            
            Text("Sales Order")
        }
        .navigationBarHidden(true)
    }
}

struct SampleRequestView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(destination: QuotationView()) {
                Text("Go to Next")
            }
            
            Text("Sample Request")
        }
        .navigationBarHidden(true)
    }
}

struct QuotationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            
            NavigationLink(destination: ProformaInvoiceView()) {
                Text("Go to Next")
            }
            
            Text("Quotations")
        }
        .navigationBarHidden(true)
    }
}

struct ProformaInvoiceView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Proforma Invoice")
    }
}

struct FollowUpView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Follow Up")
    }
}

struct DraftSalesOrderView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Draft Sales Order")
    }
}

struct DashboardView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Dashboard")
    }
}

struct TargetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Target")
    }
}

struct SalesPerformanceView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Sales Performance")
    }
}

struct CRMView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("CRM")
    }
}

struct MTPView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("MTP - Monthly Tour Plan")
    }
}

struct DVRView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("DVR - Daily Visit Report")
    }
}

struct ExpenseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
        
        Text("Expense")
    }
}

