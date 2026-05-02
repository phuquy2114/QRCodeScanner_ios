//
//  CreateQRContactViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import Combine

@MainActor
class CreateQRContactViewModel: BaseCreateQRViewModel {
    @Published var myName: String = ""
    @Published var phoneNumber: String = ""
    @Published var email: String = ""

    override func handleCreateQR() {
        // 1. Áp dụng ValidationRule
        let rules: [ValidationRule] = [
            .nonEmpty(myName, fieldName: "Name"),
            // THAY ĐỔI Ở ĐÂY: Dùng luật isPhoneNumber
            .isPhoneNumber(phoneNumber, fieldName: "Phone Number"),
            .isEmail(email, fieldName: "Email"),
        ]

        // Nếu validate thất bại thì dừng lại
        guard validate(rules) else { return }

        // 2. Tạo chuỗi chuẩn vCard (Chuẩn quốc tế để lưu Danh bạ)
        let vCardString = """
            BEGIN:VCARD
            VERSION:3.0
            FN:\(myName)
            TEL:\(phoneNumber)
            EMAIL:\(email)
            END:VCARD
            """

        // 3. Gọi hàm sinh mã QR
        generateQR(data: vCardString)
    }

    override var qrRawContent: String {
        return "My name: \(myName)\nPhone: \(phoneNumber)\nEmail: \(email)"
    }
}
