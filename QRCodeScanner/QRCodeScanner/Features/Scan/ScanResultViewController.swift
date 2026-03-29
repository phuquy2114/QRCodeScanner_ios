//
//  ScanResultViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 23/3/26.
//

import UIKit

// MARK: - ScanResultViewController (placeholder shell)
final class ScanResultViewController: UIViewController {
    private let result: ScanResult
    private let onDismiss: () -> Void
 
    init(result: ScanResult, onDismiss: @escaping () -> Void) {
        self.result    = result
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
 
        let label = UILabel()
        label.text          = result.content
        label.textColor     = .white
        label.font          = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss()
    }
}
