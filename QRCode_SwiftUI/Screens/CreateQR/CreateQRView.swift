//
//  CreateQRView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 11/4/26.
//

import SwiftUI
import UIKit // Thêm UIKit để sử dụng UIPasteboard

struct CreateQRView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var showNoClipboardToast: Bool = false
    @State private var showPermissionAlert: Bool = false // <--- Biến mới để xin quyền
    
    // 1. Thêm biến path để quản lý navigation bằng code
    @State private var path: [CreateQRRouter] = []
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible()),
    ]

    var body: some View {
        // 2. Gắn path vào NavigationStack
        NavigationStack(path: $path) {
            VStack {
                NavigationLink(value: CreateQRRouter.history) {
                    buildSection(
                        title: "History",
                        icon: "clock.arrow.circlepath"
                    )
                }.buttonStyle(.plain)

                Spacer().frame(height: 12)
                
                // 3. Đổi NavigationLink thành Button để xử lý Validation
                Button {
                    checkClipboardAndNavigate()
                } label: {
                    buildSection(
                        title: "Clipboard",
                        icon: "clipboard.fill"
                    )
                }
                .buttonStyle(.plain)

                Spacer().frame(height: 16)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CreateQREnums.allCases, id: \.self) { item in
                            NavigationLink(
                                value: CreateQRRouter.createDetail(item: item)
                            ) {
                                CreateItemCell(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 16)

            }
            .scrollContentBackground(.hidden)
            .marginBottom()
            .background(Color.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: CreateQRRouter.self) { router in
                switch router {
                case .history:
                    HistoryView(isFavoriteOnly: false)
                case .clipboard(let text):
                    // 4. Truyền nội dung clipboard đã lưu vào view
                    CreateQRBasicView(item: .text, initialContent: text)
                case .createDetail(let item):
                    navigationCreateQR(item: item)
                }
            }
            // Thông báo bộ nhớ trống
            .alert("No Clipboard Content", isPresented: $showNoClipboardToast) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Your clipboard is currently empty. Please copy some text or a URL first."
                )
            }
            // THÔNG BÁO XIN QUYỀN CLIPBOARD TỪ SETTINGS
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(
                    "Please tap 'Open Settings' and change 'Paste from Other Apps' to 'Allow' to use this feature seamlessly."
                )
            }
        }

    }
    
    // MARK: - Validation Logic
    private func checkClipboardAndNavigate() {
        // Kiểm tra xem Clipboard có chứa định dạng chữ hay không (Hàm này KHÔNG gọi popup của Apple)
        if !UIPasteboard.general.hasStrings {
            showNoClipboardToast = true
            return
        }
        
        // Cố gắng đọc chữ từ Clipboard (Hàm này SẼ kích hoạt popup của Apple)
        if let text = UIPasteboard.general.string {
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Đọc thành công -> Đi tiếp
                path.append(.clipboard(text: text))
            } else {
                showNoClipboardToast = true
            }
        } else {
            // Có dữ liệu chữ, nhưng không đọc được (trả về nil)
            // -> Chắc chắn 100% người dùng đã bấm "Don't Allow" hoặc đang tắt quyền trong Settings
            showPermissionAlert = true
        }
    }

    // MARK: - View Builders

    private func buildSection(
        title: String,
        icon: String,
        subtitle: String? = nil
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: 24, height: 24)
                .foregroundStyle(theme.accent)
                .scaledToFill()

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.white)
                    .font(.title3)

                if let sub = subtitle {
                    Text(sub)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
                .scaledToFill()
        }
        .padding(16)
        .background(Color.backgroundColor)
        .clipShape(.rect(cornerRadius: 8))
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func navigationCreateQR(item: CreateQREnums) -> some View {
        switch item {
        case .text, .location, .twitter, .instagram:
            CreateQRBasicView(item: item)
        case .telephone:
            CreateQRTelephoneView(item: item)
        case .sms, .whatsapp:
            CreateQRSMSView(item: item)
        case .website:
            CreateQRWebsiteView(item: item)
        case .wifi:
            CreateQRWifiView(item: item)
        case .event:
            CreateQREventView(item: item)
        case .contact:
            CreateQRContactView(item: item)
        case .business:
            CreateQRBusinessView(item: item)
        case .email:
            CreateQREmailView(item: item)
        }
    }
}

struct CreateItemCell: View {
    @EnvironmentObject var theme: ThemeManager
    let item: CreateQREnums

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                ZStack(alignment: .center) {
                    if let icon = item.icon() {
                        icon.resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(theme.accent)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .fill(theme.accent)
                        }
                )
                Text(item.title())
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4).fill(theme.accent)
                    )
                    .frame(maxWidth: 56)
                    .alignmentGuide(.top) { dimen in
                        dimen[VerticalAlignment.center]
                    }
            }

            Text(item.title())
                .foregroundStyle(.white)
                .lineLimit(1)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .padding(.bottom, 8)
        .padding(.top, 16)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundColor)
        )
    }
}
