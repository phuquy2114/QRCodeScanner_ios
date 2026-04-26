//
//  ToastModifier.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 26/4/26.
//

import SwiftUI
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content // View gốc
            
            if isShowing {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .padding(.bottom, 100) // Khoảng cách từ đáy màn hình
                }
                .onAppear {
                    // Tự động ẩn sau 2 giây
                    Task { @MainActor in
                        try await Task.sleep(for: .seconds(2))
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
    }
}

// Tạo extension để gọi dễ dàng hơn
extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
