//
//  AppErrorSheet.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//
import SwiftUI
import UIKit

// MARK: - AppErrorSheet
struct AppErrorSheet: View {
    let error: AppError
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer().frame(height: 8)

                Image(systemName: error.icon)
                    .font(.system(size: 52))
                    .foregroundStyle(.red)

                VStack(spacing: 8) {
                    Text(error.errorDescription)
                        .font(.title2)
                        .multilineTextAlignment(.center)

                    Text(error.suggestion)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    if error.canOpenSettings {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                                .appButtonStyle(color: .white, foreground: .black)
                        }
                    }

                    Button(action: onDismiss) {
                        Text("Try Again")
                            .appButtonStyle(color: Color.secondary.opacity(0.25), foreground: .primary)
                            
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: onDismiss)
                        .font(.title3)
                        
                }
            }
        }
        .presentationDetents([.medium])
    }
}
