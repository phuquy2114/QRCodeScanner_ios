//
//  CreateQRWebsiteViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import Combine
import Foundation  // Thêm import Foundation để tránh lỗi xử lý String

@MainActor
class CreateQRWebsiteViewModel: BaseCreateQRViewModel {

    @Published var url: String = ""
    let www: String = "www."
    let com: String = ".com"

    override func handleCreateQR() {
        // Validation: Đảm bảo URL không bị bỏ trống
        let rules: [ValidationRule] = [
            .nonEmpty(url, fieldName: "URL Link")
        ]

        guard validate(rules) else { return }

        // Tạo mã QR từ URL (Camera mặc định của điện thoại sẽ tự động mở Safari/Trình duyệt)
        generateQR(data: self.url)
    }

    override var qrRawContent: String {
        // Trả thẳng URL về để hiển thị trong lịch sử / Detail
        return url
    }

    func onTapButton(value: String) {
        // Nút gõ tắt (VD: "www.", ".com")
        self.url += value
    }
}
