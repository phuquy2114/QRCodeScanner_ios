//
//  FeedbackItemCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//

import UIKit
class FeedbackItemCell: BaseTableViewCell {
    
    private let button = UIButton()
    var onTapButton: ((Int) -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.isUserInteractionEnabled = true
        button.titleLabel?.font = .systemFont(ofSize: 20)
        // 1. Tạo một configuration mới (chọn .plain() vì bạn đang dùng nút trong suốt có viền)
        var config = UIButton.Configuration.plain()

        // 2. Cài đặt padding (Chú ý: dùng NSDirectionalEdgeInsets thay vì UIEdgeInsets)
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        // Nếu bạn có cả icon và text thì dùng titlePadding để tạo khoảng cách giữa chúng
        config.titlePadding = 6
        
        button.configuration = config
    }
    
    override func setupConstraints() {
        contentView.addSubview(button)
        button.changeConstraints()
        NSLayoutConstraint.activate([
            button.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor
                .constraint(lessThanOrEqualTo: contentView.trailingAnchor),
        ])
        
    }
    
    func configure(with model: ProblemItem, _ index: Int) {
        button.setTitle(model.title.uppercased(), for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        
        let color = model.isSelected ? AppThemeColor.blue.color() : .white
        
        button.layer.borderColor = color.cgColor
        button.setTitleColor(color, for: .normal)
    }
    
    @objc private func onTap(_ sender: UIButton) {
        self.onTapButton?(sender.tag)
    }
}
