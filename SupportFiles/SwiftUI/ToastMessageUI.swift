//
//  ToastMessageUI.swift
//
//  Created by Pranay on 23/10/24.
//

import SwiftUI

// MARK: - Toast Type
enum ToastType {
    case success
    case warning
    case error
}

// MARK: - Toast Position
enum ToastPosition {
    case top
    case center
    case bottom
}

// MARK: - Toast Message View
struct ToastMessage: View {

    let message: String
    let type: ToastType
    let position: ToastPosition

    var duration: Double = 2
    var withAnimation: Bool = true
    var customBackgroundColor: Color? = nil
    var customTextColor: Color? = nil

    @State private var isVisible = false

    // MARK: - Default Colors
    private var backgroundColor: Color {
        customBackgroundColor ?? {
            switch type {
            case .success:
                return Color.green.opacity(0.85)
            case .warning:
                return Color.orange.opacity(0.85)
            case .error:
                return Color.red.opacity(0.85)
            }
        }()
    }

    private var textColor: Color {
        customTextColor ?? {
            switch type {
            case .success, .warning:
                return .black
            case .error:
                return .white
            }
        }()
    }

    // MARK: - Body
    var body: some View {
        VStack {
            if isVisible {
                toastContent
            }
        }
        .onAppear {
            showToast()
        }
    }

    // MARK: - Toast Content
    @ViewBuilder
    private var toastContent: some View {
        switch position {
        case .top:
            toastView
            Spacer()

        case .center:
            Spacer()
            toastView
            Spacer()

        case .bottom:
            Spacer()
            toastView
        }
    }

    private var toastView: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(textColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
            .transition(transition)
            .animation(withAnimation ? .easeInOut : nil, value: isVisible)
    }

    // MARK: - Animation
    private var transition: AnyTransition {
        guard withAnimation else { return .identity }

        switch position {
        case .top:
            return .move(edge: .top)
        case .bottom:
            return .move(edge: .bottom)
        case .center:
            return .scale
        }
    }

    // MARK: - Logic
    private func showToast() {
        withAnimation(withAnimation ? .easeInOut : nil) {
            isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(withAnimation ? .easeInOut : nil) {
                isVisible = false
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
