//
//  CreateQRWifiViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import Combine
import Foundation

@MainActor
class CreateQRWifiViewModel: BaseCreateQRViewModel {
    @Published var networkName: String = ""
    @Published var password: String = ""
    @Published var securityType: SecurityType = .wpa_wpa2

    override func handleCreateQR() {
        // 1. Validation
        // Network Name bắt buộc phải có
        var rules: [ValidationRule] = [
            .nonEmpty(networkName, fieldName: "Network Name (SSID)")
        ]

        // Nếu Security khác None, bắt buộc phải có Password
        if securityType != .none {
            rules.append(.nonEmpty(password, fieldName: "Password"))
        }

        guard validate(rules) else { return }

        // 2. Format chuỗi chuẩn WIFI
        // Định dạng: WIFI:S:<SSID>;T:<WPA|WEP|nopass>;P:<PASSWORD>;H:<true|false>;;

        // Đổi loại bảo mật ra mã hệ thống chuẩn của Wifi QR
        let typeString: String
        switch securityType {
        case .wpa_wpa2: typeString = "WPA"
        case .wep: typeString = "WEP"
        case .none: typeString = "nopass"
        }

        var wifiString = "WIFI:S:\(networkName);T:\(typeString);"

        if securityType != .none {
            wifiString += "P:\(password);"
        }

        // Thêm dấu chấm phẩy kép cuối cùng để đóng chuỗi theo chuẩn
        wifiString += ";"

        // 3. Sinh mã QR
        generateQR(data: wifiString)
    }

    override var qrRawContent: String {
        var details: [String] = [
            "Network: \(networkName)",
            "Security: \(securityType.title)",
        ]

        if securityType != .none && !password.isEmpty {
            details.append("Password: \(password)")
        }

        return details.joined(separator: "\n")
    }
}

enum SecurityType: String, CaseIterable {
    case wpa_wpa2, wep, none

    var title: String {
        switch self {
        case .wpa_wpa2:
            return "WPA/WPA2"
        case .wep:
            return "WEP"
        case .none:
            return "None"
        }
    }
}
