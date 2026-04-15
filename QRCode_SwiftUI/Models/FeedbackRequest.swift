//
//  FeedbackRequest.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 12/4/26.
//

import SwiftUI

struct FeedbackRequest {
    var typeProblem: String
    var description: String?
    let attachFiles: [Image]
    let time: Date
    
    /// Convert Date → ISO8601 String để gửi lên
    var timeString: String {
        ISO8601DateFormatter().string(from: time)
    }
}

struct FeedbackResponse: Decodable {
    let id: String
    let status: String
    let createdAt: String?     // snake_case → camelCase tự động
}
