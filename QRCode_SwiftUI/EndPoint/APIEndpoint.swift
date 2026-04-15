//
// 
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

import Alamofire

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
}

extension APIEndpoint {
    var baseURL: String { APIConfig.baseURL }
    var headers: HTTPHeaders? { nil }
    var fullURL: String { baseURL + path }
}

// MARK: - API Config
enum APIConfig {
    static let baseURL = "https://api.example.com"
    static let timeoutInterval: TimeInterval = 30
    static let uploadTimeout: TimeInterval = 120
}
