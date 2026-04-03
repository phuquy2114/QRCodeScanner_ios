//
//  BaseCollectionViewCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 27/3/26.
//

import UIKit
open class BaseCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    /// Reuse identifier chuẩn (tự động lấy tên class)
    open class var identifier: String {
        return String(describing: self)
    }
    
    /// Nếu dùng XIB/Storyboard, override để trả về UINib
    open class var nib: UINib? {
        return nil // override ở cell con nếu cần: UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Initialization
    public required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    // Convenience overload nếu dùng generic hoặc protocol
    func configure<Model: CollectionCellConfigurable>(with model: Model) where Model.Cell: UICollectionViewCell {
        if let cell = self as? Model.Cell {
            model.configure(cell: cell)
        }
    }
    
    // MARK: - Reuse
    open override func prepareForReuse() {
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
protocol CollectionCellConfigurable {
    associatedtype Cell: UICollectionViewCell
    func configure(cell: Cell)
}
