//
//  KeychainHelper.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

// MARK: ──────────────────────────────────────────
// MARK: - KeychainHelper  (lưu token an toàn)
// ──────────────────────────────────────────────

import Foundation

final class KeychainHelper: @unchecked Sendable {

    nonisolated static let shared = KeychainHelper()
    private init() {}

    nonisolated func set(_ value: String?, key: String) {
        guard let value else { delete(key: key); return }
        let data = value.data(using: .utf8)!
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    nonisolated func get(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        return (result as? Data).flatMap { String(data: $0, encoding: .utf8) }
    }

    nonisolated func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    nonisolated func clearAll() {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword]
        SecItemDelete(query as CFDictionary)
    }
}
