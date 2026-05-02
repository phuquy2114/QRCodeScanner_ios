//
//  ValidationRule.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

// MARK: - ValidationRule
import Foundation

public struct ValidationRule {
    let validate: () -> AppError?

    /// Field không được rỗng
    static func nonEmpty(_ value: String, fieldName: String) -> ValidationRule {
        ValidationRule {
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? .emptyValue(
                    message: "\(fieldName) \("It cannot be left blank")"
                ) : nil
        }
    }

    /// Kiểm tra định dạng Số điện thoại hợp lệ
    static func isPhoneNumber(
        _ value: String,
        fieldName: String = "Phone Number"
    ) -> ValidationRule {
        ValidationRule {
            // Kiểm tra rỗng
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .emptyValue(message: "\(fieldName) cannot be left blank")
            }

            // Loại bỏ khoảng trắng và dấu gạch ngang (nếu người dùng có nhập) để kiểm tra cho chuẩn
            let cleanPhone = value.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "-", with: "")

            // Dùng Regex: Có thể bắt đầu bằng dấu + (optional), theo sau là 7 đến 15 chữ số
            let phoneRegex = "^\\+?[0-9]{7,15}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

            if !predicate.evaluate(with: cleanPhone) {
                return .invalidFormat(
                    message: "Please enter a valid \(fieldName)."
                )
            }

            return nil
        }
    }

    /// Kiểm tra định dạng Email hợp lệ
    static func isEmail(_ value: String, fieldName: String = "Email")
        -> ValidationRule
    {
        ValidationRule {
            // Kiểm tra rỗng trước
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return .emptyValue(message: "\(fieldName) cannot be left blank")
            }

            // Dùng Regex để kiểm tra chuẩn định dạng email
            let emailRegex =
                #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

            if value.range(of: emailRegex, options: .regularExpression) == nil {
                return .invalidFormat(
                    message: "Please enter a valid \(fieldName) address."
                )
            }

            return nil
        }
    }

    /// Độ dài tối đa
    static func maxLength(_ value: String, max: Int, fieldName: String)
        -> ValidationRule
    {
        ValidationRule {
            value.count > max
                ? .invalidFormat(
                    message: "\(fieldName) cannot exceed \(max) characters."
                ) : nil
        }
    }

    /// Custom rule (Kiểm tra tuỳ chỉnh bất kỳ)
    static func custom(condition: Bool, message: String) -> ValidationRule {
        ValidationRule { condition ? .invalidFormat(message: message) : nil }
    }
}
