//
//  LoginView.swift
//  GEClone-UI
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct LoginView: View {
    //@AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    @EnvironmentObject var loginManager: LoginManager
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
            
            Button(action: login) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
        }
        .padding()
    }
    
    func login() {
        // Simulate login validation
        if username != "user" && password != "password" {
            // Mark as logged in
            //isLoggedIn = true
            loginManager.isLoggedIn = true
        } else {
            print("Login failed")
        }
    }
}

#Preview {
    LoginView()
}
