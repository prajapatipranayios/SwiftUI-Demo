import SwiftUI

// MARK: - Toast Model
struct Toast: Equatable {
    let style: ToastStyle
    let message: String
    let position: ToastPosition

    var duration: Double = 3
    var width: CGFloat = .infinity
}

// MARK: - Toast Style
enum ToastStyle {
    case success, error, warning, info

    var backgroundColor: Color {
        switch self {
        case .success: return Color.green
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        }
    }

    var textColor: Color {
        return .white
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}

// MARK: - Toast Position
enum ToastPosition {
    case top
    case center
    case bottom
}

// MARK: - Toast View (UI ONLY)
struct ToastView: View {

    let toast: Toast
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: toast.style.icon)
                .foregroundColor(toast.style.textColor)

            Text(toast.message)
                .font(.caption)
                .foregroundColor(toast.style.textColor)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 8)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(toast.style.textColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: min(toast.width, UIScreen.main.bounds.width - 32))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toast.style.backgroundColor)
        )
        .shadow(radius: 6)
        .padding(.horizontal, 16)
    }
}

// MARK: - Local Toast Modifier
struct ToastModifier: ViewModifier {

    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let toast {
                toastContainer(toast)
                    .transition(.opacity)
            }
        }
        .onChange(of: toast) { _ in
            show()
        }
        .animation(.easeInOut, value: toast)
    }

    @ViewBuilder
    private func toastContainer(_ toast: Toast) -> some View {
        VStack {
            if toast.position == .top {
                ToastView(toast: toast, onDismiss: dismiss)
                Spacer()
            }

            if toast.position == .center {
                Spacer()
                ToastView(toast: toast, onDismiss: dismiss)
                Spacer()
            }

            if toast.position == .bottom {
                Spacer()
                ToastView(toast: toast, onDismiss: dismiss)
            }
        }
        .padding(.top, toast.position == .top ? 10 : 0)
        .padding(.bottom, toast.position == .bottom ? 10 : 0)
    }

    private func show() {
        guard let toast else { return }

        workItem?.cancel()

        let task = DispatchWorkItem { dismiss() }
        workItem = task

        DispatchQueue.main.asyncAfter(
            deadline: .now() + toast.duration,
            execute: task
        )
    }

    private func dismiss() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}

// MARK: - View Extension
extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}

// =======================================================
// MARK: - GLOBAL TOAST
// =======================================================

final class ToastManager: ObservableObject {

    static let shared = ToastManager()

    @Published var toast: Toast?
    private var workItem: DispatchWorkItem?

    private init() {}

    func show(
        style: ToastStyle,
        message: String,
        position: ToastPosition = .top,
        duration: Double = 3,
        width: CGFloat = .infinity
    ) {
        workItem?.cancel()

        toast = Toast(
            style: style,
            message: message,
            position: position,
            duration: duration,
            width: width
        )

        let task = DispatchWorkItem {
            withAnimation {
                self.toast = nil
            }
        }

        workItem = task
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration,
            execute: task
        )
    }
}

// MARK: - Global Toast Host View
struct GlobalToastView: View {

    @ObservedObject private var manager = ToastManager.shared

    var body: some View {
        ZStack {
            if let toast = manager.toast {
                VStack {
                    if toast.position == .top {
                        ToastView(toast: toast) {
                            withAnimation { manager.toast = nil }
                        }
                        Spacer()
                    }

                    if toast.position == .center {
                        Spacer()
                        ToastView(toast: toast) {
                            withAnimation { manager.toast = nil }
                        }
                        Spacer()
                    }

                    if toast.position == .bottom {
                        Spacer()
                        ToastView(toast: toast) {
                            withAnimation { manager.toast = nil }
                        }
                    }
                }
                .padding(.top, toast.position == .top ? 10 : 0)
                .padding(.bottom, toast.position == .bottom ? 10 : 0)
            }
        }
        .animation(.easeInOut, value: manager.toast)
    }
}
