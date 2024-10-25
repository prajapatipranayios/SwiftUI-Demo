//
//  AlertPopupView.swift
//  GEClone-UI
//
//  Created by Auxano on 25/10/24.
//

import Foundation
import SwiftUI

struct AlertPopupView: View {
    enum AlertType {
        case message
        case confirmation
        case input
    }
    
    @Binding var isPresented: Bool
    @Binding var inputText: String // Used for input alert
    
    let type: AlertType
    let title: String
    let message: String
    let onOK: (() -> Void)?
    let onCancel: (() -> Void)?
    
    // Customization options
    var popupColor: Color = .white
    var titleTextColor: Color = .black
    var titleBackgroundColor: Color = .blue
    var messageTextColor: Color = .gray
    var okButtonTextColor: Color = .white
    var okButtonColor: Color = .blue
    var cancelButtonTextColor: Color = .white
    var cancelButtonColor: Color = .red
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(title)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(titleBackgroundColor)
                .foregroundColor(titleTextColor)
                .cornerRadius(7)
            
            // Message
            Text(message)
                .font(.body)
                .foregroundColor(messageTextColor)
                .padding(.horizontal)
            
            // Input Field for Input Alert Type
            if type == .input {
                TextField("Enter your input...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            
            HStack {
                if type == .confirmation || type == .input {
                    // Cancel Button
                    Button(action: {
                        isPresented = false
                        onCancel?()
                    }) {
                        Text("Cancel")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(cancelButtonColor)
                            .foregroundColor(cancelButtonTextColor)
                            .cornerRadius(8)
                    }
                }
                
                // OK Button
                Button(action: {
                    isPresented = false
                    onOK?()
                }) {
                    Text("OK")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(okButtonColor)
                        .foregroundColor(okButtonTextColor)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(popupColor)
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(width: UIScreen.main.bounds.width * 0.8)
        //.frame(maxWidth: UIScreen.main.bounds.width * 0.8)
    }
}
