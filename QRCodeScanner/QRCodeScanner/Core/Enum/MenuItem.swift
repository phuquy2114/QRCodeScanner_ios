//
//  MenuItem.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import UIKit

enum MenuItem : Int, CaseIterable {
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
            return UIImage(named: "")
        case .history:
            return UIImage(named: "")
        case .createQRCode:
            return UIImage(named: "")
        case .favorite:
            return UIImage(named: "")
        case .settings:
            return UIImage(named: "")
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
