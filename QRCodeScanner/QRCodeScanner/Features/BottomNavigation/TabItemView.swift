//
//  TabItemView.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//

import UIKit

final class TabItemView: UIView {
    // Màu lấy từ ThemeManager — luôn up to date
    private var themeColor: UIColor { ThemeManager.shared.themeColor }
    private var normalColor: UIColor { UIColor(white: 0.65, alpha: 1) }

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let tab: AppTab
    private var isSelected = false

    init(tab: AppTab) {
        self.tab = tab
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.image = tab.icon()?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = self.normalColor
        addSubview(iconView)

        // Title
        titleLabel.text = tab.title()
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = self.normalColor
        addSubview(titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize: CGFloat = 24
        let labelH: CGFloat = 14
        let spacing: CGFloat = 3
        let totalH = iconSize + spacing + labelH
        let startY = (bounds.height - totalH) / 2

        iconView.frame = CGRect(
            x: (bounds.width - iconSize) / 2,
            y: startY,
            width: iconSize,
            height: iconSize
        )
        titleLabel.frame = CGRect(
            x: 0,
            y: iconView.frame.maxY + spacing,
            width: bounds.width,
            height: labelH
        )
    }

    func updateTheme(color: UIColor, isSelected: Bool) {
        if isSelected {
            iconView.tintColor = color
            titleLabel.textColor = color
        }
        // non-selected items keep normalColor, no change needed
    }

    func setSelected(_ selected: Bool) {
        isSelected = selected
        let color = selected ? themeColor : normalColor
        iconView.tintColor = color
        titleLabel.textColor = color
        titleLabel.font = .systemFont(
            ofSize: 13,
            weight: selected ? .bold : .semibold
        )

        // Scale icon khi được chọn
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            self.iconView.transform =
                selected
                ? CGAffineTransform(scaleX: 1.12, y: 1.12)
                : .identity
        }
    }

}
