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
        case .history: getHistoryView(isFavorite: false)
        case .create: CreateQRView()
        case .favorite: getHistoryView(isFavorite: true)
        case .settings: SettingsView()
        }
    }

    private func getHistoryView(isFavorite: Bool) -> some View {
        NavigationStack { HistoryView(isFavoriteOnly: isFavorite) }
    }
}
