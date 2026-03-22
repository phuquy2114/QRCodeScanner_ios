//
//  String+Extension.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

// MARK: - String Localization Extension
import Foundation

public extension String {
    
    /// Trả về string đã được dịch theo ngôn ngữ hiện tại
    /// Ví dụ: "login_button".localized
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: LanguageManager.shared.currentBundle, value: self, comment: "")
    }
    
    /// Trả về string có tham số truyền vào
    /// Ví dụ: "welcome_user".localized(with: "Nghia") -> "Chào mừng Nghia"
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
}
