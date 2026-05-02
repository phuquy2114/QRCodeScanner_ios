//
//  CreateQREmailViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 30/4/26.
//

import Combine
import Foundation

@MainActor
class CreateQREmailViewModel: BaseCreateQRViewModel {
    @Published var email: String = ""
    @Published var subject: String = ""
    @Published var content: String = ""

    override func handleCreateQR() {
        // 1. Áp dụng ValidationRule
        // Đối với Email, thường Subject và Content có thể rỗng nên ta chỉ bắt buộc kiểm tra Email
        let rules: [ValidationRule] = [
            .isEmail(email, fieldName: "Email Address")
        ]

        // Nếu validate thất bại thì dừng lại
        guard validate(rules) else { return }

        // 2. Tạo chuỗi chuẩn MATMSG dành cho Email
        // Chuẩn này được hầu hết các app quét QR hỗ trợ cực tốt
        let mailString = "MATMSG:TO:\(email);SUB:\(subject);BODY:\(content);;"

        // 3. Gọi hàm sinh mã QR
        generateQR(data: mailString)
    }

    override var qrRawContent: String {
        var details: [String] = ["To: \(email)"]

        if !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("Subject: \(subject)")
        }

        if !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("Message: \(content)")
        }

        return details.joined(separator: "\n")
    }
}
