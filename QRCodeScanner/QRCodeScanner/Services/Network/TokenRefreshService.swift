//
//  TokenRefreshService.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

// MARK: ──────────────────────────────────────────
// MARK: - TokenRefreshService  (placeholder — implement theo API thật)
// ──────────────────────────────────────────────

final class TokenRefreshService {
    static let shared = TokenRefreshService()
    private init() {}

    func refresh() async throws {
        guard let refreshToken = APIConfig.shared.refreshToken else {
            throw APIError.unauthorized
        }
        // TODO: gọi API refresh token thật
        // let response: TokenResponse = try await NetworkClient.shared.request(
        //     AuthEndpoint.refreshToken(token: refreshToken)
        // )
        // APIConfig.shared.accessToken  = response.accessToken
        // APIConfig.shared.refreshToken = response.refreshToken
        _ = refreshToken
        throw APIError.unauthorized  // remove khi implement thật
    }
}
