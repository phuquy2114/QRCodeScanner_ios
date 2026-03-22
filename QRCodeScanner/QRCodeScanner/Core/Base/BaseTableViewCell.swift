//
//  BaseTableViewCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

import UIKit
/// Base class cho tất cả custom UITableViewCell
/// - Sử dụng trong MVVM: cell.configure(with: viewModel.item)
class BaseTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    /// Reuse identifier chuẩn (tự động lấy tên class)
    class var identifier: String {
        return String(describing: self)
    }
    
    /// Nếu dùng XIB/Storyboard, override để trả về UINib
    class var nib: UINib? {
        return nil // override ở cell con nếu cần: UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup (gọi 1 lần khi init)
    /// Override để thêm subviews, style chung
    func setupUI() {
        // Ví dụ: selectionStyle = .none
        // backgroundColor = .systemBackground
        // contentView.backgroundColor = .clear
    }
    
    /// Override để setup Auto Layout constraints
    func setupConstraints() {
        // Để cell con override nếu cần layout code-based
    }
    
    // MARK: - Configure (MVVM chính)
    /// Method chính để bind data vào cell
    /// - Parameter model: Model hoặc ViewModel item
    func configure(with model: Any) {
        // Cell con sẽ override method này
        // Ví dụ: fatalError("configure(with:) phải được override ở subclass")
    }
    
    // Convenience overload nếu bạn dùng generic hoặc protocol
//    func configure<Model: CellConfigurable>(with model: Model) where Model.Cell == Self {
//        model.configure(cell: self)
//    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset trạng thái để tránh data cũ leak
        // Ví dụ:
        // textLabel?.text = nil
        // imageView?.image = nil
        // backgroundColor = .clear (nếu cần)
    }
}

// MARK: - Protocol hỗ trợ (optional, rất tiện cho MVVM)

/// Protocol để ViewModel tự configure cell
protocol CellConfigurable {
    associatedtype Cell: UITableViewCell
    func configure(cell: Cell)
}

