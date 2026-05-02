//
//  CreateQREventView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import SwiftUI

struct CreateQREventView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQREventViewModel()
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {
            TextImageTextField(
                text: $viewModel.title,
                placeholder: "Please enter something",
                annotation: "Title",
            )

            Spacer().frame(height: 24)

            // 2. Nhóm cấu hình thời gian (All Day, Start, End)
            buildDay()

            Spacer().frame(height: 24)
            TextThemeTextEditor(
                placeholder: "Please enter something",
                maxLength: viewModel.maxLength,
                annotation: "Description",
                text: $viewModel.desc
            ).frame(height: 160)
        }
    }

    private func buildText(title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.leading, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buildDay() -> some View {
        VStack(spacing: 16) {

            // Công tắc All Day
            Toggle(isOn: $viewModel.isAllDay) {
                Text("All day")
                    .font(.headline)
                    .foregroundStyle(.white)
            }.tint(theme.accent)

            Divider().background(Color.gray.opacity(0.5))

            // Chọn ngày bắt đầu
            DatePicker(
                "Start",
                selection: $viewModel.startDate,
                // Nếu "All day" bật thì chỉ chọn Ngày, nếu tắt thì chọn cả Ngày + Giờ
                displayedComponents: viewModel.isAllDay
                    ? [.date] : [.date, .hourAndMinute]
            )
            .font(.headline)
            .foregroundStyle(.white)
            .colorScheme(.dark)  // Ép giao diện DatePicker sang màu tối cho hợp với nền đen

            Divider().background(Color.gray.opacity(0.5))

            // Chọn ngày kết thúc
            DatePicker(
                "End",
                selection: $viewModel.endDate,
                // Nếu "All day" bật thì chỉ chọn Ngày, nếu tắt thì chọn cả Ngày + Giờ
                displayedComponents: viewModel.isAllDay
                    ? [.date] : [.date, .hourAndMinute]
            )
            .font(.headline)
            .foregroundStyle(.white)
            .colorScheme(.dark)

        }
        .padding()
        .background(Color.gray.opacity(0.2))  // Khối nền xám bao quanh
        .clipShape(.rect(cornerRadius: 12))
    }

}
