//
//  ToastMessageUI.swift
//
//  Created by Pranay on 23/10/24.
//

import Foundation
import SwiftUI


// Enum to define toast types
enum ToastType {
    case success
    case warning
    case failure
}

// Enum to define toast position
enum ToastPosition {
    case top
    case center
    case bottom
}

// Struct for the ToastMessage
struct ToastMessage: View {
    let message: String
    let type: ToastType
    let position: ToastPosition
    var customBackgroundColor: Color?
    var customTextColor: Color?
    var withAnimation: Bool = false // Animation control parameter
    
    // State to control the visibility of the toast
    @State private var isVisible: Bool = false
    
    // Default colors based on toast type
    private var defaultBackgroundColor: Color {
        switch type {
        case .success:
            return Color.green.opacity(0.8)
        case .warning:
            return Color.yellow.opacity(0.8)
        case .failure:
            return Color.red.opacity(0.8)
        }
    }
    
    private var defaultTextColor: Color {
        switch type {
        case .success, .warning:
            return Color.black
        case .failure:
            return Color.white
        }
    }
    
    var body: some View {
        VStack {
            if isVisible {
                switch position {
                case .top:
                    Text(message)
                        .font(.headline)
                        .foregroundColor(customTextColor ?? defaultTextColor)
                        .padding()
                        .background(customBackgroundColor ?? defaultBackgroundColor)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                        .transition(withAnimation ? .move(edge: .top) : .identity)
                        .animation(withAnimation ? .easeInOut : nil, value: isVisible)
                    Spacer()
                    
                case .bottom:
                    Spacer()
                    Text(message)
                        .font(.headline)
                        .foregroundColor(customTextColor ?? defaultTextColor)
                        .padding()
                        .background(customBackgroundColor ?? defaultBackgroundColor)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                        .transition(withAnimation ? .move(edge: .bottom) : .identity)
                        .animation(withAnimation ? .easeInOut : nil, value: isVisible)
                    
                case .center:
                    Text(message)
                        .font(.headline)
                        .foregroundColor(customTextColor ?? defaultTextColor)
                        .padding()
                        .background(customBackgroundColor ?? defaultBackgroundColor)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                        .transition(withAnimation ? .scale : .identity)
                        .animation(withAnimation ? .easeInOut : nil, value: isVisible)
                }
            }
        }
        .onAppear {
            // Show the toast with animation if specified
            SwiftUI.withAnimation(withAnimation ? .easeInOut : nil) {
                isVisible = true
            }
            // Automatically hide the toast after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SwiftUI.withAnimation(withAnimation ? .easeInOut : nil) {
                    isVisible = false
                }
            }
        }
    }
}


/*struct LoginView: View {
    
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
}   //  */

//#Preview {
//    LoginView()
//}
