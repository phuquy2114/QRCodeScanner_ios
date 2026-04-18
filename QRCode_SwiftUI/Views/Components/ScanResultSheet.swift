//
//  ScanResultSheet.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI

// MARK: - Scan Result Sheet
struct ScanResultSheet: View {
    @EnvironmentObject var theme: ThemeManager
    let result: String
    let onDismiss: () -> Void

    private var isURL: Bool {
        result.lowercased().hasPrefix("http://")
            || result.lowercased().hasPrefix("https://")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 56))
                    .foregroundStyle(theme.accent)
                    .padding(.top, 32)

                VStack(spacing: 8) {
                    Text("Scanned successfully")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(result)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .textSelection(.enabled)
                }

                HStack(spacing: 16) {
                    ActionButton(title: "Copy", icon: "doc.on.doc") {
                        UIPasteboard.general.string = result
                    }
                    if isURL, let url = URL(string: result) {
                        ActionButton(title: "Open", icon: "safari") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.accent)
                .foregroundStyle(.black)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}
