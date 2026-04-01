//
//  NetworkLogger.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

import Alamofire

// MARK: ──────────────────────────────────────────
// MARK: - NetworkLogger
// ──────────────────────────────────────────────

final class NetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "network.logger")

    func requestDidFinish(_ request: Request) {
        guard APIConfig.shared.isLoggingEnabled else { return }
        print("""
        ┌─ 🌐 REQUEST ───────────────────────────
        │ \(request.request?.httpMethod ?? "") \(request.request?.url?.absoluteString ?? "")
        │ Headers: \(request.request?.allHTTPHeaderFields ?? [:])
        │ Body: \(request.request?.httpBody.flatMap { String(data: $0, encoding: .utf8) } ?? "none")
        └────────────────────────────────────────
        """)
    }

    func request<Value>(_ request: DataRequest,
                        didParseResponse response: DataResponse<Value, AFError>) {
        guard APIConfig.shared.isLoggingEnabled else { return }
        let status = response.response?.statusCode ?? 0
        let emoji  = (200..<300).contains(status) ? "✅" : "❌"
        let body   = response.data.flatMap { String(data: $0, encoding: .utf8) } ?? "empty"
        print("""
        ┌─ \(emoji) RESPONSE ─────────────────────────
        │ Status: \(status)
        │ URL: \(response.request?.url?.absoluteString ?? "")
        │ Body: \(body.prefix(500))
        └────────────────────────────────────────
        """)
    }
}
