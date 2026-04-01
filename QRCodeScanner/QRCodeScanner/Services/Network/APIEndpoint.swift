//
//  APIEndpoint.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

import Alamofire

// MARK: ──────────────────────────────────────────
// MARK: - APIEndpoint  (protocol cho từng endpoint)
// ──────────────────────────────────────────────

protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var requiresAuth: Bool { get }
    var encoding: ParameterEncoding { get }
}

// Default values — không cần implement hết mỗi lần
extension APIEndpoint {
    var headers: [String: String]? { nil }
    var requiresAuth: Bool { true }
    var encoding: ParameterEncoding {
        method == .get ? URLEncoding.default : JSONEncoding.default
    }

    /// Full URL = baseURL + path
    var fullURL: String { APIConfig.shared.baseURL + path }
}
