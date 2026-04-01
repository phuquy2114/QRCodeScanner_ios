//
//  ServerErrorResponse.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

// MARK: - Server Error Response Shape

struct ServerErrorResponse: Decodable {
    let message: String?
    let error: String?
}
