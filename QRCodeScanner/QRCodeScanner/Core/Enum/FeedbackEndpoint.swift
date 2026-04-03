//
//  FeedbackEndpoint.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 2/4/26.
//

import Alamofire

enum FeedbackEndpoint: APIEndpoint {

    case submit            // POST /feedback — có ảnh → multipart
    case submitText        // POST /feedback/text — không có ảnh → JSON

    var path: String {
        switch self {
        case .submit, .submitText: return "/feedback"
        }
    }

    var method: HTTPMethod { .post }

    var requiresAuth: Bool { true }

    // multipart không cần Content-Type tự set (Alamofire tự làm)
    var encoding: ParameterEncoding { JSONEncoding.default }
}
