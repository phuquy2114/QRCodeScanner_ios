//
//  AppTab.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 18/4/26.
//

import Foundation
import SwiftUI

enum AppTab: String, CaseIterable {
    case scan, history, create, favorite, settings

    var title: String {
        return self.rawValue.capitalized
    }

    var icon: Image {
        switch self {
        case .scan:
            return getImageSystem("qrcode.viewfinder")
        case .history:
            return getImageSystem("clock.arrow.circlepath")
        case .create:
            return getImageSystem("qrcode")
        case .favorite:
            return getImageSystem("heart.fill")
        case .settings:
            return getImageSystem("gearshape.fill")
        }
    }
    
    private func getImageSystem(_ name: String) -> Image {
        return Image(systemName: name)
    }
}
