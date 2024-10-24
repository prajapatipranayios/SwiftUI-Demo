//
//  ToastViewRepresentable.swift
//  GEClone-UI
//
//  Created by Auxano on 23/10/24.
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
        case .success, .failure:
            return Color.white
        case .warning:
            return Color.black
        }
    }
    
    // Body of the toast message
    var body: some View {
        if position == .top {
            Text(message)
                .font(.headline)
                .foregroundColor(customTextColor ?? defaultTextColor)
                .padding()
                .background(customBackgroundColor ?? defaultBackgroundColor)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.move(edge: .top))
                .animation(.easeInOut)
            Spacer()
        }
        else if position == .bottom {
            Spacer()
            Text(message)
                .font(.headline)
                .foregroundColor(customTextColor ?? defaultTextColor)
                .padding()
                .background(customBackgroundColor ?? defaultBackgroundColor)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.move(edge: .top))
                .animation(.easeInOut)
        }
        else {
            Text(message)
                .font(.headline)
                .foregroundColor(customTextColor ?? defaultTextColor)
                .padding()
                .background(customBackgroundColor ?? defaultBackgroundColor)
                .cornerRadius(10)
                .shadow(radius: 10)
                .padding(.horizontal, 40)
                .transition(.move(edge: .top))
                .animation(.easeInOut)
        }
    }
}
