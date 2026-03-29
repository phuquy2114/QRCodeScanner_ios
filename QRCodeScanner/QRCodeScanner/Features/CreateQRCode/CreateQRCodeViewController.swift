//
//  CreateQRCodeViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import Combine
import UIKit

class CreateQRCodeViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clipboardStack: UIStackView!
    @IBOutlet weak var historyStack: UIStackView!
    @IBOutlet weak var historyIcon: UIImageView!
    @IBOutlet weak var clipboardIcon: UIImageView!
    
    private let dataArrays: [CreateQR] = CreateQR.allCases
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func setupActions() {
        historyStack.isUserInteractionEnabled = true
        clipboardStack.isUserInteractionEnabled = true
        
        let tapHistory = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapHistory)
        )
        historyStack.addGestureRecognizer(tapHistory)
        
        let tapClipboard = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapClipboard)
        )
        clipboardStack.addGestureRecognizer(tapClipboard)
        
    }
    
    override func setupUI() {
        view.backgroundColor = .black
        let identifier = CreateQRCodeCollectionViewCell.identifier
        
        collectionView.register(CreateQRCodeCollectionViewCell.nib, forCellWithReuseIdentifier: identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        self.historyIcon.tintColor = ThemeManager.shared.themeColor
        self.clipboardIcon.tintColor = ThemeManager.shared.themeColor
    }

    override func applyNewTheme(color: UIColor) {
        self.historyIcon.tintColor = color
        self.clipboardIcon.tintColor = color
    }
    
    @objc private func onTapHistory() {
        print("onTapHis")
    }
    
    @objc private func onTapClipboard() {
        print("onTapClipboard")
    }
    

}

extension CreateQRCodeViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        print("\(indexPath.row)")
    }
}

extension CreateQRCodeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArrays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: CreateQRCodeCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CreateQRCodeCollectionViewCell.identifier,
            for: indexPath
        ) as? CreateQRCodeCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: dataArrays[indexPath.row])
        
        return cell
    }
}

// Thêm extension UICollectionViewDelegateFlowLayout để chia đều layout
extension CreateQRCodeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 8
        let itemsPerRow: CGFloat = 3
        
        // Tổng khoảng cách giữa các item trên cùng 1 hàng
        let totalSpacing = spacing * (itemsPerRow - 1)
        
        // Chiều rộng khả dụng sau khi đã trừ đi khoảng cách
        let availableWidth = collectionView.bounds.width - totalSpacing
        
        // Chiều rộng của mỗi item (dùng floor để làm tròn xuống, tránh lỗi rớt hàng do sai số thập phân)
        let itemWidth = floor(availableWidth / itemsPerRow)
        
        // Trả về kích thước. Mình để height = itemWidth để ra hình vuông, bạn có thể chỉnh sửa tuỳ ý
        return CGSize(width: itemWidth, height: itemWidth + 10)
    }
    
    // Khoảng cách giữa các item trên cùng 1 hàng (cột)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // Khoảng cách giữa các hàng với nhau
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

