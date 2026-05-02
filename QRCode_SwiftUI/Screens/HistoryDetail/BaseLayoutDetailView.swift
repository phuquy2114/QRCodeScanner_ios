//
//  BaseLayoutDetailView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia
//

import SwiftUI

struct BaseLayoutDetailView<Content: View>: View {
//    @EnvironmentObject var theme: ThemeManager
    @ObservedObject var entity: QRCodeEntity

    // Tiêu đề hiển thị trên Header (Toolbar)
    var title: String

    // Nội dung tuỳ biến ở giữa
    @ViewBuilder var content: () -> Content

    @State private var uiImage: UIImage?
    @State private var showShareSheet: Bool = false
    @State private var showToast: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Text(entity.rawContent ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // 1. PHẦN NỘI DUNG RIÊNG (BODY)
                content()

                // 2. PHẦN FOOTER: 2 NÚT BẤM
                HStack(spacing: 16) {
                    buildButton(title: "COPY", color: .white) {
                        UIPasteboard.general.string = entity.rawContent
                        withAnimation {
                            showToast = true
                        }
                    }

                    buildButton(title: "SHARE", color: .white) {
                        if uiImage != nil {
                            showShareSheet = true
                        }
                    }
                }

                // 3. PHẦN FOOTER: ẢNH QR & TEXT
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .background(Color.white)
                }

                Text("Feedback or suggestion")
                    .font(.callout)
                    .foregroundStyle(.gray)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollIndicators(.hidden)
        .marginBottom()
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        // HEADER: TITLE
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
        // XỬ LÝ LOGIC DÙNG CHUNG
        .onAppear {
            loadQRImage()
        }
        .sheet(isPresented: $showShareSheet) {
            if let imageToShare = uiImage {
                ShareSheet(items: [imageToShare])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .toast(isShowing: $showToast, message: "Copied")
    }

    // MARK: - Helpers
    private func buildButton(
        title: String,
        color: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
        }
    }

    private func loadQRImage() {
        guard let fileName = entity.imageFileName,
            let image = LocalImageService.shared.loadImage(fileName: fileName)
        else { return }

        Task.detached(priority: .userInitiated) {
            let cleanedImage = await image.removingAlphaChannel()
            await MainActor.run {
                self.uiImage = cleanedImage
            }
        }
    }
}
