//
//  CameraToolbar.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

struct CameraToolbar: View {
    
    @Binding var isFlashOn: Bool
    let onPhotoLibrary: () -> Void
    let onFlipCamera: () -> Void
    let onFlashToggle:  () -> Void
    
    var body: some View {
        HStack {
            Button(action: onPhotoLibrary) {
                ToolbarIcon(systemName: "photo.stack.fill")
            }
            Spacer()
            Button {
                onFlashToggle()
            } label: {
                ToolbarIcon(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
            }
            Spacer()
            Button(action: onFlipCamera) {
                ToolbarIcon(systemName: "arrow.triangle.2.circlepath.camera.fill")
            }
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(white: 0.35))
        )
    }
    
}

struct ToolbarIcon: View {
    let systemName: String
    var color: Color = Color.white.opacity(1)

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(color)
            .frame(width: 44, height: 44)
            .scaledToFit()
            .contentShape(Rectangle())
    }
}
