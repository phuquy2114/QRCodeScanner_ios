//
//  CreateQRBasicViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import Combine
import SwiftUI
import CoreData

class CreateQRBasicViewModel: BaseViewModel {
    let maxLength = 500
    @Published var content: String = ""
    @Published var generatedImage: UIImage? = nil
    
    func generateQR() {
        guard !content.isEmpty else { return }
        // Người dùng đã dặn không cần chèn prefix, dùng trực tiếp nội dung họ nhập
        if let rawImage = QRCodeGenerator.shared.generateQRCode(from: content) {
            // Xoá kênh Alpha để tránh lỗi "ignoring alpha" và tối ưu dung lượng ảnh
            generatedImage = rawImage.removingAlphaChannel()
        }
    }
    
    func saveQRToDatabase(type: CreateQREnums) -> Bool {
        guard let image = generatedImage else { return false }
        
        // 1. Lưu ảnh qua FileManager
        guard let fileName = LocalImageService.shared.saveImage(image: image) else { return false }
        
        // 2. Lưu thông tin qua CoreData
        let context = CoreDataManager.shared.context
        let newHistory = QRCodeEntity(context: context)
        newHistory.id = UUID()
        newHistory.qrType = type.rawValue
        newHistory.rawContent = content // Lưu nguyên bản
        newHistory.imageFileName = fileName
        newHistory.isFavorite = false
        newHistory.createdAt = Date()
        
        CoreDataManager.shared.saveContext()
        return true
    }

}
