//
//  NetworkService.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

import Foundation
import Alamofire

// MARK: - Network Service
final class NetworkService {
    static let shared = NetworkService()

    private let session: Session
    private let uploadSession: Session  // timeout dài hơn cho upload

    private init() {
        let defaultConfig = URLSessionConfiguration.default
        defaultConfig.timeoutIntervalForRequest = APIConfig.timeoutInterval

        let uploadConfig = URLSessionConfiguration.default
        uploadConfig.timeoutIntervalForRequest = APIConfig.uploadTimeout

        session = Session(configuration: defaultConfig, interceptor: AuthInterceptor())
        uploadSession = Session(configuration: uploadConfig, interceptor: AuthInterceptor())
    }

    // MARK: - GET
    func get<T: Decodable>(
        _ endpoint: any APIEndpoint,
        parameters: Parameters? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await session
            .request(endpoint.fullURL,
                     method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.queryString,
                     headers: endpoint.headers)
            .validate()
            .serializingDecodable(T.self)
            .mappedValue()
    }

    // MARK: - POST
    /// POST với JSON body
    func post<T: Decodable>(
        _ endpoint: any APIEndpoint,
        body: Encodable? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await session
            .request(endpoint.fullURL,
                     method: .post,
                     parameters: body?.asDictionary(),
                     encoding: JSONEncoding.default,
                     headers: endpoint.headers)
            .validate()
            .serializingDecodable(T.self)
            .mappedValue()
    }

    /*
    /// POST không cần parse response
    func postVoid(
        _ endpoint: any APIEndpoint,
        body: Encodable? = nil
    ) async throws {
        try await session
            .request(endpoint.fullURL,
                     method: .post,
                     parameters: body?.asDictionary(),
                     encoding: JSONEncoding.default,
                     headers: endpoint.headers)
            .validate()
            .serializingData()
            .mappedValue()
    }
     */
    // MARK: - PUT

    func put<T: Decodable>(
        _ endpoint: any APIEndpoint,
        body: Encodable? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await session
            .request(endpoint.fullURL,
                     method: .put,
                     parameters: body?.asDictionary(),
                     encoding: JSONEncoding.default,
                     headers: endpoint.headers)
            .validate()
            .serializingDecodable(T.self)
            .mappedValue()
    }

    // MARK: - PATCH
    func patch<T: Decodable>(
        _ endpoint: any APIEndpoint,
        body: Encodable? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await session
            .request(endpoint.fullURL,
                     method: .patch,
                     parameters: body?.asDictionary(),
                     encoding: JSONEncoding.default,
                     headers: endpoint.headers)
            .validate()
            .serializingDecodable(T.self)
            .mappedValue()
    }

    /*
    // MARK: - DELETE
    func delete(
        _ endpoint: any APIEndpoint,
        parameters: Parameters? = nil
    ) async throws {
        try await session
            .request(endpoint.fullURL,
                     method: .delete,
                     parameters: parameters,
                     encoding: URLEncoding.queryString,
                     headers: endpoint.headers)
            .validate()
            .serializingData()
            .mappedValue()
    }
     */
    
    /// DELETE trả về body nếu API cần
    func delete<T: Decodable>(
        _ endpoint: any APIEndpoint,
        parameters: Parameters? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await session
            .request(endpoint.fullURL,
                     method: .delete,
                     parameters: parameters,
                     encoding: URLEncoding.queryString,
                     headers: endpoint.headers)
            .validate()
            .serializingDecodable(T.self)
            .mappedValue()
    }

    // MARK: - UPLOAD
    /// Upload 1 hoặc nhiều file dưới dạng multipart/form-data
    /// - Parameters:
    ///   - items: danh sách file cần upload
    ///   - fields: các form field text kèm theo (tên, mô tả...)
    ///   - progress: callback progress 0.0 → 1.0
    func upload<T: Decodable>(
        _ endpoint: any APIEndpoint,
        items: [UploadItem],
        fields: [String: String] = [:],
        progress: ((Double) -> Void)? = nil,
        type: T.Type = T.self
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            uploadSession.upload(
                multipartFormData: { form in
                    // Text fields
                    for (key, value) in fields {
                        if let data = value.data(using: .utf8) {
                            form.append(data, withName: key)
                        }
                    }
                    // Files
                    for item in items {
                        form.append(item.data,
                                    withName: item.name,
                                    fileName: item.fileName,
                                    mimeType: item.mimeType)
                    }
                },
                to: endpoint.fullURL,
                method: .post,
                headers: endpoint.headers
            )
            .uploadProgress { prog in
                progress?(prog.fractionCompleted)
            }
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: mapAFError(error))
                }
            }
        }
    }

    // MARK: - DOWNLOAD

    /// Download file về Documents directory
    /// - Parameters:
    ///   - endpoint: endpoint trả về file
    ///   - fileName: tên file lưu local
    ///   - progress: callback progress 0.0 → 1.0
    func download(
        _ endpoint: any APIEndpoint,
        fileName: String,
        progress: ((Double) -> Void)? = nil
    ) async throws -> DownloadResult {
        let destination: DownloadRequest.Destination = { _, _ in
            let url = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName)
            return (url, [.removePreviousFile, .createIntermediateDirectories])
        }

        return try await withCheckedThrowingContinuation { continuation in
            session.download(
                endpoint.fullURL,
                method: .get,
                headers: endpoint.headers,
                to: destination
            )
            .downloadProgress { prog in
                progress?(prog.fractionCompleted)
            }
            .validate()
            .response { response in
                switch response.result {
                case .success(let url):
                    let result = DownloadResult(
                        fileURL: url ?? URL(fileURLWithPath: ""),
                        response: response.response
                    )
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: mapAFError(error))
                }
            }
        }
    }

    /// Download trực tiếp thành Data (file nhỏ, ảnh...)
    func downloadData(
        _ endpoint: any APIEndpoint,
        progress: ((Double) -> Void)? = nil
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            session.request(endpoint.fullURL,
                            method: .get,
                            headers: endpoint.headers)
            .downloadProgress { prog in
                progress?(prog.fractionCompleted)
            }
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: mapAFError(error))
                }
            }
        }
    }
}

// MARK: - Error Mapping (free function — dùng được cả trong closure)

private func mapAFError(_ error: AFError) -> AppError {
    if let urlError = error.underlyingError as? URLError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        default:
            break
        }
    }
    if let code = error.responseCode {
        return .serverError(code: code)
    }
    return .unknown(error.localizedDescription)
}

// MARK: - DataTask convenience

private extension DataTask {
    func mappedValue() async throws -> Value {
        do {
            return try await value
        } catch let error as AFError {
            throw mapAFError(error)
        }
    }
}

// MARK: - Encodable → Dictionary

private extension Encodable {
    func asDictionary() -> Parameters? {
        guard
            let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data) as? Parameters
        else { return nil }
        return dict
    }
}

// MARK: - Notification

extension Notification.Name {
    static let unauthorizedError = Notification.Name("unauthorizedError")
}
