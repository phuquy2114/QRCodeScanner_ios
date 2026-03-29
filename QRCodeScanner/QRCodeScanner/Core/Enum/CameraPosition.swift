//
//  CameraPosition.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 26/3/26.
//

import Foundation

// MARK: - CameraPosition
enum CameraPosition: Int, Sendable, Equatable {
    case back, front
    mutating func toggle() { self = self == .back ? .front : .back }
}

// MARK: - CameraError
enum CameraError: LocalizedError {
    case torchUnavailable
    case permissionDenied
    case configurationFailed

    var errorDescription: String? {
        switch self {
        case .torchUnavailable: 
            return "Flash_not_available".localized
        case .permissionDenied:
            return "Camera_permission_is_required_to_scan_QR_codes".localized
        case .configurationFailed:
            return "Unable_to_initialize_camera".localized
        }
    }
}
