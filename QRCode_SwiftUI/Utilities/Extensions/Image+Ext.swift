//
//  Image+Ext.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import UIKit

extension UIImage {
    
    // Thêm extension để tự vẽ một ảnh hình tròn vừa khít
    static func circleImage(diameter: CGFloat, color: UIColor) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Loại bỏ hoàn toàn kênh Alpha (độ trong suốt) của ảnh.
    /// Ép ảnh qua định dạng JPEG để xoá bộ nhớ AlphaLast, giúp tối ưu RAM và tránh lỗi khi Share/Lưu file.
    func removingAlphaChannel() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = self.scale
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        let flattenedImage = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: self.size))
            self.draw(at: .zero)
        }
        
        if let jpegData = flattenedImage.jpegData(compressionQuality: 1.0),
           let finalOpaqueImage = UIImage(data: jpegData) {
            return finalOpaqueImage
        }
        
        return flattenedImage
    }
}
