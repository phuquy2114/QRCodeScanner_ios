//
//  FeedbackModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//

struct FeedbackModel {
    let title: String
    let desc: String?
    let attachFiles: [String]?
}

struct ProblemItem {
    let title: String
    var isSelected: Bool = false
    
    mutating func setDefaultValue() {
        self.isSelected = false
    }
}
