//
//  AppEnvironment.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 4/4/26.
//
// MARK: ══════════════════════════════════════════
// MARK: PHẦN 3 — ENVIRONMENT & SHARED STATE
// Truyền ThemeManager, NavigationRouter vào SwiftUI Environment
// ══════════════════════════════════════════════

import SwiftUI
import Combine

// MARK: - AppEnvironment (inject vào SwiftUI root)

struct AppEnvironment {
    let theme: ThemeManager
}

// EnvironmentKey
private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppEnvironment(theme: ThemeManager.shared)
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

// MARK: - ThemeManager + ObservableObject bridge
// Wrap ThemeManager để SwiftUI tự re-render khi theme đổi
final class AppThemeObservable: ObservableObject {
    
    @Published var themeColor: Color = Color(ThemeManager.shared.themeColor)

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: .themeDidChange)
            .compactMap { $0.object as? UIColor }
            .receive(on: RunLoop.main)
            .sink { [weak self] uiColor in
                self?.themeColor  = Color(uiColor)
            }
    }
}

// Environment Key cho theme
private struct ThemeColorKey: EnvironmentKey {
    static let defaultValue: Color = Color(ThemeManager.shared.themeColor)
}

extension EnvironmentValues {
    var appThemeColor: Color {
        get { self[ThemeColorKey.self] }
        set { self[ThemeColorKey.self] = newValue }
    }
}

// MARK: - NavigationRouter (điều hướng từ SwiftUI sang UIKit)
@MainActor
final class NavigationRouter: ObservableObject {
    static let shared = NavigationRouter()

    /// Tham chiếu đến UINavigationController đang active
    weak var navigationController: UINavigationController?

    /// Push UIKit VC từ SwiftUI
    func push(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }

    /// Push SwiftUI View từ SwiftUI (dùng UIHostingController)
    func push<V: View>(_ view: V, title: String? = nil, animated: Bool = true) {
        let hosting = HostingViewController(rootView: view, navigationTitle: title)
        navigationController?.pushViewController(hosting, animated: animated)
    }

    /// Dismiss/pop
    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
}
