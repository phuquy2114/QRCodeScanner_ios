//
//  FilledButton.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 2/4/26.
//

import UIKit

final class FilledButton: UIButton {
    private let indicator = UIActivityIndicatorView(style: .medium)
    
    var title: String? {
        set { setTitle(newValue, for: .normal) }
        get { self.titleLabel?.text }
    }
    var titleColor: UIColor? {
        set { setTitleColor(newValue, for: .normal) }
        get { titleLabel?.textColor }
    }
    
    
    required init?(coder: NSCoder) { fatalError() }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = .boldSystemFont(ofSize: 22)
        self.backgroundColor = ThemeManager.shared.themeColor
        setTitleColor(.black, for: .normal)
        layer.cornerRadius = 14
        self.applyAccentBackground()
        heightAnchor.constraint(equalToConstant: 48).isActive = true

        indicator.hidesWhenStopped = true
        indicator.color = ThemeManager.shared.themeColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        backgroundColor = enabled ? ThemeManager.shared.themeColor : .gray
    }

    func setLoading(_ loading: Bool) {
        isUserInteractionEnabled = !loading
        loading ? indicator.startAnimating() : indicator.stopAnimating()
    }
}

