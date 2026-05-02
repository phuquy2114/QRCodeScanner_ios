//
//  CreateQRSMSView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 30/4/26.
//

import SwiftUI

struct CreateQRSMSView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRSMSViewModel()

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {

            TextImageTextField(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                annotation: "Phone Number",
                keyboardType: .numberPad,
                icon: Image(systemName: "phone.fill")
            )

            Spacer().frame(height: 24)

            TextThemeTextEditor(
                placeholder: "Please enter something",
                maxLength: 500,
                annotation: "Text message",
                text: $viewModel.message
            ).frame(height: 160)
        }
    }
}
