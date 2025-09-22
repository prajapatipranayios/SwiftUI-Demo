//
//  CustomPopup.swift
//  Tussly
//
//  Created by Auxano on 22/09/25.
//


import SwiftUI

struct CustomPopup: View {
    var title: String? = nil
    var message: String
    var popupColor: Color = .white                 // default
    var textColor: Color = .black                  // default
    
    var okTitle: String = "Submit"                 // default
    var okColor: Color = .green                     // default
    var onOk: ((String?) -> Void)? = nil
    
    var cancelTitle: String? = "Cancel"            // default
    var cancelColor: Color = .gray                 // default
    var onCancel: (() -> Void)? = nil
    
    var cornerRadius: CGFloat = 16
    var dismissOnBackgroundTap: Bool = false
    var showTextField: Bool = false
    
    @Binding var isPresented: Bool
    @State private var inputText: String = ""
    
    var body: some View {
        if isPresented {
            ZStack {
                // Background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if dismissOnBackgroundTap {
                            isPresented = false
                        }
                    }
                
                // Popup
                VStack(spacing: 16) {
                    if let title = title {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    
                    Text(message)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                    
                    if showTextField {
                        TextField("Enter here...", text: $inputText)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        if let cancelTitle = cancelTitle {
                            Button(action: {
                                isPresented = false
                                onCancel?()
                            }) {
                                Text(cancelTitle)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(cancelColor)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            isPresented = false
                            onOk?(showTextField ? inputText : nil)
                        }) {
                            Text(okTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(okColor)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(popupColor)
                .cornerRadius(cornerRadius)
                .padding(.horizontal, 40)
                .shadow(radius: 10)
                .transition(.scale)
            }
            .animation(.easeInOut, value: isPresented)
        }
    }
}

//CustomPopup(
//    title: "Feedback",
//    message: "Please enter your name:",
//    onOk: { text in
//        print("Entered value:", text ?? "nil")
//    },
//    isPresented: $showPopup,
//    showTextField: true
//)
