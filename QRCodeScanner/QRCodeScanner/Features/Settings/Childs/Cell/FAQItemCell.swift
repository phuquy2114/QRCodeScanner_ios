//
//  FAQItemCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 30/3/26.
//

import UIKit

// MARK: - FAQItemCell (accordion row)

final class FAQItemCell: BaseTableViewCell {

    // MARK: Views

    private let card = UIView()
    private let iconImageView = UIImageView()
    private let questionLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let answerLabel = UILabel()
    private let divider = UIView()
    private let expandableContainer = UIView()
    private var expandableHeightConstraint: NSLayoutConstraint!
    
    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    // MARK: Build Layout
    override func setupUI() {
        // Card
        card.backgroundColor = .backgroundColor
        card.layer.cornerRadius = 14
        card.clipsToBounds = true
        card.changeConstraints()
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 6
            ),
            card.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -6
            ),
            card.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            card.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
        ])
        
        // ── Icon ─
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.changeConstraints()
        contentView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: card.leadingAnchor,
                constant: 16
            ),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
        ])

        // Question label
        questionLabel.font = .boldSystemFont(ofSize: 20)
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        questionLabel.changeConstraints()
        card.addSubview(questionLabel)

        // Chevron
        let chevronConfig = UIImage.SymbolConfiguration(
            pointSize: 13,
            weight: .semibold
        )
        chevronImageView.image = UIImage(
            systemName: "chevron.down",
            withConfiguration: chevronConfig
        )
        chevronImageView.tintColor = .white
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.changeConstraints()
        card.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            questionLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor,
                constant: 14
            ),
            questionLabel.trailingAnchor.constraint(
                equalTo: chevronImageView.leadingAnchor,
                constant: -12
            ),
            questionLabel.topAnchor.constraint(
                greaterThanOrEqualTo: card.topAnchor,
                constant: 16
            ),

            iconImageView.centerYAnchor.constraint(
                equalTo: questionLabel.centerYAnchor
            ),

            chevronImageView.trailingAnchor.constraint(
                equalTo: card.trailingAnchor,
                constant: -16
            ),
            chevronImageView.centerYAnchor.constraint(
                equalTo: iconImageView.centerYAnchor
            ),
            chevronImageView.widthAnchor.constraint(equalToConstant: 20),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
        ])

        
        // ── Expandable container ──────────────────────────────
        // clipsToBounds = true → khi height = 0, content bị ẩn hoàn toàn
        expandableContainer.clipsToBounds = true
        expandableContainer.changeConstraints()
        card.addSubview(expandableContainer)
        
        // height = 0 mặc định (collapsed)
        expandableHeightConstraint = expandableContainer.heightAnchor.constraint(equalToConstant: 0)
        // cho phép nội dung bên trong push nếu cần
        //expandableHeightConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            expandableContainer.topAnchor
                .constraint(equalTo: questionLabel.bottomAnchor, constant: 0),
            expandableContainer.widthAnchor
                .constraint(equalTo: card.widthAnchor),
            expandableContainer.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            expandableHeightConstraint
        ])
        
        // Divider
        divider.backgroundColor = UIColor(white: 1, alpha: 0.1)
        divider.changeConstraints()
        divider.clipsToBounds = true
        divider.isHidden = true
        expandableContainer.addSubview(divider)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(
                equalTo: expandableContainer.topAnchor,
                constant: 16
            ),
            divider.leadingAnchor.constraint(
                equalTo: expandableContainer.leadingAnchor,
                constant: 16
            ),
            divider.centerXAnchor.constraint(equalTo: expandableContainer.centerXAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])

        // Answer label
        answerLabel.font = .systemFont(ofSize: 18)
        answerLabel.textColor = UIColor(white: 0.8, alpha: 1)
        answerLabel.numberOfLines = 0
        answerLabel.clipsToBounds = true
        answerLabel.isHidden = true
        answerLabel.changeConstraints()
        expandableContainer.addSubview(answerLabel)

        NSLayoutConstraint.activate([
            answerLabel.topAnchor.constraint(
                equalTo: divider.bottomAnchor,
                constant: 12
            ),
            answerLabel.leadingAnchor.constraint(
                equalTo: expandableContainer.leadingAnchor,
                constant: 16
            ),
            answerLabel.centerXAnchor.constraint(equalTo: expandableContainer.centerXAnchor),

        ])
        
        NSLayoutConstraint.activate([
            answerLabel.bottomAnchor.constraint(
                equalTo: expandableContainer.bottomAnchor,
                constant: -16
            ),
        ])
        
    }

    // MARK: Configure

    func configure(with item: FAQItem) {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconImageView.image = UIImage(
            systemName: item.icon,
            withConfiguration: config
        )?.withRenderingMode(.alwaysTemplate)
        
        questionLabel.text = item.question
        answerLabel.text = item.answer

        let isExpanded = item.isExpanded
        answerLabel.isHidden = !isExpanded
        divider.isHidden = !isExpanded

        let chevronConfig = UIImage.SymbolConfiguration(
            pointSize: 13,
            weight: .semibold
        )
        let chevronName = isExpanded ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(
            systemName: chevronName,
            withConfiguration: chevronConfig
        )
        
        // deactivate height = 0 khi expand, activate khi collapse
        if item.isExpanded {
            NSLayoutConstraint.deactivate([
                expandableHeightConstraint,
                questionLabel.bottomAnchor
                    .constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
        } else {
            NSLayoutConstraint.activate([
                expandableHeightConstraint,
                questionLabel.bottomAnchor
                    .constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
        }
        
    }
}
