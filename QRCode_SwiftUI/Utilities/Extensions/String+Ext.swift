//
//  String+Ext.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import Foundation

extension String {
    /// Hàm tiện ích dùng để trích xuất giá trị từ một chuỗi nhiều dòng, dựa trên tiền tố (prefix).
    /// Ví dụ: Nếu chuỗi có dòng "Password: 123", gọi extractValue(for: "Password: ") sẽ trả về "123".
    func extractValue(for prefix: String) -> String {
        let lines = self.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix(prefix) {
                return String(line.dropFirst(prefix.count))
            }
        }
        return ""
    }
    
}
