//
//  CreateQR.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 18/4/26.
//

import Foundation
import SwiftUI

enum CreateQR: String, CaseIterable, Codable {
    case text, website, wifi, event, contact, business, location, sms, whatsapp, email,
    twitter, instagram, telephone
    
    func title() -> String {
        self == .sms ? rawValue.uppercased() : rawValue.capitalized
    }
    
    func icon() -> Image? {
        switch self {
        case .text:
            return Image(systemName: "textbox")
        case .website:
            return Image("website")
        case .wifi:
            return Image(systemName: "wifi")
        case .event:
            return Image(systemName: "note.text")
        case .contact:
            return Image(systemName: "person.crop.circle")
        case .business:
            return Image("business")
        case .location:
            return Image("location")
        case .sms:
            return Image(systemName: "bubble.left.and.text.bubble.right.fill")
        case .whatsapp:
            return Image("whatsapp")
        case .email:
            return Image(systemName: "envelope.fill")
        case .twitter:
            return Image("twitter")
        case .instagram:
            return Image("instagram")
        case .telephone:
            return Image(systemName: "phone.arrow.down.left.fill")
        }
    }
}
