//
//  AppError.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 18/4/26.
//

import Foundation

// MARK: - AppError
enum AppError: LocalizedError, Equatable {

    // Camera
    case permissionDenied
    case cameraUnavailable

    // QR / Scan
    case noQRCodeFound
    case invalidQRPayload
    case photoLoadFailed
    case photoScanFailed

    // Network — dùng cho History, Create
    case networkUnavailable
    case serverError(code: Int)

    // Generic
    case unknown(String)

    // MARK: Display

    var errorDescription: String {
        switch self {
        case .permissionDenied:   return "Camera permission denied"
        case .cameraUnavailable:  return "Camera unavailable"
        case .noQRCodeFound:      return "No QR code found"
        case .invalidQRPayload:   return "QR code unreadable"
        case .photoLoadFailed:    return "Could not load photo"
        case .photoScanFailed:    return "Failed to scan image"
        case .networkUnavailable: return "No internet connection"
        case .serverError(let c): return "Server error (\(c))"
        case .unknown(let msg):   return msg.isEmpty ? "Something went wrong" : msg
        }
    }

    var suggestion: String {
        switch self {
        case .permissionDenied:   return "Go to Settings → Privacy → Camera and enable access."
        case .cameraUnavailable:  return "Try using the photo library instead"
        case .noQRCodeFound:      return "Make sure the QR code is fully visible"
        case .invalidQRPayload:   return "The QR code may be damaged or unsupported"
        case .photoLoadFailed:    return "Try selecting a different photo"
        case .photoScanFailed:    return "Try again with a clearer image"
        case .networkUnavailable: return "Check your connection and try again"
        case .serverError:        return "Please try again later"
        case .unknown:            return "Please try again"
        }
    }

    var icon: String {
        switch self {
        case .permissionDenied, .cameraUnavailable: return "camera.fill"
        case .noQRCodeFound, .invalidQRPayload:     return "qrcode.viewfinder"
        case .photoLoadFailed, .photoScanFailed:    return "photo.fill"
        case .networkUnavailable:                   return "wifi.slash"
        case .serverError:                          return "exclamationmark.icloud.fill"
        case .unknown:                              return "exclamationmark.triangle.fill"
        }
    }

    var canOpenSettings: Bool { self == .permissionDenied }

    // MARK: Equatable — serverError và unknown cần custom
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.permissionDenied, .permissionDenied),
             (.cameraUnavailable, .cameraUnavailable),
             (.noQRCodeFound, .noQRCodeFound),
             (.invalidQRPayload, .invalidQRPayload),
             (.photoLoadFailed, .photoLoadFailed),
             (.photoScanFailed, .photoScanFailed),
             (.networkUnavailable, .networkUnavailable):
            return true
        case (.serverError(let a), .serverError(let b)): return a == b
        case (.unknown(let a), .unknown(let b)):         return a == b
        default: return false
        }
    }
}
