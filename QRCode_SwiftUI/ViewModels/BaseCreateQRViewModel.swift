//
//  BaseCreateQRViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import Combine
import CoreData
import UIKit

@MainActor
class BaseCreateQRViewModel: BaseViewModel, BaseCreateQRProtocol {

    let maxLength = 500
    @Published var generatedImage: UIImage? = nil
    @Published var qrCodeSuccessGen: Bool = false

    // Thuộc tính để lớp con ghi đè, cung cấp nội dung lưu vào Database
    var qrRawContent: String {
        return ""
    }

    func generateQR(data: String) {
        if let rawImage = QRCodeGenerator.shared.generateQRCode(from: data) {
            self.generatedImage = rawImage.removingAlphaChannel()
            qrCodeSuccessGen = generatedImage != nil
        }
    }

    func handleCreateQR() {
        // Hàm này không yêu cầu trả về (Void) nên có thể để trống,
        // hoặc dùng fatalError("Cần override")
    }

    func saveQRToDatabase(type: CreateQREnums) -> Bool {
        guard let image = generatedImage else { return false }

        // 1. Lưu ảnh qua FileManager
        guard let fileName = LocalImageService.shared.saveImage(image: image)
        else { return false }

        // 2. Lưu thông tin qua CoreData
        let context = CoreDataManager.shared.context
        let newHistory = QRCodeEntity(context: context)
        newHistory.id = UUID()
        newHistory.qrType = type.rawValue

        newHistory.rawContent = qrRawContent
        newHistory.imageFileName = fileName
        newHistory.isFavorite = false
        newHistory.createdAt = Date()

        CoreDataManager.shared.saveContext()
        return true
    }

}

protocol BaseCreateQRProtocol {
    var qrRawContent: String { get }
    func generateQR(data: String)
    func handleCreateQR()
    func saveQRToDatabase(type: CreateQREnums) -> Bool
}
