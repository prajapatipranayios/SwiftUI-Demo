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
    @State private var showToast = false
    
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
            
            Button("Show Success Toast") {
                showToast = true
                ToastView.showToast(message: "Success Toast", type: .success, on: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView(), duration: 3.0)
            }
        }
        .padding()
        .showToast(message: "Show Toast message", type: .success)
    }
    
    func login() {
        // Simulate login validation
        showToast = true
        if username != "" && password != "" {
            // Mark as logged in
            //isLoggedIn = true
            //loginManager.isLoggedIn = true
            
            let param = [
                "mobile_no": username,
                "password": password,
                "device_id": (UIDevice.current.identifierForVendor?.uuidString)!,
                "fcm_token": "UserDefaults.standard.value(forKey: UserDefaultType.fcmToken) as Any"
            ]
            
            APIManager.sharedManager.postData(url: APIManager.sharedManager.LOGIN, parameters: param) { (response: ApiResponse?, error) in
                if response?.status == 1 {
                    print(response?.message ?? "")
                    
                    print(response?.result)
                }
                else {
                    print(response?.message ?? "")
                }
            }
            
        } else {
            print("Login failed")
        }
    }
    
}

#Preview {
    LoginView()
}
