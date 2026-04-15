//
//  BottomNavigationBar.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case scan, history, create, favorite, settings

    var title: String {
        return self.rawValue.capitalized
    }

    var icon: Image? {
        switch self {
        case .scan:
            return getImageSystem("qrcode.viewfinder")
        case .history:
            return getImageSystem("clock.arrow.circlepath")
        case .create:
            return getImageSystem("qrcode")
        case .favorite:
            return getImageSystem("heart.fill")
        case .settings:
            return getImageSystem("gearshape.fill")
        }
    }
    
    private func getImageSystem(_ name: String) -> Image? {
        return Image(systemName: name)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabItem(
                    title: tab.title,
                    icon: tab.icon,
                    isSelected: selectedTab == tab,
                    action: { selectedTab = tab }
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(white: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(theme.accent, lineWidth: 1.5)
                )
        )
    }
}
