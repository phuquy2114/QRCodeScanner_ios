//
//  CreateQRBusinessView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import SwiftUI

struct CreateQRBusinessView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRBusinessViewModel()

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {

            buildTextField(
                text: $viewModel.name,
                placeholder: "Full Name",
                icon: "person.fill"
            )
            Spacer().frame(height: 24)
            buildTextField(
                text: $viewModel.phoneNumber,
                placeholder: "Phone Number",
                icon: "phone.fill",
                keyboardType: .numberPad
            )

            Spacer().frame(height: 24)

            buildTextField(
                text: $viewModel.email,
                placeholder: "Email Address",
                icon: "envelope.fill",
                keyboardType: .emailAddress
            )

            Spacer().frame(height: 24)

            buildTextField(
                text: $viewModel.address,
                placeholder: "Address",
                icon: "map.fill"
            )

            Spacer().frame(height: 24)

            // --- GIAO DIỆN CHỌN NGÀY SINH (DATE PICKER) ---
            Text("Birthday")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.leading, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer().frame(height: 6)
            
            HStack {
                Image(systemName: "gift.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray)

                DatePicker(
                    "Birthday",
                    selection: $viewModel.birthday,
                    displayedComponents: .date  // Chỉ lấy Ngày Tháng Năm
                )
                .font(.title3)
                .foregroundStyle(.white)
                .colorScheme(.dark)  // Ép lịch sang màu tối
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background(Color.gray.opacity(0.2))
            .clipShape(.rect(cornerRadius: 12))

            Spacer().frame(height: 24)
            buildTextField(
                text: $viewModel.organization,
                placeholder: "Organization / Company",
                icon: "building.2.fill"
            )

            Spacer().frame(height: 24)
            TextThemeTextEditor(
                placeholder: "Enter any extra information here...",
                maxLength: viewModel.maxLength,
                annotation: "Note",
                text: $viewModel.note,
            ).frame(height: 160)

        }
    }

    // MARK: - Helper Builder

    private func buildTextField(
        text: Binding<String>,
        placeholder: String,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextImageTextField(
            text: text,
            placeholder: placeholder,
            annotation: placeholder,
            keyboardType: keyboardType,
            icon: Image(systemName: icon)
        )
        // Nếu là ô nhập Email, tự động tắt viết hoa chữ cái đầu và tắt sửa lỗi chính tả
        .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        .disableAutocorrection(keyboardType == .emailAddress)
    }
}
