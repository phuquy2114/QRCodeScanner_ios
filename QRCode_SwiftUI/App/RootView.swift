//
//  RootView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

// Định nghĩa các trạng thái của App
enum AppState {
    case splash
    case main
    // Sau này có thể thêm: case login, case onboarding...
}

struct RootView: View {

    @State var appState: AppState = .splash

    var body: some View {
        Group {
            switch appState {
            case .splash:
                SplashView().onAppear {
                    startAppLoading()
                }
            case .main:
                ContentView().transition(.opacity)
            }
        }
    }

    private func startAppLoading() {
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 100_000_000)
            withAnimation(.easeInOut(duration: 0.5)) {
                appState = .main
            }
        }
    }
}
