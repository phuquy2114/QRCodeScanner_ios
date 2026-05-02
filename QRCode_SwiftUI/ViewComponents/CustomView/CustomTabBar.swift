//
//  CustomTabBar.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

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
