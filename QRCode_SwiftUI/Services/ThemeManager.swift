//
//  ThemeManager.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import Combine
import SwiftUI

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var current: ThemeColor {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "app_theme")
        }
    }
    
    // Shortcut dùng trong View
    var accent: Color { current.color() }
    
    private init() {
        let saved = UserDefaults.standard.string(forKey: "app_theme") ?? ""
        current = ThemeColor(rawValue: saved) ?? .yellow
    }

    func setNewTheme(_ theme: ThemeColor) {
        withAnimation(.easeInOut(duration: 0.25)) {
            current = theme
        }
    }
}

struct ThemeTintModifier: ViewModifier {
    @EnvironmentObject var theme: ThemeManager
    func body(content: Content) -> some View {
        content.tint(theme.accent)
    }
}
