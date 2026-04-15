//
//  TextInputTextEditor.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 11/4/26.
//

import SwiftUI

struct TextInputTextEditor: View {
    let placeholder: String
    let maxLength: Int
    
    @Binding var text: String
    // Biến để theo dõi trạng thái tap/focus của TextEditor
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused($isFocused)
                .padding(12)
                .frame(height: 160)
                .font(.title3)
                .foregroundStyle(.white)
                .background(Color.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 12))
                .scrollContentBackground(.hidden)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
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
                .overlay(alignment: .topLeading, content: {
                    if !text.isEmpty || isFocused {
                        Text(placeholder)
                        .padding(.horizontal, 3)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: 160, alignment: .leading)
                        .lineLimit(1)
                        .background(Color.backgroundColor)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.leading, 20)
                        .padding(.top , -8)
                    }
                })
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
            } else {
                
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    // Để preview với @Binding, sử dụng @State trong một wrapper hoặc dùng .constant
    struct PreviewWrapper: View {
        @State private var text = ""
        var body: some View {
            TextInputTextEditor(
                placeholder: "Describe your problem...",
                maxLength: 500, text: $text
            )
                .padding()
                .background(Color.black)
        }
    }
    
    return PreviewWrapper()
}
