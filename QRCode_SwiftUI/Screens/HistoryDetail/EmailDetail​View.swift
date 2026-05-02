import SwiftUI

struct EmailDetail​View: View {
    @ObservedObject var entity: QRCodeEntity
    @EnvironmentObject var theme: ThemeManager
    
    // Khai báo biến môi trường để mở URL của hệ thống
    @Environment(\.openURL) var openURL

    var body: some View {
        BaseLayoutDetailView(
            entity: entity,
            // Thay vì hiện nguyên cục content dài dòng, ta chỉ lấy email hiện lên Header cho đẹp
            title: extractValue(for: "To: ") 
        ) {
            Button {
                sendEmail()
            } label: {
                Text("SEND EMAIL")
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
    
    private func sendEmail() {
        guard let content = entity.rawContent else { return }
        // Sử dụng Extension String
        let email = content.extractValue(for: "To: ")
        let subject = content.extractValue(for: "Subject: ")
        let message = content.extractValue(for: "Message: ")
        
        guard !email.isEmpty else { return }
        
        // 1. Bắt đầu với scheme mailto:
        var urlString = "mailto:\(email)"
        
        // 2. Mảng chứa các tham số phụ (Subject, Body)
        var queryItems: [String] = []
        
        // Thêm Subject nếu có (Mã hoá URL để an toàn với khoảng trắng, dấu tiếng Việt...)
        if !subject.isEmpty, let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryItems.append("subject=\(encodedSubject)")
        }
        
        // Thêm Message (Body) nếu có
        if !message.isEmpty, let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            queryItems.append("body=\(encodedMessage)")
        }
        
        // 3. Gắn tham số vào URL String
        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }
        
        // 4. Ép kiểu URL và yêu cầu iOS mở ứng dụng Mail
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
    
    // Hàm dùng chung để cắt chữ theo tiền tố (prefix)
    private func extractValue(for prefix: String) -> String {
        guard let content = entity.rawContent else { return "" }
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix(prefix) {
                return String(line.dropFirst(prefix.count))
            }
        }
        return ""
    }}
