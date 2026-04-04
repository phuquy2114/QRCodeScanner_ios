//
//  StructWrapper.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 4/4/26.
//

import SwiftUI

// MARK: ══════════════════════════════════════════
// MARK: PHẦN 2 — BRIDGE: SwiftUI → UIKit
// UIViewControllerRepresentable: nhúng UIKit VC vào SwiftUI
// ══════════════════════════════════════════════

// MARK: - UIKitWrapper (generic, dùng cho bất kỳ UIViewController)
struct UIKitWrapper<VC: UIViewController>: UIViewControllerRepresentable {
    let makeVC: () -> VC
    var configure: ((VC) -> Void)? = nil

    func makeUIViewController(context: Context) -> VC {
        makeVC()
    }

    func updateUIViewController(_ uiViewController: VC, context: Context) {
        configure?(uiViewController)
    }
}

// MARK: - NavigationControllerWrapper
// Dùng khi cần wrap UINavigationController bên trong SwiftUI
struct NavigationControllerWrapper: UIViewControllerRepresentable {
    let rootViewController: UIViewController

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: rootViewController)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - Camera Scanner Wrapper (UIKit → SwiftUI)
// Nhúng ScanViewController (UIKit) vào SwiftUI screen
struct CameraScannerView: UIViewControllerRepresentable {
    @Binding var scannedResult: String?
    var onDismiss: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> ScanViewController {
        ScanViewController()
    }

    func updateUIViewController(_ uiViewController: ScanViewController, context: Context) {}
}
