//
//  CreateQRTelephoneViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import Combine
import Foundation

@MainActor
class CreateQRTelephoneViewModel: BaseCreateQRViewModel {
    @Published var phoneNumber: String = ""

    override func handleCreateQR() {
        // 1. Áp dụng ValidationRule kiểm tra số điện thoại hợp lệ
        let rules: [ValidationRule] = [
            .isPhoneNumber(phoneNumber, fieldName: "Phone Number")
        ]

        // Nếu validate thất bại thì dừng lại
        guard validate(rules) else { return }

        // 2. Tạo chuỗi chuẩn cho Cuộc gọi điện thoại
        // Loại bỏ mọi khoảng trắng hoặc gạch ngang thừa trước khi gen QR
        let cleanPhone = phoneNumber.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        let telString = "tel:\(cleanPhone)"

        // 3. Gọi hàm sinh mã QR
        generateQR(data: telString)
    }

    override var qrRawContent: String {
        return "Phone: \(phoneNumber)"
    }
}
