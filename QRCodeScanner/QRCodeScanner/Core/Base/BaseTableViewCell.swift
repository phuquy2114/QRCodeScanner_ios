//
//  BaseTableViewCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

import UIKit
class BaseTableViewCell: UITableViewCell {
    
    // Identifier mặc định dùng tên của Class (giúp register cell dễ dàng hơn)
    static var identifier: String {
        return String(describing: self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }
    
    // Các hàm để class con override
    func setupViews() {
        // Thêm các subviews vào contentView ở đây
    }
    
    func setupConstraints() {
        // Thiết lập AutoLayout ở đây
    }
}

