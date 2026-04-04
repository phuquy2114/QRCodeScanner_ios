//
//  Components.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 4/4/26.
//

import SwiftUI

// MARK: ══════════════════════════════════════════
// MARK: PHẦN 4 — COMMON SWIFTUI COMPONENTS
// Các component hay dùng, reactive với AppTheme
// ══════════════════════════════════════════════

// MARK: - QRCard  (card container chuẩn)
struct QRCard<Content: View>: View {
    let content: Content
    var padding: EdgeInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
    var cornerRadius: CGFloat = 14

    init(padding: EdgeInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16),
         @ViewBuilder content: () -> Content) {
        self.content      = content()
        self.padding      = padding
    }

    var body: some View {
        content
            .padding(padding)
            .background(Color(UIColor(white: 0.14, alpha: 1)))
            .cornerRadius(cornerRadius)
    }
}

// MARK: - AccentButton  (button màu accent, reactive theme)

struct AccentButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    @EnvironmentObject private var theme: AppThemeObservable

    init(title: String,
         isLoading: Bool = false,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.title     = title
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action    = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                theme.themeColor
                    .opacity(isEnabled ? 1 : 0.5)
                    .cornerRadius(14)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(theme.themeColor)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.themeColor)
                }
            }
        }
        .frame(height: 54)
        .disabled(!isEnabled || isLoading)
    }
}

// MARK: - QRTextField

struct QRTextField: View {
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default

    @EnvironmentObject private var theme: AppThemeObservable

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 52)
                .background(Color(UIColor(white: 0.15, alpha: 1)))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                )
                .keyboardType(keyboardType)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - QRToggleRow

struct QRToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    @EnvironmentObject private var theme: AppThemeObservable

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 17))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(theme.themeColor)
        }
        .frame(height: 52)
    }
}

// MARK: - QRSectionHeader

struct QRSectionHeader: View {
    let title: String
    var isAccent: Bool = false

    @EnvironmentObject private var theme: AppThemeObservable

    var body: some View {
        Text(title)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(isAccent ? theme.themeColor : .white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - QREmptyState

struct QREmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    @EnvironmentObject private var theme: AppThemeObservable

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(theme.themeColor)

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor(white: 0.6, alpha: 1)))
                .multilineTextAlignment(.center)

            if let actionTitle, let onAction {
                AccentButton(title: actionTitle, action: onAction)
                    .frame(width: 180)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - QRLoadingOverlay

struct QRLoadingOverlay: View {
    let isShowing: Bool
    var message: String = "Đang tải..."

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.4)
                        .tint(.white)
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(28)
                .background(Color(UIColor(white: 0.15, alpha: 1)))
                .cornerRadius(16)
            }
        }
    }
}

// MARK: - ViewState + SwiftUI helper

extension ViewState {
    var isLoadingState: Bool { self == .loading }
    var errorMsg: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}

// MARK: - View Modifiers

struct QRBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor(white: 0.06, alpha: 1)))
            .preferredColorScheme(.dark)
    }
}

extension View {
    /// Apply dark background chuẩn của app
    func qrBackground() -> some View {
        modifier(QRBackground())
    }

    /// Show loading overlay
    func loadingOverlay(isShowing: Bool, message: String = "Đang tải...") -> some View {
        overlay(QRLoadingOverlay(isShowing: isShowing, message: message))
    }

    /// Show error alert từ ViewState
    func viewStateAlert(state: ViewState, onDismiss: @escaping () -> Void) -> some View {
        alert("Lỗi", isPresented: .constant(state.isError)) {
            Button("OK") { onDismiss() }
        } message: {
            Text(state.errorMsg ?? "")
        }
    }
}
