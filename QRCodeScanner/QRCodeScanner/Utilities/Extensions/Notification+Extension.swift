//
//  Notification+Extension.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//

import UIKit

// MARK: - Notifications
public extension Notification.Name {
    // LanguageManager.shared.currentLanguage = .english
    static let languageDidChange = Notification.Name("app_language_did_change")
    
    static let themeDidChange = Notification.Name("theme_did_change")
}
