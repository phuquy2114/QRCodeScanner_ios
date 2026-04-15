//
//  ContentView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 4/4/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .scan
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabContent(selectedTab: selectedTab)
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .background(Color.backgroundColor)
    }
}

#Preview {
    ContentView()
}
