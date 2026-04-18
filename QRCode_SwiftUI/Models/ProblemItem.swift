//
//  ProblemItem.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 18/4/26.
//

import Foundation

struct ProblemItem: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool
}
