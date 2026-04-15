//
//  TabContent.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

struct TabContent: View {
    let selectedTab: AppTab

    var body: some View {
        switch selectedTab {
        case .scan: ScanView()
        case .history: PlaceholderView(title: "History")
        case .create: CreateQRView()
        case .favorite: PlaceholderView(title: "Favorite")
        case .settings: SettingsView()
        }
    }
}

struct PlaceholderView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black
            Text(title)
                .foregroundStyle(.white)
                .font(.title2)
        }
    }
}
