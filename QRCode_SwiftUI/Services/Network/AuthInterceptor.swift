//
//  AuthInterceptor.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 12/4/26.
//

import Alamofire

// MARK: - Auth Interceptor
final class AuthInterceptor: RequestInterceptor {

    private var token: String? {
        UserDefaults.standard.string(forKey: "auth_token")
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let token {
            request.headers.add(.authorization(bearerToken: token))
        }
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        if let afError = error as? AFError, afError.responseCode == 401 {
            NotificationCenter.default.post(name: .unauthorizedError, object: nil)
            completion(.doNotRetry)
            return
        }
        if let urlError = error as? URLError,
           urlError.code == .timedOut,
           request.retryCount < 1 {
            completion(.retryWithDelay(1.0))
            return
        }
        completion(.doNotRetry)
    }
}
