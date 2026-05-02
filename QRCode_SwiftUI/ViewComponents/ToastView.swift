//
//  ToastView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 26/4/26.
//

import SwiftUI

struct ToastView: View {
    @EnvironmentObject var theme: ThemeManager
    
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "qrcode")
                .font(.body)
                .foregroundStyle(theme.accent)
            Spacer().frame(width: 8)
            Text(message)
                .font(.body)
                .foregroundColor(.white)

        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.25))
        )
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
