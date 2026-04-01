//
//  APIConfig.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//
// MARK: ──────────────────────────────────────────
// MARK: - APIConfig  (singleton cấu hình chung)
// ──────────────────────────────────────────────

import Foundation

final class APIConfig {
    static let shared = APIConfig()
    private init() {}

    var environment: APIEnvironment = .development
    var baseURL: String { environment.baseURL }
    var timeout: TimeInterval = 30
    var isLoggingEnabled: Bool { environment.isLoggingEnabled }

    /// Token lưu sau khi login — tự động gắn vào header
    /// nonisolated: KeychainHelper thread-safe, gọi được từ bất kỳ context nào
    nonisolated var accessToken: String? {
        get { KeychainHelper.shared.get(key: "access_token") }
        set { KeychainHelper.shared.set(newValue, key: "access_token") }
    }

    nonisolated var refreshToken: String? {
        get { KeychainHelper.shared.get(key: "refresh_token") }
        set { KeychainHelper.shared.set(newValue, key: "refresh_token") }
    }
}

