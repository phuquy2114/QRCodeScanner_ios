import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class QRCodeGenerator {
    static let shared = QRCodeGenerator()
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private init() {}
    
    /// Sinh mã QR từ một chuỗi văn bản
    func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter.outputImage {
            // Scale ảnh lên để không bị mờ (do ảnh mặc định của CoreImage rất nhỏ)
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledCIImage = outputImage.transformed(by: transform)
            
            if let cgimg = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return nil
    }
}
