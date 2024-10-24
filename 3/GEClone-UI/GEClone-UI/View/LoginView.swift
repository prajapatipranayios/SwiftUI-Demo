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
    @State private var toastType: ToastType = .success // Tracks the type of toast
    @State private var toastPosition: ToastPosition = .bottom // Tracks the position of toast
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Buttons to trigger toast at various positions and types
                Button("Show Success Toast at Bottom") {
                    toastType = .success
                    toastPosition = .bottom
                    showToast.toggle()
                }
                .padding()
                
                Button("Show Warning Toast at Top") {
                    toastType = .warning
                    toastPosition = .top
                    showToast.toggle()
                }
                .padding()
                
                Button("Show Failure Toast at Center") {
                    toastType = .failure
                    toastPosition = .center
                    showToast.toggle()
                }
                .padding()
            }
            
            // Toast overlay
            if showToast {
                VStack {
                    ToastMessage(message: "This is a toast message!", type: toastType, position: toastPosition, withAnimation: true)
                        .onAppear {
                            // Reset showToast to false after the ToastMessage appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut) {
                                    showToast = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    /*var body: some View {
     VStack {
     Button("Show Success Toast") {
     showToast.toggle()
     }
     .padding()
     
     // Toast overlay
     if showToast {
     ToastMessage(
     message: "Operation was successful!",
     type: .success
     )
     .onTapGesture {
     // Dismiss the toast when tapped
     showToast = false
     }
     .onAppear {
     // Automatically dismiss the toast after 3 seconds
     DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
     showToast = false
     }
     }
     }
     }
     }   //  */
    
    /*var body: some View {
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
     }   //  */
    
    /*func login() {
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
     }   //  */
    
}

#Preview {
    LoginView()
}
