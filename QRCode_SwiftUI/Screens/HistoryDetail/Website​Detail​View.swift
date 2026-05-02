import SwiftUI

struct Website​Detail​View: View {
    @ObservedObject var entity: QRCodeEntity
    @EnvironmentObject var theme: ThemeManager
    
    // Khai báo biến môi trường để mở URL của hệ thống
    @Environment(\.openURL) var openURL

    var body: some View {
        BaseLayoutDetailView(
            entity: entity,
            title: entity.rawContent ?? ""
        ) {
            Button {
                openWebsite()
            } label: {
                Text("OPEN  WEB")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.accent, lineWidth: 2)
                    )
            }
        }
    }
    
    // MARK: - Logic Helpers
    private func openWebsite() {
        guard let urlString = entity.rawContent, !urlString.isEmpty else { return }
        
        // Kiểm tra xem link đã có http:// hoặc https:// chưa, nếu chưa thì tự động thêm vào
        var validUrlString = urlString
        if !validUrlString.lowercased().hasPrefix("http://") && !validUrlString.lowercased().hasPrefix("https://") {
            validUrlString = "https://" + validUrlString
        }
        
        // Ép kiểu sang URL và yêu cầu iOS mở
        if let url = URL(string: validUrlString) {
            openURL(url)
        }
    }
}
