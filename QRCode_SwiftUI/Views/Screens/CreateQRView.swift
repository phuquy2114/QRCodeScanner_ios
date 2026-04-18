//
//  CreateQRView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 11/4/26.
//

import SwiftUI

struct CreateQRView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var onShowHistory = false
    @State private var onShowClipboard = false

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 12)
                buildSection(
                    title: "History",
                    icon: "clock.arrow.circlepath",
                    showScreen: $onShowHistory
                )
                Spacer().frame(height: 12)
                buildSection(
                    title: "Clipboard",
                    icon: "clipboard.fill",
                    showScreen: $onShowClipboard
                )
                Spacer().frame(height: 16)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CreateQR.allCases, id: \.self) { item in
                            CreateItemCell(onTap: { object in
                                handleOnTap(item: object)
                            }, item: item)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal, 16)

            }
            .scrollContentBackground(.hidden)
            .marginBottom()
            .background(Color.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(isPresented: $onShowHistory) {
                PlaceholderView(title: "History")
            }
            .navigationDestination(isPresented: $onShowClipboard) {
                PlaceholderView(title: "clip")
            }
        }

    }

    private func buildSection(
        title: String,
        icon: String,
        showScreen: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: 24, height: 24)
                .foregroundStyle(theme.accent)
                .scaledToFill()
            
            Text(title)
                .foregroundStyle(.white)
                .font(.title3)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .frame(width: 18, height: 18)
                .foregroundStyle(.white)
                .scaledToFill()
        }
        .padding(16)
        .background(Color.backgroundColor)
        .clipShape(.rect(cornerRadius: 8))
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            showScreen.wrappedValue = true
        }
    }
    
    private func handleOnTap(item: CreateQR) {
        print(item.title())
    }
}

struct CreateItemCell: View {
    @EnvironmentObject var theme: ThemeManager
    var onTap: (CreateQR) -> Void
    let item: CreateQR

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                ZStack(alignment: .center) {
                    if let icon = item.icon() {
                        icon.resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundStyle(theme.accent)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color.clear)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .fill(theme.accent)
                        }
                )
                Text(item.title())
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4).fill(theme.accent)
                    )
                    .frame(maxWidth: 56)
                    .alignmentGuide(.top) { dimen in
                        dimen[VerticalAlignment.center]
                    }
            }

            Text(item.title())
                .foregroundStyle(.white)
                .lineLimit(1)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .padding(.bottom, 8)
        .padding(.top, 16)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundColor)
        )
        .onTapGesture {
            onTap(item)
        }
    }
}
