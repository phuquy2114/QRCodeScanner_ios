//
//  ScanErrorSheet.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

// MARK: - Scan Error Sheet
struct ScanErrorSheet: View {
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
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    Text(error.suggestion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    // Mở Settings nếu là lỗi permission
                    if error.canOpenSettings {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Open Settings", systemImage: "gear")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.yellow)
                                .foregroundStyle(.black)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }

                    Button(role: .cancel, action: onDismiss) {
                        Text("Try Again")
                            .font(.system(size: 15, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.secondary.opacity(0.15))
                            .foregroundStyle(.primary)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: onDismiss)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
