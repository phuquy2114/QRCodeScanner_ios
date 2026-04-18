//
//  SettingEnums.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 18/4/26.
//

import Foundation
import SwiftUI

enum ThemeColor: String, CaseIterable, Codable  {

    case yellow, blue, green, orange, red
    
    var displayName: String { rawValue.capitalized }
    
    func color() -> Color {
        switch self {
        case .yellow:
            return Color(hex: "#FFBF1A")
        case .blue:
            return Color(hex: "#3B8BFF")
        case .green:
            return Color(hex: "#2ECC71")
        case .orange:
            return Color(hex: "#FF6B35")
        case .red:
            return Color(hex: "#FF3B30")
        }
    }
}

enum SettingSound: String, CaseIterable, Codable {
    case vibrate, beep, autoFocus, touchFocus

    var displayName: String {
        switch self {
        case .vibrate, .beep:
            rawValue.capitalized
        case .autoFocus:
            "Auto Focus"
        case .touchFocus:
            "Touch Focus"
        }
    }

}

enum SettingHelp: String, CaseIterable, Codable {
    case faq, feedback, rateUs, share, privacyPolicy, termsOfUse

    var title: String {
        switch self {
        case .faq:
            return rawValue.uppercased()
        case .feedback, .share:
            return rawValue.capitalized
        case .rateUs:
            return "Rate Us"
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of use"
        }
    }

    var description: String? {
        switch self {
        case .faq, .privacyPolicy, .termsOfUse:
            return nil
        case .feedback:
            return "Report bugs and tell us what to improve"
        case .rateUs:
            return "Your best reward to us."
        case .share:
            return "Share app with others"
        }
    }
}
