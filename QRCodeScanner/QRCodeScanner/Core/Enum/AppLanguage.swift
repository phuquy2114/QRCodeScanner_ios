//
//  AppLanguage.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//
import Foundation
import UIKit

// MARK: - App Languages
public enum AppLanguage: String, CaseIterable {
    case vietnamese = "vi"
    case english = "en"
}

// MARK: - Language Manager
public final class LanguageManager: @unchecked Sendable {
    public static let shared = LanguageManager()
    
    private let languageKey = "AppSelectedLanguage"
    
    private init() {}
    
    /// Ngôn ngữ hiện tại của app (Mặc định là Tiếng Việt)
    public var currentLanguage: AppLanguage {
        get {
            if let saved = UserDefaults.standard.string(forKey: languageKey),
               let lang = AppLanguage(rawValue: saved) {
                return lang
            }
            // Nếu chưa chọn, tự detect theo ngôn ngữ máy, nếu không ra thì lấy "vi"
            let deviceLang = Locale.preferredLanguages.first?.prefix(2) ?? "vi"
            return AppLanguage(rawValue: String(deviceLang)) ?? .vietnamese
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: languageKey)
            NotificationCenter.default.post(name: .languageDidChange, object: nil)
        }
    }
    
    /// Trả về Bundle chứa file .strings tương ứng với ngôn ngữ đang chọn
    public var currentBundle: Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }
    
    @MainActor
    func reloadAppToApplyLanguage(viewController: UIViewController) {
        // 1. Lấy cửa sổ (Window) hiện tại của app
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // 2. Khởi tạo lại màn hình gốc của bạn (Thay bằng màn hình bạn muốn hiển thị sau khi đổi ngôn ngữ)
        let rootNav = UINavigationController(rootViewController: viewController)
        
        // 3. Thay thế RootVC với hiệu ứng mờ (Cross-Dissolve)
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = rootNav
        }, completion: nil)
    }
}

