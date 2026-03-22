//
//  UIView+Extension.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

import UIKit
extension UIView {
    /// Gán màu accent hiện tại, tự động cập nhật khi theme đổi
    /// Ví dụ: myButton.applyAccentBackground()
    func applyAccentBackground() {
        //backgroundColor = ThemeManager.shared.themeColor
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.backgroundColor = notification.object as? UIColor
        }
    }

    func applyAccentTint() {
        if let iv = self as? UIImageView {
            iv.tintColor = ThemeManager.shared.themeColor
        } else {
            tintColor = ThemeManager.shared.themeColor
        }
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            let color = notification.object as? UIColor
            if let iv = self as? UIImageView { iv.tintColor = color }
            else { self?.tintColor = color }
        }
    }
}

extension UILabel {
    func applyAccentColor() {
        textColor = ThemeManager.shared.themeColor
        NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.textColor = notification.object as? UIColor
        }
    }
}
