//
//  AppError.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//
import SwiftUI
import UIKit

// MARK: - AppErrorSheet
struct AppErrorSheet: View {
    let error: AppError
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 8)

                Image(systemName: error.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(.red)

                VStack(spacing: 8) {
                    Text(error.errorDescription)
                        .font(.title2)
                        .multilineTextAlignment(.center)

                    Text(error.suggestion)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    if error.canOpenSettings {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                                .appButtonStyle(color: .white, foreground: .black)
                        }
                    }

                    Button(action: onDismiss) {
                        Text("Try Again")
                            .appButtonStyle(color: Color.secondary.opacity(0.25), foreground: .primary)
                            
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: onDismiss)
                        .font(.title3)
                        
                }
            }
        }
        .presentationDetents([.medium])
    }
}

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
        case .permissionDenied:   return "Go to Settings → Privacy → Camera"
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
