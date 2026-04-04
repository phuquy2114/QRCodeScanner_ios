//
//  HostingViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 4/4/26.
//

import UIKit
import SwiftUI
import Combine

// MARK: ══════════════════════════════════════════
// MARK: PHẦN 1 — BRIDGE: UIKit → SwiftUI
// UIHostingController: nhúng SwiftUI View vào UIKit
// ══════════════════════════════════════════════

// MARK: - HostingViewController (base wrapper)
// Dùng thay vì UIHostingController trực tiếp để có lifecycle hooks
class HostingViewController<Content: View>: UIViewController {
    private let hostingController: UIHostingController<Content>
    
    init(rootView: Content, navigationTitle: String? = nil) {
        self.hostingController = UIHostingController(rootView: rootView)
        super.init(nibName: nil, bundle: nil)
        self.title = navigationTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        embedHostingController()
    }
    
    private func embedHostingController() {
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
    
    /// Update SwiftUI view content (dùng khi cần re-render)
    func updateRootView(_ newView: Content) {
        hostingController.rootView = newView
    }
}
