//
//  CreateQREmailView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 30/4/26.
//

import SwiftUI

struct CreateQREmailView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQREmailViewModel()

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {

            // 1. Nhập địa chỉ Email nhận
            TextImageTextField(
                text: $viewModel.email,
                placeholder: "Email Address",
                annotation: "To",
                keyboardType: .emailAddress,
                icon: Image(systemName: "envelope.fill")
            )
            .autocapitalization(.none) // Tắt viết hoa chữ cái đầu cho email
            .disableAutocorrection(true)

            Spacer().frame(height: 24)
            
            // 2. Nhập tiêu đề
            TextImageTextField(
                text: $viewModel.subject,
                placeholder: "Subject",
                annotation: "Subject",
                keyboardType: .default,
                icon: Image(systemName: "doc.text.fill")
            )

            Spacer().frame(height: 24)

            // 3. Nhập nội dung
            TextThemeTextEditor(
                placeholder: "Compose email...",
                maxLength: viewModel.maxLength,
                annotation: "Content",
                text: $viewModel.content
            ).frame(height: 160)
        }
    }
}
