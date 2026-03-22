//
//  UIScreen+Current.swift.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import UIKit

extension UIScreen {
    /// Thay thế UIScreen.main (deprecated iOS 16+)
    static var current: UIScreen {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen ?? .main
    }
}
