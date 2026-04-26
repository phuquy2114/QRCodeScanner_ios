//
//  ShareSheet.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import SwiftUI
import LinkPresentation

class ImageActivityItemSource: NSObject, UIActivityItemSource {
    let image: UIImage
    let title: String
    
    init(image: UIImage, title: String = "QR Code") {
        self.image = image
        self.title = title
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    // Hàm này giúp lấy được ảnh QR ra để làm Icon Preview thay cho icon mặc định của Apple
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.imageProvider = NSItemProvider(object: image)
        return metadata
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Tự động map các ảnh sang ImageActivityItemSource để hỗ trợ Preview Icon
        let activityItems = items.map { item -> Any in
            if let image = item as? UIImage {
                return ImageActivityItemSource(image: image)
            }
            return item
        }
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
