//
//  CreateQRBusinessViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import Combine
import UIKit

@MainActor
class CreateQRBusinessViewModel: BaseCreateQRViewModel {
    @Published var name: String = ""
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var address: String = ""
    // Đổi thành kiểu Date để sử dụng được với DatePicker
    @Published var birthday: Date = Date()
    @Published var organization: String = ""
    // Thêm trường Note (Tuỳ chọn)
    @Published var note: String = ""

    override func handleCreateQR() {
        // 1. Áp dụng ValidationRule (không có `note` vì nó là option)
        let rules: [ValidationRule] = [
            .nonEmpty(name, fieldName: "Name"),
            .isPhoneNumber(phoneNumber, fieldName: "Phone Number"),
            .isEmail(email, fieldName: "Email"),
            .nonEmpty(organization, fieldName: "Organization"),
        ]

        // Nếu validate thất bại thì dừng lại
        guard validate(rules) else { return }

        // Format Date sang String định dạng chuẩn YYYY-MM-DD cho vCard
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthdayString = formatter.string(from: birthday)

        // 2. Tạo chuỗi chuẩn vCard dành cho Business
        let vCardString = """
            BEGIN:VCARD
            VERSION:3.0
            FN:\(name)
            ORG:\(organization)
            TEL:\(phoneNumber)
            EMAIL:\(email)
            ADR:;;\(address);;;;
            BDAY:\(birthdayString)
            NOTE:\(note)
            END:VCARD
            """

        // 3. Tạo QR Code
        generateQR(data: vCardString)
    }

    override var qrRawContent: String {
        // Format lại ngày sinh cho đẹp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let birthdayString = formatter.string(from: birthday)

        // Gom các trường bắt buộc
        var details: [String] = [
            "Company: \(organization)",
            "Name: \(name)",
            "Phone: \(phoneNumber)",
            "Email: \(email)",
            "Birthday: \(birthdayString)",
        ]

        // Kiểm tra nếu có nhập địa chỉ thì mới thêm vào danh sách
        if !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("Address: \(address)")
        }

        // Kiểm tra nếu có nhập ghi chú thì mới thêm vào danh sách
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("Note: \(note)")
        }

        // Nối tất cả các dòng lại với nhau bằng dấu xuống dòng (\n)
        return details.joined(separator: "\n")
    }
}
