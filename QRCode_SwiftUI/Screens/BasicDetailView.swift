import SwiftUI

struct BasicDetailView: View {
    @EnvironmentObject var theme: ThemeManager
    @ObservedObject var entity: QRCodeEntity
    @State private var uiImage: UIImage?
    @State private var showShareSheet: Bool = false
    @State private var showToast: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Text Box
                Text(entity.rawContent ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color.gray.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = entity.rawContent
                        withAnimation {
                            showToast = true
                        }

                    } label: {
                        Text("COPY")
                            .font(.headline)
                            .foregroundStyle(theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.accent, lineWidth: 1)
                            )
                    }

                    Button {
                        if uiImage != nil {
                            showShareSheet = true
                        }
                    } label: {
                        Text("SHARE")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color.white,
                                        lineWidth: 1
                                    )
                            )
                    }
                }

                // QR Image
                if let img = uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .background(Color.white)
                }

                Spacer().frame(height: 24)

                Text("Feedback or suggestion")
                    .font(.callout)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .padding(20)
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(entity.rawContent ?? "")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
        .onAppear {
            if let fileName = entity.imageFileName,
               let rawImage = LocalImageService.shared.loadImage(fileName: fileName) {
                
                // Gọi extension dùng chung, code cực kỳ gọn gàng
                Task.detached(priority: .userInitiated) {
                    let cleanedImage = await rawImage.removingAlphaChannel()
                    await MainActor.run {
                        self.uiImage = cleanedImage
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let imageToShare = uiImage {
                ShareSheet(items: [imageToShare])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .toast(isShowing: $showToast, message: "copied")
    }
}
