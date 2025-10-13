//
//  ContentView.swift
//  DemoUIForm
//
//  Created by Auxano on 01/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
}

// MARK: - Model
//struct FormData {
//    var name: String = ""
//    var age: String = ""
//    var email: String = ""
//    var address: String = ""
//}

// MARK: - ViewModel
//class FormViewModel: ObservableObject {
//    @Published var formData = FormData()
//    @Published var showForm = false
//}

// MARK: - Home View
//struct HomeView: View {
//    @StateObject private var viewModel = FormViewModel()
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                
//                Button("Fill Form") {
//                    viewModel.showForm = true
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button("Print Values") {
//                    print("Name: \(viewModel.formData.name)")
//                    print("Age: \(viewModel.formData.age)")
//                    print("Email: \(viewModel.formData.email)")
//                    print("Address: \(viewModel.formData.address)")
//                }
//                .buttonStyle(.bordered)
//            }
//            .navigationTitle("Home")
//            .sheet(isPresented: $viewModel.showForm) {
//                FormFlowView(viewModel: viewModel)
//            }
//        }
//    }
//}

// MARK: - Multi-Step Form
//struct FormFlowView: View {
//    @ObservedObject var viewModel: FormViewModel
//    @State private var step = 1
//    
//    var body: some View {
//        VStack {
//            if step == 1 {
//                StepOne(formData: $viewModel.formData)
//            } else if step == 2 {
//                StepTwo(formData: $viewModel.formData)
//            } else if step == 3 {
//                StepThree(formData: $viewModel.formData)
//            } else if step == 4 {
//                StepFour(formData: $viewModel.formData)
//            }
//            
//            Spacer()
//            
//            HStack {
//                if step > 1 {
//                    Button("Back") { step -= 1 }
//                }
//                Spacer()
//                if step < 4 {
//                    Button("Next") { step += 1 }
//                } else {
//                    Button("Save") {
//                        viewModel.showForm = false // close sheet
//                    }
//                }
//            }
//            .padding()
//        }
//        .padding()
//    }
//}

// MARK: - Step Views
//struct StepOne: View {
//    @Binding var formData: FormData
//    var body: some View {
//        Form {
//            TextField("Enter Name", text: $formData.name)
//        }
//        .navigationTitle("Step 1")
//    }
//}

//struct StepTwo: View {
//    @Binding var formData: FormData
//    var body: some View {
//        Form {
//            TextField("Enter Age", text: $formData.age)
//        }
//        .navigationTitle("Step 2")
//    }
//}

//struct StepThree: View {
//    @Binding var formData: FormData
//    var body: some View {
//        Form {
//            TextField("Enter Email", text: $formData.email)
//        }
//        .navigationTitle("Step 3")
//    }
//}

//struct StepFour: View {
//    @Binding var formData: FormData
//    var body: some View {
//        Form {
//            TextField("Enter Address", text: $formData.address)
//        }
//        .navigationTitle("Step 4")
//    }
//}

//import SwiftUI
//
//// MARK: - Model
//struct FormData {
//    var name: String = ""
//    var age: String = ""
//    var email: String = ""
//    var address: String = ""
//}
//
//// MARK: - ViewModel (shared between steps)
//final class FormViewModel: ObservableObject {
//    @Published var formData = FormData()
//}
//
//// MARK: - Navigation Route (hashable)
//enum Route: Hashable {
//    case step(Int)
//}
//
//// MARK: - Home
//struct HomeView: View {
//    @StateObject private var viewModel = FormViewModel()
//    @State private var path = NavigationPath()          // <--- navigation path
//    
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 20) {
//                // Start the flow by appending Step 1
//                Button("Fill Form") {
//                    path.append(Route.step(1))
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button("Print Values") {
//                    let d = viewModel.formData
//                    print("Name: \(d.name)")
//                    print("Age: \(d.age)")
//                    print("Email: \(d.email)")
//                    print("Address: \(d.address)")
//                }
//                .buttonStyle(.bordered)
//                
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Home")
//            // Map Route -> destination views
//            .navigationDestination(for: Route.self) { route in
//                switch route {
//                case .step(let idx):
//                    StepView(index: idx,
//                             totalSteps: 4,                 // change this for more/less steps
//                             path: $path,
//                             viewModel: viewModel)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Generic Step View (re-usable for any step index)
//struct StepView: View {
//    let index: Int
//    let totalSteps: Int
//    @Binding var path: NavigationPath
//    @ObservedObject var viewModel: FormViewModel
//    
//    var body: some View {
//        Form {
//            Group {
//                // Simple example: different field per step
//                if index == 1 {
//                    TextField("Enter name", text: $viewModel.formData.name)
//                } else if index == 2 {
//                    TextField("Enter age", text: $viewModel.formData.age)
//                        .keyboardType(.numberPad)
//                } else if index == 3 {
//                    TextField("Enter email", text: $viewModel.formData.email)
//                        .keyboardType(.emailAddress)
//                } else {
//                    TextField("Enter address", text: $viewModel.formData.address)
//                }
//            }
//            .textInputAutocapitalization(.never)
//            
//            // Next / Save buttons at bottom
//            Section {
//                HStack {
//                    // Optional custom Back button (the system back arrow is present automatically
//                    // when view was pushed — this is an extra explicit back button).
//                    if index > 1 {
//                        Button("Back") {
//                            if !path.isEmpty { path.removeLast() } // safe pop one
//                        }
//                        .buttonStyle(.bordered)
//                    }
//                    
//                    Spacer()
//                    
//                    if index < totalSteps {
//                        Button("Next") {
//                            path.append(Route.step(index + 1))
//                        }
//                        .buttonStyle(.borderedProminent)
//                    } else {
//                        // SAVE: clear path to go back to Home (no counting of pages needed)
//                        Button("Save") {
//                            path = NavigationPath() // <-- clear the stack -> back to Home
//                        }
//                        .buttonStyle(.borderedProminent)
//                    }
//                }
//            }
//        }
//        .navigationTitle("Step \(index)")
//        // The system-provided back arrow will appear automatically;
//        // above we also provide an explicit Back button in the form body (optional).
//    }
//}
