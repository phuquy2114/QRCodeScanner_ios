//
//  TextThemeTextEditor.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import SwiftUI
struct TextThemeTextEditor: View {
    let placeholder: String
    let maxLength: Int
    var annotation: String? = nil
    @Binding var text: String
    // Biến để theo dõi trạng thái tap/focus của TextEditor
    @FocusState private var isFocused: Bool
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let annotation = annotation {
                Text(annotation)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.leading, 2)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                    .padding(.top, 8)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 12))
                    .scrollContentBackground(.hidden)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isFocused ? theme.accent : Color.gray,
                                lineWidth: 1
                            )
                    )
                    // Thêm bộ đếm ký tự vào overlay góc dưới phải của chính TextEditor
                    .overlay(alignment: .bottomTrailing) {
                        Text("\(text.count)/\(maxLength)")
                            .font(.caption)
                            .foregroundStyle(
                                text.count >= maxLength ? .red : .gray)
                            .padding(.trailing, 8)
                            .padding(.bottom, 2)
                    }
                    .padding(.horizontal, 2)
                    // Giới hạn 500 ký tự khi người dùng nhập
                    .onChange(of: text) { newValue in
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                
                // Hiển thị placeholder nếu text rỗng VÀ không được focus (chưa tap vào)
                if text.isEmpty && !isFocused {
                    Text(placeholder)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.5)) // Màu mờ
                        .padding(.top, 14) // Căn chỉnh Y cho khớp với TextEditor (tuỳ chỉnh lại nếu cần)
                        .padding(.leading, 22) // Căn chỉnh X cho khớp với TextEditor đã có padding
                        .allowsHitTesting(false) // Bỏ qua tap để xuyên xuống TextEditor
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

