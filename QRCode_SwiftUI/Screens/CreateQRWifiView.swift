//
//  CreateQRWifiView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import SwiftUI

struct CreateQRWifiView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRWifiViewModel()

    var body: some View {
        BaseLayoutCreateQRView(
            item: item,
            viewModel: viewModel
        ) {
            TextImageTextField(
                text: $viewModel.networkName,
                placeholder: "Network name (SSID)",
                annotation: "Network name"
            )

            Spacer().frame(height: 20)

            Text("Security")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.leading, 2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 6)

            buildDropdownList()

            Spacer().frame(height: 20)

            TextImageTextField(
                text: $viewModel.password,
                placeholder: "Password",
                annotation: "Password",
                keyboardType: .asciiCapable,  // Bàn phím gõ tiếng anh/số bình thường
                icon: Image(systemName: "lock.fill"),  // Đổi thành ổ khoá cho hợp
                isSecureField: true  // Bật chế độ mật khẩu lên
            )
        }
    }

    private func buildDropdownList() -> some View {
        // Bọc Picker vào trong Menu để chiếm toàn quyền thiết kế giao diện nút bấm
        Menu {
            Picker(
                "",
                selection: $viewModel.securityType
            ) {
                ForEach(SecurityType.allCases, id: \.self) { type in
                    Text(type.title).tag(type)  // Thêm .tag() để binding hiểu được giá trị
                }
            }
        } label: {
            // Đây là giao diện hiển thị của nút Dropdown
            HStack {
                Text(viewModel.securityType.title)
                    .font(.title2)
                    .foregroundStyle(.white)

                Spacer()

                // Icon mũi tên để người dùng biết đây là dropdown
                Image(systemName: "chevron.up.chevron.down")
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 16)
            .frame(height: 60)  // Đồng bộ chiều cao với TextImageTextField
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .clipShape(.rect(cornerRadius: 12))
            .contentShape(Rectangle())  // Ép SwiftUI nhận tap trên toàn bộ khung hình chữ nhật
        }
    }
}
