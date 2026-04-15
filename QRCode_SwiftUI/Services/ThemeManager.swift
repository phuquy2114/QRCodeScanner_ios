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

// MARK: - Environment Key
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeManager = .shared
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct ThemeTintModifier: ViewModifier {
    @EnvironmentObject var theme: ThemeManager
    func body(content: Content) -> some View {
        content.tint(theme.accent)
    }
}


enum ThemeColor: String, CaseIterable, Codable  {

    case yellow, blue, green, orange, red
    
    var displayName: String { rawValue.capitalized }
    
    func color() -> Color {
        switch self {
        case .yellow:
            return Color(hex: "#FFBF1A")
        case .blue:
            return Color(hex: "#3B8BFF")
        case .green:
            return Color(hex: "#2ECC71")
        case .orange:
            return Color(hex: "#FF6B35")
        case .red:
            return Color(hex: "#FF3B30")
        }
    }
}
