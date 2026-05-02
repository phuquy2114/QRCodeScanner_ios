//
//  CreateQREventViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 2/5/26.
//

import Combine
import Foundation

@MainActor  // Bắt buộc thêm @MainActor vì kế thừa từ BaseCreateQRViewModel
class CreateQREventViewModel: BaseCreateQRViewModel {
    @Published var title: String = ""
    @Published var isAllDay: Bool = false
    @Published var startDate: Date = Date()
    // Mặc định kết thúc sau 1 tiếng
    @Published var endDate: Date = Date().addingTimeInterval(3600)
    @Published var desc: String = ""

    override func handleCreateQR() {

        // 1. Validate Tiêu đề và Thời gian
        let rules: [ValidationRule] = [
            .nonEmpty(title, fieldName: "Event Title"),
            .custom(
                condition: startDate >= endDate,
                message: "End time must be after Start time."
            ),
        ]

        guard validate(rules) else { return }

        // 2. Format Ngày Giờ theo chuẩn vEvent (VD: 20231231T235959Z)
        let formatter = DateFormatter()
        // Phải đưa về múi giờ UTC/GMT để thiết bị quét tự động đổi lại theo múi giờ địa phương của họ
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        if isAllDay {
            // All day thì chỉ cần YYYYMMDD
            formatter.dateFormat = "yyyyMMdd"
        } else {
            // Có giờ phút thì là YYYYMMDDTHHmmssZ
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        }

        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)

        // 3. Tạo chuỗi chuẩn vEvent
        // Dùng định dạng VEVENT lồng trong VCALENDAR
        var vEventString = """
            BEGIN:VCALENDAR
            VERSION:2.0
            BEGIN:VEVENT
            SUMMARY:\(title)
            DTSTART:\(startString)
            DTEND:\(endString)
            """

        // Thêm mô tả nếu có
        if !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            vEventString += "\nDESCRIPTION:\(desc)"
        }

        vEventString += """

            END:VEVENT
            END:VCALENDAR
            """

        // 4. Sinh QR Code
        generateQR(data: vEventString)
    }

    override var qrRawContent: String {
        // Format lại thời gian để lưu vào lịch sử hiển thị cho người dùng đọc dễ hiểu
        let displayFormatter = DateFormatter()
        if isAllDay {
            displayFormatter.dateFormat = "MMM d, yyyy (All Day)"
        } else {
            displayFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        }

        var details: [String] = [
            "Event: \(title)",
            "Start: \(displayFormatter.string(from: startDate))",
            "End: \(displayFormatter.string(from: endDate))",
        ]

        if !desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            details.append("Description: \(desc)")
        }

        return details.joined(separator: "\n")
    }
}
