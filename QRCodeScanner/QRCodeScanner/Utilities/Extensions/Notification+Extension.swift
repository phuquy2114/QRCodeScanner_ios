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
    static let languageDidChange = Notification.Name(Constants.languageDidChange)
    
    static let themeDidChange = Notification.Name(Constants.themeDidChange)
}
