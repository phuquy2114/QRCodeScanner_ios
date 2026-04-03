//
//  ImageSection.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 2/4/26.
//

import UIKit

// MARK: ImageSection
final class ImageSection: UIView {
    var onAddTapped: (() -> Void)?
    var onRemoveTapped: ((Int) -> Void)?

    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            heightAnchor.constraint(equalToConstant: 80),
        ])
        refreshAddButton(canAdd: true)
    }
    required init?(coder: NSCoder) { fatalError() }

    func setImages(_ images: [UIImage], canAdd: Bool) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        images.enumerated().forEach { index, image in
            let thumb = makeThumb(image: image, index: index)
            stack.addArrangedSubview(thumb)
        }
        if canAdd { refreshAddButton(canAdd: true) }
    }

    private func refreshAddButton(canAdd: Bool) {
        let btn = UIButton(type: .system)
        btn.setImage(
            UIImage(systemName: "plus")?
                .withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                ),
            for: .normal
        )
        btn.tintColor = ThemeManager.shared.themeColor
        btn.backgroundColor = UIColor(white: 0.15, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = ThemeManager.shared.themeColor.cgColor
        btn.widthAnchor.constraint(equalToConstant: 72).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 72).isActive = true
        btn.addAction(
            .init { [weak self] _ in self?.onAddTapped?() },
            for: .touchUpInside
        )
        stack.addArrangedSubview(btn)
        self.observerNewTheme { color in
            btn.tintColor = color
            btn.layer.borderColor = color.cgColor
        }
    }

    private func makeThumb(image: UIImage, index: Int) -> UIView {
        let container = UIView()
        container.widthAnchor.constraint(equalToConstant: 72).isActive = true
        container.heightAnchor.constraint(equalToConstant: 72).isActive = true

        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iv)

        let removeBtn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        removeBtn.setImage(
            UIImage(systemName: "xmark", withConfiguration: cfg),
            for: .normal
        )
        removeBtn.tintColor = .white
        removeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        removeBtn.layer.cornerRadius = 10
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(removeBtn)
        removeBtn.addAction(
            .init { [weak self] _ in
                self?.onRemoveTapped?(index)
            },
            for: .touchUpInside
        )

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            iv.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            removeBtn.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 4
            ),
            removeBtn.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -4
            ),
            removeBtn.widthAnchor.constraint(equalToConstant: 20),
            removeBtn.heightAnchor.constraint(equalToConstant: 20),
        ])
        return container
    }
}

