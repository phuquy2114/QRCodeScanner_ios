//
//  ZoomSlider.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

struct ZoomSlider: View {
    @Binding var zoom: Double
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Button { zoom = max(1.0, zoom - 0.5) } label: {
                Image(systemName: "minus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .scaledToFit()
                    .contentShape(Rectangle())
                    .frame(width: 32, height: 32)
            }

            Slider(value: $zoom, in: 1.0...5.0)

            Button { zoom = min(5.0, zoom + 0.5) } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .scaledToFit()
                    .contentShape(Rectangle())
                    .frame(width: 32, height: 32)
            }
        }
        .onAppear {
            // 1. Dùng hàm tự vẽ hình tròn hoàn hảo, không có viền trong suốt (padding)
            let thumbImage = UIImage.circleImage(diameter: 24, color: UIColor(theme.accent))
                
            // Gán hình ảnh này cho tất cả Slider trong app
            UISlider.appearance().setThumbImage(thumbImage, for: .normal)
            
            // 2. Set màu cho phần thanh đã kéo (Minimum Track)
            UISlider.appearance().minimumTrackTintColor = UIColor(theme.accent)
            
            // 3. Set màu cho phần thanh chưa kéo (Maximum Track)
            UISlider.appearance().maximumTrackTintColor = .white.withAlphaComponent(0.3)
        }
    }
}

