//
//  BaseAPIService.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

import Alamofire

// MARK: ──────────────────────────────────────────
// MARK: - BaseAPIService  (subclass cho từng feature)
// ──────────────────────────────────────────────

open class BaseAPIService {
    let client: NetworkClient

    init(client: NetworkClient = .shared) {
        self.client = client
    }

    // Shorthand methods — gọi gọn hơn trong subclass

    func get<T: Decodable>(
        _ endpoint: APIEndpoint,
        params: APIParameters? = nil
    ) async throws -> T {
        try await client.request(endpoint, parameters: params)
    }

    func getData<T: Decodable>(
        _ endpoint: APIEndpoint,
        params: APIParameters? = nil
    ) async throws -> T {
        try await client.requestData(endpoint, parameters: params)
    }

    func post<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: APIParameters? = nil
    ) async throws -> T {
        try await client.request(endpoint, parameters: body)
    }

    func postData<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: APIParameters? = nil
    ) async throws -> T {
        try await client.requestData(endpoint, parameters: body)
    }

    func put<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: APIParameters? = nil
    ) async throws -> T {
        try await client.request(endpoint, parameters: body)
    }

    func patch<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: APIParameters? = nil
    ) async throws -> T {
        try await client.request(endpoint, parameters: body)
    }

    func delete(
        _ endpoint: APIEndpoint,
        params: APIParameters? = nil
    ) async throws {
        try await client.requestVoid(endpoint, parameters: params)
    }

    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        multipart: @escaping (MultipartFormData) -> Void,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> T {
        try await client.upload(
            endpoint,
            multipartData: multipart,
            onProgress: onProgress
        )
    }

    func download(
        _ endpoint: APIEndpoint,
        to destination: URL,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> URL {
        try await client
            .download(endpoint, to: destination, onProgress: onProgress)
    }
}

// MARK: ──────────────────────────────────────────
// MARK: - JSONDecoder  (default config)
// ──────────────────────────────────────────────

extension JSONDecoder {
    static var apiDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase  // user_name → userName
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: ──────────────────────────────────────────
// MARK: - AFError helpers
// ──────────────────────────────────────────────

extension AFError {
    var responseCode: Int? {
        if case .responseValidationFailed(let reason) = self,
            case .unacceptableStatusCode(let code) = reason
        {
            return code
        }
        return nil
    }
}
