//
//  AppRouter.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

enum CreateQRRouter: Hashable {
    case history
    case clipboard(text: String)
    case createDetail(item: CreateQREnums)
}
