//
//  ToastViewRepresentable.swift
//  GEClone-UI
//
//  Created by Auxano on 23/10/24.
//

import Foundation
import SwiftUI

struct ToastViewRepresentable: UIViewRepresentable {
    
    let message: String
    let type: ToastType
    let duration: TimeInterval
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let toast = ToastView(message: message, type: type)
        toast.showToast(on: uiView, duration: duration)
    }
}

extension View {
    func showToast(message: String, type: ToastType, duration: TimeInterval = 2.0) -> some View {
        self.overlay {
            ToastViewRepresentable(message: message, type: type, duration: duration)
                .frame(width: 0, height: 0)
        }
    }
}
