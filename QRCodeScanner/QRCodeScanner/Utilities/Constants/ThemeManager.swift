//
//  ThemeManager.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//
// MARK: - ThemeManager

import Combine
import Foundation
import UIKit

final class ThemeManager {

    // MARK: - Singleton
    static let shared = ThemeManager()

    private init() {
        newTheme = .yellow
        currentTheme = .yellow
        
        var theme = self.load()
        newTheme = theme
        currentTheme = theme
    }

    // MARK: - Published

    /// Combine publisher — observe ở bất kỳ đâu
    @Published private(set) var currentTheme: AppThemeColor {
        didSet {
            guard oldValue != currentTheme else { return }
            self.save(currentTheme)
            applyGlobally()
        }
    }

    // backing store để tránh didSet loop
    private var newTheme: AppThemeColor {
        didSet { currentTheme = newTheme }
    }

    // MARK: - Public API

    /// Màu accent hiện tại — dùng ở mọi nơi
    var themeColor: UIColor { currentTheme.color() }
    //var onAccentColor: UIColor { currentTheme.onAccentColor() }

    /// Đổi theme
    func apply(_ newTheme: AppThemeColor) {
        self.newTheme = newTheme
    }

    // MARK: - Global UIAppearance

    /// Gọi 1 lần sau khi load app + mỗi khi đổi theme
    func applyGlobally() {
        let accent = themeColor

        // UISwitch
        UISwitch.appearance().onTintColor = accent

        // UISlider
        UISlider.appearance().minimumTrackTintColor = accent
        UISlider.appearance().thumbTintColor = accent

        // UIProgressView
        UIProgressView.appearance().progressTintColor = accent

        // UIPageControl
        UIPageControl.appearance().currentPageIndicatorTintColor = accent

        // NavigationBar tint
        UINavigationBar.appearance().tintColor = accent

        // Notify toàn app re-render (iOS 15+)
        refreshAllWindows()
    }

    /// Khởi động app — gọi trong AppDelegate / SceneDelegate
    func bootstrap() {
        applyGlobally()
    }

    // MARK: - Persistence

    private let storageKey = "app_theme_color"

    private func save(_ theme: AppThemeColor) {
        UserDefaults.standard.set(theme.rawValue, forKey: storageKey)
    }

    private func load() -> AppThemeColor {
        guard let raw = UserDefaults.standard.string(forKey: storageKey),
            let theme = AppThemeColor(rawValue: raw)
        else { return .yellow }
        return theme
    }

    // MARK: - Private

    private func refreshAllWindows() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.setNeedsLayout() }

        // Notify custom components (tab bar, v.v.)
        NotificationCenter.default.post(
            name: .themeDidChange,
            object: themeColor
        )
    }
}
