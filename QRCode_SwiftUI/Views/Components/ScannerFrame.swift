//
//  ScannerFrame.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

struct ScannerFrame: View {
    @EnvironmentObject private var theme: ThemeManager
    @State private var isAnimating = false
    private let cornerSize: CGFloat = 28
    private let cornerThickness: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Color.black.opacity(0.4)
                    .mask {
                        Rectangle()
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: w, height: h)
                                    .blendMode(.destinationOut)
                            }
                    }
                // Corner brackets
                CornerBrackets(
                    size: geo.size,
                    cornerSize: cornerSize,
                    thickness: cornerThickness
                )

                // Scan line — tự quản lý animation bằng @State nội bộ
                Rectangle()
                    .fill(theme.accent)
                    .frame(width: w - 20, height: 4)
                    .opacity(0.9)
                    // Dùng position thay cho offset để cố định từ lề trên xuống lề dưới
                    .position(x: w / 2, y: isAnimating ? h : 0)
                    .clipped()
            }
            .onAppear {
                // Kích hoạt animation chạy mãi mãi, tự động đảo chiều
                withAnimation(
                    .linear(duration: 2.0).repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
}

struct CornerBrackets: View {
    let size: CGSize
    let cornerSize: CGFloat
    let thickness: CGFloat
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        ZStack {
            // Top-left
            CornerShape(corner: .topLeft)
            // Top-right
            CornerShape(corner: .topRight)
            // Bottom-left
            CornerShape(corner: .bottomLeft)
            // Bottom-right
            CornerShape(corner: .bottomRight)
        }
        .foregroundStyle(theme.accent)
        .frame(width: size.width, height: size.height)
    }
}

enum FrameCorner { case topLeft, topRight, bottomLeft, bottomRight }

struct CornerShape: View {
    let corner: FrameCorner
    private let len: CGFloat = 28
    private let thickness: CGFloat = 6
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Path { path in
                switch corner {
                case .topLeft:
                    path.move(to: CGPoint(x: 0, y: len))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: len, y: 0))
                case .topRight:
                    path.move(to: CGPoint(x: w - len, y: 0))
                    path.addLine(to: CGPoint(x: w, y: 0))
                    path.addLine(to: CGPoint(x: w, y: len))
                case .bottomLeft:
                    path.move(to: CGPoint(x: 0, y: h - len))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: len, y: h))
                case .bottomRight:
                    path.move(to: CGPoint(x: w - len, y: h))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: w, y: h - len))
                }
            }
            .stroke(
                theme.accent,
                style: StrokeStyle(lineWidth: thickness, lineCap: .round)
            )

        }
    }
}
