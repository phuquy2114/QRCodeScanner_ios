//
//  QRCodeApp.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 4/4/26.
//
import SwiftUI

@main
struct QRCodeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .withTheme() // inject ThemeManager vào toàn bộ cây view
        }
    }
}
