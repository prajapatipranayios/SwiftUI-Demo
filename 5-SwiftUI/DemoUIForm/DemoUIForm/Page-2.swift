//
//  Page-2.swift
//  DemoUIForm
//
//  Created by Auxano on 01/10/25.
//


//import SwiftUI
//
//// MARK: - Model
//struct FormData {
//    var name: String = ""
//    var age: String = ""
//    var address: String = ""
//    var email: String = ""
//    var phone: String = ""
//}
//
//// MARK: - ViewModel
//final class FormViewModel: ObservableObject {
//    @Published var formData = FormData()
//}
//
//// MARK: - Navigation Route
//enum Route: Hashable {
//    case basic
//    case address
//    case contact
//    case other
//}
//
//// MARK: - Home
//struct HomeView: View {
//    @StateObject private var viewModel = FormViewModel()
//    @State private var path = NavigationPath()
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 20) {
//                
//                Button("Fill Form") {
//                    path.append(Route.basic)  // start with Basic Details
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button("Print Values") {
//                    let d = viewModel.formData
//                    print("Name: \(d.name)")
//                    print("Age: \(d.age)")
//                    print("Address: \(d.address)")
//                    print("Email: \(d.email)")
//                    print("Phone: \(d.phone)")
//                }
//                .buttonStyle(.bordered)
//                
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Home")
//            .navigationDestination(for: Route.self) { route in
//                switch route {
//                case .basic:
//                    BasicDetailsView(viewModel: viewModel, path: $path)
//                case .address:
//                    AddressDetailsView(viewModel: viewModel, path: $path)
//                case .contact:
//                    ContactDetailsView(viewModel: viewModel, path: $path)
//                case .other:
//                    OtherDetailsView(viewModel: viewModel, path: $path)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Basic Details
//struct BasicDetailsView: View {
//    @ObservedObject var viewModel: FormViewModel
//    @Binding var path: NavigationPath
//    
//    var body: some View {
//        Form {
//            TextField("Name", text: $viewModel.formData.name)
//            TextField("Age", text: $viewModel.formData.age)
//                .keyboardType(.numberPad)
//            
//            Button("Next → Address Details") {
//                path.append(Route.address)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .navigationTitle("Basic Details")
//    }
//}
//
//// MARK: - Address Details
//struct AddressDetailsView: View {
//    @ObservedObject var viewModel: FormViewModel
//    @Binding var path: NavigationPath
//    
//    var body: some View {
//        Form {
//            TextField("Address", text: $viewModel.formData.address)
//            
//            Button("Next → Contact Details") {
//                path.append(Route.contact)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .navigationTitle("Address Details")
//    }
//}
//
//// MARK: - Contact Details
//struct ContactDetailsView: View {
//    @ObservedObject var viewModel: FormViewModel
//    @Binding var path: NavigationPath
//    
//    var body: some View {
//        Form {
//            TextField("Email", text: $viewModel.formData.email)
//                .keyboardType(.emailAddress)
//            TextField("Phone", text: $viewModel.formData.phone)
//                .keyboardType(.phonePad)
//            
//            Button("Next → Other Details") {
//                path.append(Route.other)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .navigationTitle("Contact Details")
//    }
//}
//
//// MARK: - Other Details
//struct OtherDetailsView: View {
//    @ObservedObject var viewModel: FormViewModel
//    @Binding var path: NavigationPath
//    
//    var body: some View {
//        Form {
//            Text("Any other fields…")
//            
//            Button("Save & Return to Home") {
//                path = NavigationPath()   // ✅ clears all stack and goes back Home
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .navigationTitle("Other Details")
//    }
//}
