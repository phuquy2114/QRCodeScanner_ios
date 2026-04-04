//
//  AppThemeColor.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//

import UIKit

enum AppThemeColor: String, CaseIterable, Codable {
    case yellow
    case blue
    case green
    case orange
    case red

    func color() -> UIColor {
        switch self {
        case .yellow:
            return UIColor(hex: "#FFBF1A")
        case .blue:
            return UIColor(hex: "#3B8BFF")
        case .green:
            return UIColor(hex: "#2ECC71")
        case .orange:
            return UIColor(hex: "#FF6B35")
        case .red:
            return UIColor(hex: "#FF3B30")
        }
    }

    /*
    /// Màu text trên nền theme (đảm bảo contrast)
    func onThemeColor() -> UIColor {
        switch self {
        case .yellow, .green, .orange:
            return .black
        case .blue, .red:
            return .white
        }
    }
     */
}
