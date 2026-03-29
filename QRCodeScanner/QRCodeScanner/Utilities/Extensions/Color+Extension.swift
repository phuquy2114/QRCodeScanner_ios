//
//  Color+Extension.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8)  / 255
        let b = CGFloat( rgb & 0x0000FF)         / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    convenience init(hexWithAlpha: String) {
        var hexSanitized = hexWithAlpha.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var hexInt: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&hexInt)

        let r, g, b, a: CGFloat
        let length = hexSanitized.count

        if length == 8 {
            // Trường hợp mã màu 8 ký tự (RRGGBBAA) - ví dụ: 333333D6
            r = CGFloat((hexInt & 0xFF000000) >> 24) / 255
            g = CGFloat((hexInt & 0x00FF0000) >> 16) / 255
            b = CGFloat((hexInt & 0x0000FF00) >> 8)  / 255
            a = CGFloat(hexInt & 0x000000FF)         / 255
        } else if length == 6 {
            // Trường hợp mã màu 6 ký tự (RRGGBB) - ví dụ: 333333
            r = CGFloat((hexInt & 0xFF0000) >> 16) / 255
            g = CGFloat((hexInt & 0x00FF00) >> 8)  / 255
            b = CGFloat(hexInt & 0x0000FF)         / 255
            a = 1.0
        } else {
            // Mặc định trả về màu đen nếu mã màu không hợp lệ
            r = 0; g = 0; b = 0; a = 1.0
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
//    static let backgroundColor: UIColor = UIColor(white: 0.08, alpha: 1)
    static let backgroundColor: UIColor = UIColor(hexWithAlpha: "#333333D6")
    
}
