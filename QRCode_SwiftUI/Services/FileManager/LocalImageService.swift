import Foundation
import UIKit

class LocalImageService {
    static let shared = LocalImageService()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// Lưu ảnh vào Document Directory, trả về tên file nếu thành công
    func saveImage(image: UIImage, fileName: String = UUID().uuidString + ".png") -> String? {
        guard let data = image.pngData() else { return nil }
        
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return fileName
        } catch {
            print("Lỗi khi lưu ảnh: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Đọc ảnh từ Document Directory dựa vào tên file
    func loadImage(fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            print("Lỗi khi đọc ảnh: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Xoá ảnh khỏi Document Directory
    func deleteImage(fileName: String) {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Lỗi khi xoá ảnh: \(error.localizedDescription)")
            }
        }
    }
}
