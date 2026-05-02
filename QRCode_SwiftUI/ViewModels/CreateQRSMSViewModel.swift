//
//  CreateQRSMSViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import Combine

@MainActor
class CreateQRSMSViewModel: BaseCreateQRViewModel {
    @Published var phoneNumber: String = ""
    @Published var message: String = ""

    override func handleCreateQR() {
        // 1. Áp dụng ValidationRule bạn vừa tạo
        let rules: [ValidationRule] = [
            .nonEmpty(phoneNumber, fieldName: "Phone Number"),
            .nonEmpty(message, fieldName: "Message"),
        ]

        // Nếu validate thất bại (trả về false), hàm validate() bên BaseViewModel
        // sẽ tự động gọi presentError() -> tự động bật showError = true
        guard validate(rules) else { return }

        // 2. Nếu qua được cửa kiểm tra -> Tiến hành tạo QR
        let smsString = "SMSTO:\(phoneNumber):\(message)"
        generateQR(data: smsString)
    }

    override var qrRawContent: String {
        return "Phone: \(phoneNumber)\nMessage: \(message)"
    }
}
