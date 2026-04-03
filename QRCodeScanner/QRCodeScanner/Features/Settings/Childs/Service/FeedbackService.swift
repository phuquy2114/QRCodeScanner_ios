//
//  FeedbackService.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 2/4/26.
//

import Foundation
import Alamofire

// MARK: ──────────────────────────────────────────
// MARK: - FeedbackService
// ──────────────────────────────────────────────

final class FeedbackService: BaseAPIService {

    /// Submit feedback — single entry point
    /// - Nếu có ảnh → multipart/form-data + progress
    /// - Nếu không có ảnh → JSON body
    /// - onProgress: chỉ có giá trị khi upload ảnh
    func submit(
        _ request: FeedbackRequest,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> FeedbackResponse {
        if request.attachFiles.isEmpty {
            return try await submitJSON(request)
        } else {
            return try await submitMultipart(request, onProgress: onProgress)
        }
    }

    // MARK: - JSON (không có ảnh)
    private func submitJSON(_ request: FeedbackRequest) async throws -> FeedbackResponse {
        var body: APIParameters = [
            "title": request.title,
            "time": request.timeString
        ]
        if let description = request.description {
            body["description"] = description
        }
        return try await postData(FeedbackEndpoint.submitText, body: body)
    }
    
    // MARK: - Multipart (có ảnh)

    private func submitMultipart(
        _ request: FeedbackRequest,
        onProgress: ((Double) -> Void)?
    ) async throws -> FeedbackResponse {
        return try await upload(
            FeedbackEndpoint.submit,
            multipart: { form in
                if let description = request.description {
                    form.append(Data(description.utf8), withName: "description")
                }
                form.append(Data(request.title.utf8), withName: "title")
                form.append(Data(request.timeString.utf8),  withName: "time")
                
                let files = request.attachFiles
                
                files.enumerated().forEach { index, image in
                    guard let data = image.jpegData(compressionQuality: 0.8)
                    else { return }
                    
                    form.append(data,
                                withName: "attach_image[\(index)]",
                                fileName: "image_\(index).jpg",
                                mimeType: "image/jpeg")
                    
                }
            },
            onProgress: onProgress
        )
    }
    
}
