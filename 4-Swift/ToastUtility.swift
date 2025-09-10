//
//  ToastUtility.swift
//  Shared UIKit + SwiftUI Toast
//

import UIKit
import SwiftUI

// MARK: - Common UIKit Toast Utility
class ToastUtility {
    
    // MARK: Quick Toast for UIKit
    class func showToast(message: String, controller: UIViewController) {
        DispatchQueue.main.async {
            let maxWidth = min(controller.view.frame.width * 0.8, 300)
            let label = UILabel()
            label.text = message
            label.numberOfLines = 0
            label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            
            let textHeight = message.height(withConstrainedWidth: maxWidth, font: label.font)
            let safeBottom = controller.view.safeAreaInsets.bottom
            let frame = CGRect(
                x: (controller.view.frame.width - maxWidth) / 2,
                y: controller.view.frame.height - (textHeight + 40 + safeBottom),
                width: maxWidth,
                height: textHeight + 20
            )
            label.frame = frame
            
            controller.view.addSubview(label)
            controller.view.bringSubviewToFront(label)
            
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
                label.alpha = 0.0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        }
    }
    
    // MARK: Builder for UIKit
    class Builder {
        
        private var toast: UILabel
        private var controller: UIViewController
        
        private var screenTime: TimeInterval = 2.0
        private var hideAnimationDuration: TimeInterval = 0.5
        private var maxWidth: CGFloat
        
        init(message: String, controller: UIViewController) {
            self.controller = controller
            self.maxWidth = min(controller.view.frame.width * 0.8, 300)
            
            toast = UILabel()
            toast.text = message
            toast.numberOfLines = 0
            
            defaultSetup()
            updateFrame()
        }
        
        func setColor(background: UIColor, text: UIColor) -> ToastUtility.Builder {
            toast.backgroundColor = background
            toast.textColor = text
            return self
        }
        
        func set(font: UIFont) -> ToastUtility.Builder {
            toast.font = font
            updateFrame()
            return self
        }
        
        func setScreenTime(duration: TimeInterval) -> ToastUtility.Builder {
            self.screenTime = duration
            return self
        }
        
        func setHideAnimation(duration: TimeInterval) -> ToastUtility.Builder {
            self.hideAnimationDuration = duration
            return self
        }
        
        func dynamicHeight() -> ToastUtility.Builder {
            updateFrame()
            return self
        }
        
        func show() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.controller.view.addSubview(self.toast)
                self.controller.view.bringSubviewToFront(self.toast)
                
                UIView.animate(
                    withDuration: self.hideAnimationDuration,
                    delay: self.screenTime,
                    options: .curveEaseOut,
                    animations: {
                        self.toast.alpha = 0.0
                    },
                    completion: { _ in
                        self.toast.removeFromSuperview()
                    }
                )
            }
        }
        
        private func defaultSetup() {
            toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toast.textColor = .white
            toast.textAlignment = .center
            toast.font = UIFont.systemFont(ofSize: 14)
            toast.layer.cornerRadius = 8
            toast.clipsToBounds = true
        }
        
        private func updateFrame() {
            let safeBottom = controller.view.safeAreaInsets.bottom
            let textHeight = (toast.text ?? "").height(withConstrainedWidth: maxWidth, font: toast.font)
            toast.frame = CGRect(
                x: (controller.view.frame.width - maxWidth) / 2,
                y: controller.view.frame.height - (textHeight + 40 + safeBottom),
                width: maxWidth,
                height: textHeight + 20
            )
        }
    }
}

// MARK: - SwiftUI Toast
struct Toast<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    let message: String
    let presenting: () -> Presenting
    
    var body: some View {
        ZStack(alignment: .bottom) {
            presenting()
            
            if isShowing {
                Text(message)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.isShowing = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        Toast(isShowing: isShowing, message: message, presenting: { self })
    }
}

// MARK: - String Extension for UIKit Dynamic Height
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

