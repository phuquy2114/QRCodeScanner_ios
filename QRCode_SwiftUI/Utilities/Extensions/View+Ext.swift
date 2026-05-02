//
//  View+Ext.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 4/4/26.
//

import SwiftUI

extension View {

    /// Gắn error sheet vào bất kỳ view nào
    func withErrorSheet(
        isPresented: Binding<Bool>,
        error: AppError?,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            if let error {
                AppErrorSheet(error: error, onDismiss: onDismiss)
            }
        }
    }

    /// Loading overlay toàn màn hình
    func withLoadingOverlay(isLoading: Bool, message: String = "Loading...") -> some View {
        self.overlay {
            if isLoading {
                LoadingOverlay(message: message)
            }
        }
    }
}

// MARK: - Button style helper
extension View {
    func appButtonStyle(color: Color, foreground: Color) -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .foregroundStyle(foreground)
            .clipShape(.rect(cornerRadius: 12))
    }
    
    func marginBottom() -> some View {
        self.padding(.bottom, 95)
    }
}

// MARK: - View extension
extension View {
    /// Inject theme vào toàn bộ cây view
    func withTheme() -> some View {
        self.environmentObject(ThemeManager.shared)
    }

    /// Tint theo theme hiện tại — dùng thay cho .tint(.yellow) cứng
    func themeTinted() -> some View {
        self.modifier(ThemeTintModifier())
    }
}
