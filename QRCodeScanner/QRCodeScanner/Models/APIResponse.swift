//
//  APIResponse.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

// MARK: ──────────────────────────────────────────
// MARK: - APIResponse  (wrapper chuẩn)
// ──────────────────────────────────────────────

/// Cấu trúc JSON response chung của server
/// { "success": true, "data": {...}, "message": "OK", "code": 200 }
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let code: Int?

    var serverMessage: String { message ?? "" }
}
