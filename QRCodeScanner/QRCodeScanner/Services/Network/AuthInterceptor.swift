//
//  AuthInterceptor.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//
// MARK: ──────────────────────────────────────────
// MARK: - RequestInterceptor  (auto refresh token)
// ──────────────────────────────────────────────

import Alamofire

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {

    private let lock = NSLock()
    private var isRefreshing = false
    private var pendingRetries: [(RetryResult) -> Void] = []

    // Gắn token vào mỗi request
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        if let token = APIConfig.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    // Auto retry khi 401 — refresh token rồi thử lại
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              request.retryCount == 0 else {
            completion(.doNotRetry)
            return
        }
        refreshTokenAndRetry(completion: completion)
    }

    private func refreshTokenAndRetry(completion: @escaping (RetryResult) -> Void) {
        lock.lock()
        pendingRetries.append(completion)
        guard !isRefreshing else { lock.unlock(); return }
        isRefreshing = true
        lock.unlock()

        Task {
            do {
                try await TokenRefreshService.shared.refresh()
                self.resolvePending(.retry)
            } catch {
                KeychainHelper.shared.delete(key: "access_token")
                KeychainHelper.shared.delete(key: "refresh_token")
                self.resolvePending(.doNotRetry)
                // Notify app để show login screen
                await MainActor.run {

                    NotificationCenter.default.post(name: .userSessionExpired, object: nil)
                }
            }
        }
    }

    private func resolvePending(_ result: RetryResult) {
        lock.lock()
        let retries = pendingRetries
        pendingRetries.removeAll()
        isRefreshing = false
        lock.unlock()
        retries.forEach { $0(result) }
    }
}
