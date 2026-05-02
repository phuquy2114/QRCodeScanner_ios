import SwiftUI

struct WifiDetail​View: View {
    @ObservedObject var entity: QRCodeEntity
    @EnvironmentObject var theme: ThemeManager

    // Thêm biến quản lý thông báo và sheet
    @State private var showToast: Bool = false
    @State private var showConnectSheet: Bool = false

    var body: some View {
        BaseLayoutDetailView(
            entity: entity,
            title: entity.rawContent ?? ""
        ) {
            HStack(spacing: 16) {
                buildButton(title: "CONNECT TO WI-FI", color: theme.accent) {
                    // Mở sheet hướng dẫn kết nối
                    showConnectSheet = true
                }

                buildButton(title: "COPY PASSWORD", color: .white) {
                    copyPasswordToClipboard()
                }
            }
        }
        // Hiện thông báo copy thành công
        .toast(isShowing: $showToast, message: "Password copied")
        // Hiển thị Sheet hướng dẫn (1/2 màn hình)
        .sheet(isPresented: $showConnectSheet) {
            connectInstructionsSheet()
                .presentationDetents([.medium, .large])  // Chỉ cao 1/2 màn hình
                .presentationDragIndicator(.visible)  // Hiện thanh kéo phía trên
                .preferredColorScheme(.dark)  // Ép nền sheet về màu tối cho đồng bộ
        }
    }

    private func buildButton(
        title: String,
        color: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            Text(title)
                .font(.title3)
                .fontWeight(.regular)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
        }
    }

    // MARK: - Sheet View Builder
    @ViewBuilder
    private func connectInstructionsSheet() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Connect (Tips)")
                .font(.title2)
                .bold()
                .foregroundStyle(.white)

            Text(
                "Due to system restrictions, you need to connect manually. Follow these steps:"
            )
            .font(.headline)
            .foregroundStyle(.gray)
            .lineLimit(4)

            Text(
                """
                1. Choose the Wifi to connect
                2. Paste the password (auto copied)
                """
            )
            .font(.headline)
            .foregroundStyle(.white)

            // Khối hiển thị thông tin Wi-Fi
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Network Name:")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(networkName)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }

                Divider().background(Color.gray.opacity(0.5))

                HStack {
                    Text("Password:")
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(password.isEmpty ? "None" : password)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)

            Spacer()

            // Hai nút hành động ở cuối Sheet
            HStack(spacing: 16) {
                buildButton(title: "COPY PASS", color: .white) {
                    copyPasswordToClipboard()
                    // Tự động đóng sheet sau khi copy xong để tiện thao tác
                    showConnectSheet = false
                }

                buildButton(title: "OPEN SETTINGS", color: theme.accent) {
                    openWiFiSettings()
                }
            }
            .padding(.bottom, 16)
        }
        .padding(24)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Logic Helpers

    // Trích xuất Tên mạng từ rawContent (Sử dụng Extension mới)
    private var networkName: String {
        entity.rawContent?.extractValue(for: "Network: ") ?? ""
    }

    // Trích xuất Mật khẩu từ rawContent (Sử dụng Extension mới)
    private var password: String {
        entity.rawContent?.extractValue(for: "Password: ") ?? ""
    }

    private func copyPasswordToClipboard() {
        let pass = self.password
        guard !pass.isEmpty else { return }

        UIPasteboard.general.string = pass
        withAnimation {
            showToast = true
        }
    }

    private func openWiFiSettings() {
        // App-Prefs:root=WIFI là URL Scheme mặc định của iOS để nhảy thẳng vào mục Wi-Fi
        if let url = URL(string: "App-Prefs:root=WIFI") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Đề phòng trên các bản iOS tương lai Apple chặn URL Scheme này,
                // ta dự phòng bằng cách mở trang Cài đặt chung của App
                if let settingsUrl = URL(
                    string: UIApplication.openSettingsURLString
                ) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
}
