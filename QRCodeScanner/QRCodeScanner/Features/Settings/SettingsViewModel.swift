//
//  SettingsViewModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import Combine
import Foundation

final class SettingsViewModel: BaseViewModel {

    // MARK: - Theme
    @Published var selectedTheme: AppThemeColor = ThemeManager.shared
        .currentTheme

    // MARK: - Sound / Focus Toggles
    @Published var isVibrate: Bool = UserDefaults.standard.bool(
        forKey: "pref_vibrate",
        default: true
    )
    @Published var isBeep: Bool = UserDefaults.standard.bool(
        forKey: "pref_beep",
        default: true
    )
    @Published var isAutoFocus: Bool = UserDefaults.standard.bool(
        forKey: "pref_autofocus",
        default: true
    )
    @Published var isTouchFocus: Bool = UserDefaults.standard.bool(
        forKey: "pref_touchfocus",
        default: true
    )

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        bindTheme()
        bindToggles()
    }

    private func bindTheme() {
        $selectedTheme
            .dropFirst()
            .sink { ThemeManager.shared.apply($0) }
            .store(in: &cancellables)
    }

    private func bindToggles() {
        $isVibrate.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "pref_vibrate") }
            .store(in: &cancellables)
        $isBeep.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "pref_beep") }
            .store(in: &cancellables)
        $isAutoFocus.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "pref_autofocus") }
            .store(in: &cancellables)
        $isTouchFocus.dropFirst()
            .sink { UserDefaults.standard.set($0, forKey: "pref_touchfocus") }
            .store(in: &cancellables)
    }
}

// MARK: - UserDefaults bool helper

extension UserDefaults {
    fileprivate func bool(forKey key: String, default defaultValue: Bool)
        -> Bool
    {
        object(forKey: key) != nil ? bool(forKey: key) : defaultValue
    }
}
