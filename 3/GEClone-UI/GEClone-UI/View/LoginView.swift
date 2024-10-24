//
//  LoginView.swift
//  GEClone-UI
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct LoginView: View {
    
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
}

#Preview {
    LoginView()
}
