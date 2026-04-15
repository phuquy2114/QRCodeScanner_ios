//
//  ButtonTheme.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 8/4/26.
//

import SwiftUI

struct ButtonTheme: View {
    @EnvironmentObject var theme: ThemeManager
    // Lấy trạng thái từ modifier .disabled() truyền vào
    @Environment(\.isEnabled) private var isEnabled
    
    let title: String
    var titleColor: Color?
    var radius: CGFloat?
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52)
                // Đổi màu chữ theo trạng thái nếu không truyền titleColor
                .foregroundStyle(titleColor ?? (isEnabled ? .black : .white))
        }
        // Đổi màu background theo trạng thái isEnabled
        .background(isEnabled ? theme.accent : Color.gray, in: .rect(cornerRadius: radius ?? 12))
        .clipShape(.rect(cornerRadius: radius ?? 12))
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}

#Preview {
    ButtonTheme(
        title: "STILL STILLSTILLSTILL",
        titleColor: .black,
        onTap: {

        }
    ).withTheme()
}
