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
    var annotation: String? = nil
    var keyboardType: UIKeyboardType?
    var icon: Image?
    // Thêm 2 biến này để quản lý mật khẩu
    var isSecureField: Bool = false
    @State private var showPassword: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let annotation = annotation {
                Text(annotation)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.leading, 2)
            }

            ZStack(alignment: .topLeading) {
                Group {
                    if isSecureField && !showPassword {
                        // Dùng SecureField nếu là ô mật khẩu và chưa bật mắt
                        SecureField(
                            "",
                            text: $text,
                            prompt: Text(
                                (isFocused || !text.isEmpty)
                                    ? "" : (placeholder ?? "")
                            )
                            .foregroundColor(.gray)
                        )
                    } else {
                        TextField(
                            "",
                            text: $text,
                            // Ẩn placeholder chìm đi khi ô này đang được focus HOẶC đã có chữ
                            prompt: Text(
                                (isFocused || !text.isEmpty)
                                    ? "" : (placeholder ?? "")
                            )
                            .foregroundColor(.gray)
                        )
                    }
                }
                .focused($isFocused)
                .keyboardType(keyboardType ?? .default)
                // Nếu có icon thì chừa lề trái 48, không thì 16
                .padding(.leading, (icon != nil) ? 48 : 16)
                .padding(.trailing, isSecureField ? 58 : 16)
                .frame(height: 60)
                .font(.title2)
                .foregroundStyle(.white)
                .background(Color.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 12))  // Cắt nền xám bo góc
                
                // 2. ICON BÊN TRÁI
                .overlay(alignment: .leading) {
                    if let icon = icon {
                        icon
                            .resizable() // Bắt buộc để thay đổi size ảnh
                            .scaledToFit() // Căn vừa khung không méo tỷ lệ
                            .frame(width: 24, height: 24) // Ép cứng mọi icon về khung vuông 24x24
                            .foregroundColor(.gray)
                            .padding(.leading, 16)
                    }
                }
                
                // 3. NÚT CON MẮT (BÊN PHẢI) NẾU LÀ Ô PASSWORD
                .overlay(alignment: .trailing) {
                    if isSecureField {
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(
                                systemName: showPassword
                                    ? "eye.slash.fill" : "eye.fill"
                            )
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                        }
                    }
                }
                
                // 4. VIỀN (BORDER)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? theme.accent : Color.gray,
                            lineWidth: 1
                        )
                )

            }
        }
        .padding(.horizontal, 1)
    }

}
