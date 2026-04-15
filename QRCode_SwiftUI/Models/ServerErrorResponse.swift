//
//  ServerErrorResponse.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

// MARK: - Server Error Response Shape
struct ServerErrorResponse: Decodable {
    let message: String?
    let error: String?
}
