//
//  CreateQRCodeCollectionViewCell.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 27/3/26.
//

import UIKit


class CreateQRCodeCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var bigTitle: UILabel!
    @IBOutlet weak var smallTitle: PaddingLabel!
    @IBOutlet weak var outlineView: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    var accentColor: UIColor = ThemeManager.shared.themeColor {
        didSet {
            setNeedsDisplay()
            smallTitle.backgroundColor = accentColor
            icon.tintColor = accentColor
            outlineView.layer.borderColor = accentColor.cgColor
        }
    }
        
    override class var nib: UINib? {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    override func setupUI() {

        background.backgroundColor = .backgroundColor
        background.layer.cornerRadius = 16
        
        outlineView.backgroundColor = .clear
        outlineView.layer.cornerRadius = 6
        outlineView.layer.borderColor = accentColor.cgColor
        outlineView.layer.borderWidth = 1
        
        icon.tintColor = accentColor
        
        bigTitle.textColor = .white
        bigTitle.font = .systemFont(ofSize: 18)
        
        smallTitle.textColor = .black
        smallTitle.backgroundColor = accentColor
        smallTitle.font = .systemFont(ofSize: 10)
        smallTitle.textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        // Chỉnh bo góc 4 và bắt buộc phải có clipsToBounds = true để cắt màu nền
        smallTitle.clipsToBounds = true
        smallTitle.layer.cornerRadius = 4
        smallTitle.textAlignment = .center
        smallTitle.observerNewTheme { [weak self] color in
            self?.accentColor = color
        }
    }
    
    override func configure(with model: Any) {
        guard let model = model as? CreateQR else { return }
        smallTitle.text = model.title()
        icon.image = model.icon()?.withRenderingMode(.alwaysTemplate)
        bigTitle.text = model.title()
    }
    
}
