//
//  TextImageTextField.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import SwiftUI

struct TextImageTextField: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @EnvironmentObject var theme: ThemeManager
    var placeholder: String?
    var keyboardType: UIKeyboardType?
    var icon: Image?

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField(placeholder ?? "", text: $text)
                .focused($isFocused)
                .keyboardType(keyboardType ?? .default)
                .frame(height: 60)
                .padding(.leading, (icon != nil) ? 48 : 16)
                .font(.title2)
                .overlay(alignment: .leading) {
                    if let icon = icon {
                        icon.resizable()
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? theme.accent : Color.gray.opacity(0.5),
                            lineWidth: 2
                        )
                )
            if isFocused {
                Text(placeholder ?? "")
                    .font(.callout)
                    .frame(maxWidth: 200)
                    .foregroundStyle(theme.accent)
                    .padding(.horizontal, 3)
                    .background(Color.black)
                    .padding(.leading, 12)
                    .padding(.top, -10)
            }
        }
    }

}

