//
//  CustomPopup.swift
//  GEClone-UI
//
//  Created by Auxano on 25/10/24.
//

import SwiftUI

// Struct to manage popup response
struct PopupResponse {
    var confirmed: Bool
    var inputText: String?
}

// Enum to define the type of popup
enum PopupType {
    case message
    case confirmation
    case textInput
}

// Custom popup view
struct CustomPopup: View {
    let type: PopupType
    let title: String
    let message: String
    let placeholder: String
    let colors: PopupColors?
    let onConfirm: (PopupResponse) -> Void
    let onCancel: () -> Void
    
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Popup Title
            Text(title)
                .font(.headline)
                .foregroundColor(colors?.titleTextColor)
                .padding()
                .background(colors?.titleBackgroundColor)
                .cornerRadius(8)
            
            // Popup Message or Text Input
            if type == .textInput {
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .foregroundColor(colors?.messageTextColor)
            } else {
                Text(message)
                    .font(.body)
                    .foregroundColor(colors?.messageTextColor)
                    .padding()
            }
            
            // Action Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if type == .confirmation || type == .textInput {
                        onCancel()
                    } else {
                        onConfirm(PopupResponse(confirmed: true, inputText: nil))
                    }
                }) {
                    Text("Cancel")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colors?.cancelButtonColor)
                        .foregroundColor(colors?.cancelButtonTextColor)
                        .cornerRadius(8)
                }
                .opacity(type == .message ? 0 : 1) // Hide Cancel button for message popup
                
                Button(action: {
                    onConfirm(PopupResponse(confirmed: true, inputText: inputText.isEmpty ? nil : inputText))
                }) {
                    Text("OK")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colors?.okButtonColor)
                        .foregroundColor(colors?.okButtonTextColor)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(colors?.popupBackgroundColor)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

// Popup colors configuration
struct PopupColors {
    var popupBackgroundColor: Color = Color.white
    var titleTextColor: Color = Color.black
    var titleBackgroundColor: Color = Color.gray.opacity(0.2)
    var messageTextColor: Color = Color.gray
    var okButtonColor: Color = Color.blue
    var okButtonTextColor: Color = Color.white
    var cancelButtonColor: Color = Color.red
    var cancelButtonTextColor: Color = Color.white
}

// Popup view modifier to present popup as overlay
extension View {
    func customPopup(show: Binding<Bool>, type: PopupType, title: String, message: String, placeholder: String = "", colors: PopupColors, onConfirm: @escaping (PopupResponse) -> Void, onCancel: @escaping () -> Void) -> some View {
        ZStack {
            self
                .blur(radius: show.wrappedValue ? 2 : 0)
                .animation(.easeInOut, value: show.wrappedValue)
            
            if show.wrappedValue {
                CustomPopup(type: type, title: title, message: message, placeholder: placeholder, colors: colors, onConfirm: { response in
                    show.wrappedValue = false
                    onConfirm(response)
                }, onCancel: {
                    show.wrappedValue = false
                    onCancel()
                })
                .frame(maxWidth: 300)
                .padding()
                .transition(.scale)
            }
        }
    }
}

//#Preview {
//    CustomPopup()
//}
