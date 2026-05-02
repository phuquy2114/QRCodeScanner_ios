//
//  CreateQRBasicViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import Combine
import CoreData
import SwiftUI

@MainActor
class CreateQRBasicViewModel: BaseCreateQRViewModel {
    @Published var content: String = ""

    override func handleCreateQR() {
        guard
            validate([
                .nonEmpty(content, fieldName: "Content")
            ])
        else { return }

        generateQR(data: content)
    }

    override var qrRawContent: String {
        return content
    }
}
