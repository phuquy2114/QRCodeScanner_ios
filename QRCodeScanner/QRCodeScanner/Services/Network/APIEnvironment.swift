//
//  APIEnvironment.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

//
//  Base Network Layer — Alamofire + Swift Concurrency
//  Requires: Alamofire 5.8+, iOS 15+
//

import Alamofire
// MARK: ──────────────────────────────────────────
// MARK: - APIEnvironment
// Thêm môi trường mới: chỉ cần thêm case + baseURL
// ─

enum APIEnvironment {
    case development
    case staging
    case production

    var baseURL: String {
        switch self {
        case .development: return "https://dev-api.yourapp.com/v1"
        case .staging:     return "https://staging-api.yourapp.com/v1"
        case .production:  return "https://api.yourapp.com/v1"
        }
    }

    var isLoggingEnabled: Bool {
        switch self {
        case .development, .staging: return true
        case .production:            return false
        }
    }
}

// MARK: ──────────────────────────────────────────
// MARK: - HTTPMethod  (type-safe wrapper)
// ──────────────────────────────────────────────

enum HTTPMethod {
    case get, post, put, patch, delete
    var afMethod: Alamofire.HTTPMethod {
        switch self {
        case .get:    return .get
        case .post:   return .post
        case .put:    return .put
        case .patch:  return .patch
        case .delete: return .delete
        }
    }
}

// MARK: ──────────────────────────────────────────
// MARK: - APIParameters  (query params hoặc body)
// ──────────────────────────────────────────────

typealias APIParameters = [String: Any]

// MARK: ──────────────────────────────────────────
// MARK: - APIError
// ──────────────────────────────────────────────

enum APIError: LocalizedError {
    case invalidURL
    case noInternet
    case timeout
    case unauthorized                    // 401 → cần login lại
    case forbidden                       // 403
    case notFound                        // 404
    case serverError(statusCode: Int)    // 5xx
    case decodingFailed(Error)           // parse JSON lỗi
    case custom(message: String)         // lỗi từ server body
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:               return "URL không hợp lệ"
        case .noInternet:               return "Không có kết nối internet"
        case .timeout:                  return "Yêu cầu quá thời gian, thử lại sau"
        case .unauthorized:             return "Phiên đăng nhập hết hạn"
        case .forbidden:                return "Bạn không có quyền thực hiện hành động này"
        case .notFound:                 return "Không tìm thấy dữ liệu"
        case .serverError(let code):    return "Lỗi máy chủ (\(code))"
        case .decodingFailed(let err):  return "Lỗi xử lý dữ liệu: \(err.localizedDescription)"
        case .custom(let msg):          return msg
        case .unknown(let err):         return err.localizedDescription
        }
    }

    var isUnauthorized: Bool {
        if case .unauthorized = self { return true }
        return false
    }
}
