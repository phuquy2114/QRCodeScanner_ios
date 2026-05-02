//
//  CreateQRTelephoneView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import SwiftUI

struct CreateQRTelephoneView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRTelephoneViewModel()

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {

            // 1. Ô nhập số điện thoại
            TextImageTextField(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                annotation: "Phone Number",
                keyboardType: .numberPad,
                icon: Image(systemName: "phone.fill")
            )
            
            // Có thể thêm ghi chú nhỏ để hướng dẫn người dùng
            Text("Scanning this QR code will automatically prompt the user to call this number.")
                .font(.callout)
                .foregroundStyle(.gray)
                .padding(.leading, 2)
                .padding(.top, 12)
        }
    }
}
