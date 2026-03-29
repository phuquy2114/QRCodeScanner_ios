//
//  ThemeRadioView.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 28/3/26.
//

import UIKit

// MARK: - ThemeRadioView

final class ThemeRadioView: UIView {

    let theme: AppThemeColor
    var onTap: (() -> Void)?

    private let radioOuter = UIView()
    private let radioDot = UIView()
    private let nameLabel = UILabel()

    private let outerSize: CGFloat = 26
    private let dotSize: CGFloat = 14

    init(theme: AppThemeColor) {
        self.theme = theme
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Outer ring
        radioOuter.layer.cornerRadius = outerSize / 2
        radioOuter.layer.borderWidth = 2
        radioOuter.layer.borderColor = theme.color().cgColor
        radioOuter.backgroundColor = .clear
        radioOuter.translatesAutoresizingMaskIntoConstraints = false
        addSubview(radioOuter)

        // Inner dot
        radioDot.backgroundColor = theme.color()
        radioDot.layer.cornerRadius = dotSize / 2
        radioDot.alpha = 0
        radioDot.translatesAutoresizingMaskIntoConstraints = false
        radioOuter.addSubview(radioDot)

        // Label
        nameLabel.text = theme.rawValue.capitalizingFirstLetter()

        nameLabel.font = .systemFont(ofSize: 17)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)

        NSLayoutConstraint.activate([
            radioOuter.leadingAnchor.constraint(equalTo: leadingAnchor),
            radioOuter.centerYAnchor.constraint(equalTo: centerYAnchor),
            radioOuter.widthAnchor.constraint(equalToConstant: outerSize),
            radioOuter.heightAnchor.constraint(equalToConstant: outerSize),

            radioDot.centerXAnchor.constraint(
                equalTo: radioOuter.centerXAnchor
            ),
            radioDot.centerYAnchor.constraint(
                equalTo: radioOuter.centerYAnchor
            ),
            radioDot.widthAnchor.constraint(equalToConstant: dotSize),
            radioDot.heightAnchor.constraint(equalToConstant: dotSize),

            nameLabel.leadingAnchor.constraint(
                equalTo: radioOuter.trailingAnchor,
                constant: 14
            ),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapped)
        )
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5
        ) {
            self.radioDot.alpha = selected ? 1 : 0
            self.radioDot.transform =
                selected ? .identity : CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.radioOuter.layer.borderColor =
                selected
                ? self.theme.color().cgColor
                : self.theme.color().withAlphaComponent(0.5).cgColor
            self.nameLabel.font = .systemFont(
                ofSize: 17,
                weight: selected ? .semibold : .regular
            )
        }
    }

    @objc private func tapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTap?()
    }
}
