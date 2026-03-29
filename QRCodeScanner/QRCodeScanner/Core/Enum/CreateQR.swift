//
//  CreateQR.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 27/3/26.
//

import UIKit

enum CreateQR: String, CaseIterable, Codable {
    case text, website, wifi, event, contact, business, location, sms, whatsapp, email,
    twitter, instagram, telephone
    
    func title() -> String {
        switch self {
        case .sms:
            return self.rawValue.uppercased()
        default :
            return self.rawValue.capitalizingFirstLetter()
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .text:
            return UIImage(systemName: "textbox")
        case .website:
            return UIImage(named: "website")
        case .wifi:
            return UIImage(systemName: "wifi")
        case .event:
            return UIImage(systemName: "note.text")
        case .contact:
            return UIImage(systemName: "person.crop.circle")
        case .business:
            return UIImage(named: "business.svg")
        case .location:
            return UIImage(named: "location")
        case .sms:
            return UIImage(systemName: "bubble.left.and.text.bubble.right.fill")
        case .whatsapp:
            return UIImage(named: "whatsapp")
        case .email:
            return UIImage(systemName: "envelope.fill")
        case .twitter:
            return UIImage(named: "twitter")
        case .instagram:
            return UIImage(named: "instagram")
        case .telephone:
            return UIImage(systemName: "phone.arrow.down.left.fill")
        }
    }
    
    
}
