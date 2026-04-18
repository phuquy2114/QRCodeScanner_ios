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
        case .history: PlaceholderView(title: selectedTab.title)
        case .create: CreateQRView()
        case .favorite: PlaceholderView(title: selectedTab.title)
        case .settings: SettingsView()
        }
    }
}

