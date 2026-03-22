//
//  MenuItem.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import UIKit

enum AppTab: Int, CaseIterable {
    case qrCodeScanner = 0
    case history = 1
    case createQRCode = 2
    case favorite = 3
    case settings = 4

    func title() -> String {
        switch self {
        case .qrCodeScanner:
            return "Scan"
        case .history:
            return "History"
        case .createQRCode:
            return "Create"
        case .favorite:
            return "Favorite"
        case .settings:
            return "Settings"
        }
    }

    func icon() -> UIImage? {
        switch self {
        case .qrCodeScanner:
            return UIImage(systemName: "qrcode.viewfinder")
        case .history:
            return UIImage(systemName: "clock.arrow.circlepath")
        case .createQRCode:
            return UIImage(systemName: "qrcode")
        case .favorite:
            return UIImage(systemName: "heart.fill")
        case .settings:
            return UIImage(systemName: "gearshape.fill")
        }
    }

    func viewController() -> UIViewController {
        switch self {
        case .qrCodeScanner:
            return QRCodeScannerViewController()
        case .history:
            return HistoryViewController()
        case .createQRCode:
            return CreateQRCodeViewController()
        case .favorite:
            return FavoriteViewController()
        case .settings:
            return SettingsViewController()
        }
    }
}
