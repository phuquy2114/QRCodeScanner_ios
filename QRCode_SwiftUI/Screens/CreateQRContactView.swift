//
//  CreateQRContactView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import SwiftUI

struct CreateQRContactView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRContactViewModel()

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {
            
            // 1. Trường nhập Tên
            TextImageTextField(
                text: $viewModel.myName,
                placeholder: "Full Name",
                annotation: "Name",
                keyboardType: .default,
                icon: Image(systemName: "person.fill")
            )

            Spacer().frame(height: 24)
            
            // 2. Trường nhập Số điện thoại
            TextImageTextField(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                annotation: "Phone Number",
                keyboardType: .numberPad,
                icon: Image(systemName: "phone.fill")
            )

            Spacer().frame(height: 24)
            
            // 3. Trường nhập Email
            TextImageTextField(
                text: $viewModel.email,
                placeholder: "Email Address",
                annotation: "Email",
                keyboardType: .emailAddress, // Bật bàn phím có sẵn phím @
                icon: Image(systemName: "envelope.fill")
            )
            // Tắt tự động viết hoa chữ cái đầu cho ô Email
            .autocapitalization(.none) 
            .disableAutocorrection(true)
        }
    }
}
