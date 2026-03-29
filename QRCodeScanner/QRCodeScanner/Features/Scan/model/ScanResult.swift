//
//  ScanResult.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 26/3/26.
//

import AVFoundation

// MARK: - ScanResult
struct ScanResult {
    let content: String
    let type: AVMetadataObject.ObjectType
    let scannedAt: Date = Date()
}
