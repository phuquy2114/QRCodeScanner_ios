//
//  UploadItem.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

import SwiftUI

// MARK: - Upload Item
struct UploadItem {
    let data: Data
    let name: String       // form field name
    let fileName: String   // tên file server nhận
    let mimeType: String

    static func image(_ data: Data, name: String = "file", fileName: String = "image.jpg") -> UploadItem {
        UploadItem(data: data, name: name, fileName: fileName, mimeType: "image/jpeg")
    }

    static func file(_ data: Data, name: String, fileName: String, mimeType: String) -> UploadItem {
        UploadItem(data: data, name: name, fileName: fileName, mimeType: mimeType)
    }
}
