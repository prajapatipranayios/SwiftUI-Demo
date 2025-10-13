//
//  Page-3.swift
//  DemoUIForm
//
//  Created by Auxano on 01/10/25.
//


import SwiftUI

#Preview {
    ContentView()
}

// MARK: - Model
struct FormData {
    var name: String = ""
    var address: String = ""
    var email: String = ""
}

// MARK: - ViewModel
class FormViewModel: ObservableObject {
    @Published var formData = FormData()
}

// MARK: - Home
struct HomeView: View {
    @StateObject private var viewModel = FormViewModel()
    @State private var goToForm = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink("", destination: BasicDetailsView(viewModel: viewModel, goToForm: $goToForm), isActive: $goToForm)
                    .hidden()
                
                Button("Fill Form") {
                    goToForm = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Print Values") {
                    print("Name: \(viewModel.formData.name)")
                    print("Address: \(viewModel.formData.address)")
                    print("Email: \(viewModel.formData.email)")
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

// MARK: - Basic Details
struct BasicDetailsView: View {
    @ObservedObject var viewModel: FormViewModel
    @Binding var goToForm: Bool
    @State private var next = false
    
    var body: some View {
        VStack {
            TextField("Name", text: $viewModel.formData.name)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            NavigationLink("", destination: AddressDetailsView(viewModel: viewModel, goToForm: $goToForm), isActive: $next)
                .hidden()
            
            Button("Next → Address Details") {
                next = true
            }
        }
        .navigationTitle("Basic Details")
    }
}

// MARK: - Address Details
struct AddressDetailsView: View {
    @ObservedObject var viewModel: FormViewModel
    @Binding var goToForm: Bool
    @State private var next = false
    
    var body: some View {
        VStack {
            TextField("Address", text: $viewModel.formData.address)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            NavigationLink("", destination: ContactDetailsView(viewModel: viewModel, goToForm: $goToForm), isActive: $next)
                .hidden()
            
            Button("Next → Contact Details") {
                next = true
            }
        }
        .navigationTitle("Address Details")
    }
}

// MARK: - Contact Details
struct ContactDetailsView: View {
    @ObservedObject var viewModel: FormViewModel
    @Binding var goToForm: Bool
    
    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.formData.email)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Save & Go Home") {
                goToForm = false   // ✅ This pops all the way back to Home
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Contact Details")
    }
}
