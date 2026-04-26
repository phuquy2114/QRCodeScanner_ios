//
//  RootView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

enum AppState {
    case splash
    case main
}

struct RootView: View {

    @State private var appState: AppState = .splash

    var body: some View {
        ZStack {
            switch appState {
            case .splash:
                SplashView().transition(.opacity).onAppear {
                    startAppLoading()
                }
            case .main:
                ContentView().transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState)
    }

    private func startAppLoading() {
        Task { @MainActor in
            try await Task.sleep(for: .seconds(1))
            withAnimation(.easeInOut(duration: 0.5)) {
                appState = .main
            }
        }
    }
}
