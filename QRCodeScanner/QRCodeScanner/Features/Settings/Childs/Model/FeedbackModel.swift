//
//  FeedbackModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//

import Foundation
import UIKit

// MARK: ──────────────────────────────────────────
// MARK: - FeedbackRequest  (body gửi lên server)
// ──────────────────────────────────────────────
struct FeedbackRequest {
    let title: String
    let description: String?
    let attachFiles: [UIImage]
    let time: Date
    
    /// Convert Date → ISO8601 String để gửi lên
    var timeString: String {
        ISO8601DateFormatter().string(from: time)
    }
}


// MARK: ──────────────────────────────────────────
// MARK: - FeedbackResponse  (data server trả về)
// ──────────────────────────────────────────────
struct FeedbackResponse: Decodable {
    let id: String
    let status: String
    let createdAt: String?     // snake_case → camelCase tự động
}

struct ProblemItem {
    let title: String
    var isSelected: Bool = false
    
    mutating func setDefaultValue() {
        self.isSelected = false
    }
}
