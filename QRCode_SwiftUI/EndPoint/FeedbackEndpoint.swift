//
//  FeedbackEndpoint.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 12/4/26.
//

import Alamofire
enum FeedbackEndpoint: APIEndpoint {
    case submitFeedback
    var path: String {
        switch self {
        case .submitFeedback:
            "/feedback"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .submitFeedback:
                .post
        }
    }

}
