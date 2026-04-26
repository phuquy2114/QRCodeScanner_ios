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
        case .history: NavigationStack { HistoryView(isFavoriteOnly: false) }
        case .create: CreateQRView()
        case .favorite: NavigationStack { HistoryView(isFavoriteOnly: true) }
        case .settings: SettingsView()
        }
    }
}

