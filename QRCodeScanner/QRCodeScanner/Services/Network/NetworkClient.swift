//
//  NetworkClient.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

import Alamofire
import Network

final class NetworkClient {

    static let shared = NetworkClient()

    private let session: Session

    private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest  = APIConfig.shared.timeout
        config.timeoutIntervalForResource = APIConfig.shared.timeout * 2

        session = Session(
            configuration: config,
            interceptor: AuthInterceptor(),
            eventMonitors: [NetworkLogger()]
        )
    }

    // MARK: - Generic Request → Decodable
    /// Gọi API và decode thẳng sang kiểu T
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        parameters: APIParameters? = nil,
        decode: JSONDecoder? = nil
    ) async throws -> T {
        let decoder = decode ?? .apiDefault
        let headers   = buildHeaders(endpoint)
        let dataTask  = session.request(
            endpoint.fullURL,
            method:     endpoint.method.afMethod,
            parameters: parameters,
            encoding:   endpoint.encoding,
            headers:    headers
        )
        .validate()

        return try await withCheckedThrowingContinuation { continuation in
            dataTask.responseDecodable(of: T.self, decoder: decoder) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, data: response.data))
                }
            }
        }
    }

    // MARK: - APIResponse wrapper (success/data/message)
    /// Gọi API và unwrap `APIResponse<T>.data`
    func requestData<T: Decodable>(
        _ endpoint: APIEndpoint,
        parameters: APIParameters? = nil,
        decode: JSONDecoder? = nil
    ) async throws -> T {
        let decoder = decode ?? .apiDefault
        
        let wrapper: APIResponse<T> = try await request(
            endpoint,
            parameters: parameters,
            decode: decoder
        )
        guard wrapper.success, let data = wrapper.data else {
            throw APIError.custom(message: wrapper.serverMessage)
        }
        return data
    }

    // MARK: - Void response (không cần decode body)
    func requestVoid(
        _ endpoint: APIEndpoint,
        parameters: APIParameters? = nil
    ) async throws {
        let headers  = buildHeaders(endpoint)
        let dataTask = session.request(
            endpoint.fullURL,
            method:     endpoint.method.afMethod,
            parameters: parameters,
            encoding:   endpoint.encoding,
            headers:    headers
        )
        .validate()

        return try await withCheckedThrowingContinuation { continuation in
            dataTask.response { response in
                switch response.result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, data: response.data))
                }
            }
        }
    }

    // MARK: - Multipart Upload

    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        multipartData: @escaping (MultipartFormData) -> Void,
        decode: JSONDecoder? = nil ,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> T {
        let decoder = decode ?? .apiDefault
        let headers = buildHeaders(endpoint)

        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: multipartData,
                to: endpoint.fullURL,
                method: endpoint.method.afMethod,
                headers: headers
            )
            .uploadProgress { progress in
                onProgress?(progress.fractionCompleted)
            }
            .responseDecodable(of: T.self, decoder: decoder) { response in
                
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(
                        throwing: self.mapError(error, data: response.data)
                    )
                }
            }
        }
    }

    // MARK: - Download File

    func download(
        _ endpoint: APIEndpoint,
        to destination: URL,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> URL {
        let headers = buildHeaders(endpoint)
        let afDestination: DownloadRequest.Destination = { _, _ in
            (destination, [.removePreviousFile, .createIntermediateDirectories])
        }

        return try await withCheckedThrowingContinuation { continuation in
            session.download(
                endpoint.fullURL,
                method: endpoint.method.afMethod,
                headers: headers,
                to: afDestination
            )
            .downloadProgress { progress in
                onProgress?(progress.fractionCompleted)
            }
            .response { response in
                switch response.result {
                case .success(let url):
                    continuation.resume(returning: url ?? destination)
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error, data: nil))
                }
            }
        }
    }

    // MARK: - Network Reachability
    var isConnected: Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isConnect = false
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnect = true
            } else {
                isConnect = false
            }
        }
        monitor.start(queue: queue)
        return isConnect
    }

    // MARK: - Private Helpers

    private func buildHeaders(_ endpoint: APIEndpoint) -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type":  "application/json",
            "Accept":        "application/json",
            "Accept-Language": Locale.preferredLanguages.first ?? "en"
        ]
        endpoint.headers?.forEach { headers[$0.key] = $0.value }
        return headers
    }

    private func mapError(_ error: AFError, data: Data?) -> APIError {
        // Thử parse error message từ server body
        if let data,
           let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
            return .custom(message: serverError.message ?? serverError.error ?? "Unknown error")
        }

        if let statusCode = error.responseCode {
            switch statusCode {
            case 401: return .unauthorized
            case 403: return .forbidden
            case 404: return .notFound
            case 500...: return .serverError(statusCode: statusCode)
            default: break
            }
        }

        if error.isSessionTaskError {
            let nsError = error.underlyingError as NSError?
            if nsError?.code == NSURLErrorNotConnectedToInternet { return .noInternet }
            if nsError?.code == NSURLErrorTimedOut               { return .timeout }
        }

        if case .responseSerializationFailed(let reason) = error,
           case .decodingFailed(let decodingError) = reason {
            return .decodingFailed(decodingError)
        }

        return .unknown(error)
    }
}
