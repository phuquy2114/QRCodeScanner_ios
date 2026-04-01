//
//  HelpSetting.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 30/3/26.
//

import UIKit

enum HelpSetting: Int, CaseIterable {
    case faq = 0
    case feedback = 1
    case rateUs = 2
    case share = 3
    case privacyPolicy = 4
    case termsOfUse = 5
    
    var title: String {
        switch self {
        case .faq:
            return "FAQ"
        case .feedback:
            return "Feedback"
        case .rateUs:
            return "Rate Us"
        case .share:
            return "Share"
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of use"
        }
    }
    
    var description: String? {
        switch self {
        case .faq, .privacyPolicy , .termsOfUse:
            return nil
        case .feedback:
            return "Report bugs and tell us what to improve"
        case .rateUs:
            return "Your best reward to us."
        case .share:
            return "Share app with others"
        }
    }
    
    var controller: UIViewController? {
        switch self {
        case .rateUs, .share, .privacyPolicy, .termsOfUse:
            return nil
        case .faq:
            return UIViewController()
        case .feedback:
            return UIViewController()
        }
    }
}
