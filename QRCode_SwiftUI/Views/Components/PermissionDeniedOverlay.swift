//
//  PermissionDeniedOverlay.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

// MARK: - Permission Denied Overlay
struct PermissionDeniedOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)
                Text("Camera access required")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("Go to Settings → Privacy → Camera and enable access.")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.yellow)
                .foregroundStyle(.black)
                .fontWeight(.semibold)
                .clipShape(Capsule())
            }
        }
    }
}
