//
//  TabItem.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 4/4/26.
//

import SwiftUI

struct TabItem: View {
    @EnvironmentObject private var theme: ThemeManager
    let title: String
    let icon: Image?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let icon = icon {
                    icon.renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(isSelected ? theme.accent : .gray)
                }
                Text(title).font(
                    .system(size: 13, weight: isSelected ? .bold : .medium)
                )
                // Tự động căn đều các nút bằng frame vô cực
                .frame(maxWidth: .infinity)
                .foregroundStyle(isSelected ? theme.accent : .gray)
                // Tăng diện tích chạm (hit area) cho user dễ bấm
                .contentShape(Rectangle())

            }.padding(.vertical, 12)
        }.buttonStyle(.plain)
    }
}
