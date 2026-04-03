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
    let code: Int?
    let message: String?
    let data: T?

    var serverMessage: String { message ?? "" }
    
    func isHaveData() -> Bool {
        
        if data != nil && success {
            return true
        }
        
        return false

    }
    
    func isEmptyData() -> Bool {
        
        if data == nil || success == false {
            return true
        }
        
        return false
    }
    
    func handleResponse(onSuccsess: (T) -> Void, onFail: (String) -> Void) {
        if isHaveData() {
            onSuccsess(data!)
        } else {
            onFail(message ?? "Unknown error")
        }
    }
}
