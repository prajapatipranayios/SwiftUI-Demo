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
    
    @State private var showAlert = false
    @State private var alertType: AlertPopupView.AlertType = .message
    @State private var alertInputText = ""
    @State private var responseText = ""
    
    @State private var showPopup = false
    @State private var popupResponse: PopupResponse?
    
    var body: some View {
        
        VStack(spacing: 20) {
            Button("Show Message Popup") {
                showPopup.toggle()
            }
            
            if let response = popupResponse {
                Text("Popup Response: \(response.inputText ?? "No Input")")
                    .padding()
            }
        }
        .customPopup(show: $showPopup, type: .message, title: "Notice", message: "This is a message.", placeholder: "Enter text", colors: defaultColors(), onConfirm: { response in
            popupResponse = response
        }, onCancel: {
            popupResponse = nil
        })
        
        /*VStack(spacing: 20) {
            Button("Show Message Alert") {
                alertType = .message
                showAlert.toggle()
            }
            
            Button("Show Confirmation Alert") {
                alertType = .confirmation
                showAlert.toggle()
            }
            
            Button("Show Input Alert") {
                alertType = .input
                showAlert.toggle()
            }
            
            Text("Response: \(responseText)")
                .padding()
        }
                .overlay(
                    AlertPopupView(
                        isPresented: $showAlert,
                        inputText: $alertInputText,
                        type: alertType,
                        title: "Custom Alert",
                        message: alertType == .input ? "Please enter your input" : "This is a custom alert message. This is a custom alert message. This is a custom alert message. ",
                        onOK: {
                            responseText = alertType == .input ? "Input: \(alertInputText)" : "OK Pressed"
                            alertInputText = ""
                            print(responseText)
                        },
                        onCancel: {
                            responseText = "Cancel Pressed"
                        },
                        // Customize colors here as needed
                        popupColor: .white,
                        titleTextColor: .white,
                        titleBackgroundColor: .blue,
                        messageTextColor: .black,
                        okButtonTextColor: .white,
                        okButtonColor: .green,
                        cancelButtonTextColor: .white,
                        cancelButtonColor: .red
                    )
                    .opacity(showAlert ? 1 : 0)
                    .animation(.easeInOut)
                )   //  */
        
        /*ZStack {
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
        }   //  */
    }
    
    func defaultColors() -> PopupColors {
        return PopupColors(
            popupBackgroundColor: Color.white,
            titleTextColor: Color.black,
            titleBackgroundColor: Color.gray.opacity(0.2),
            messageTextColor: Color.gray,
            okButtonColor: Color.blue,
            okButtonTextColor: Color.white,
            cancelButtonColor: Color.red,
            cancelButtonTextColor: Color.white
        )
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
