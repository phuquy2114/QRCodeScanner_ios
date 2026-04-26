//
//  SettingsView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showFAQ = false
    @State private var showFeedback = false
    @State private var showShare = false

    @AppStorage("isOpenRateUs") private var isOpenRateUs: Bool = false

    private let spacingSection: CGFloat = 1

    var body: some View {
        NavigationStack {
            List {
                themeSection
                soundSection
                helpSection
                versionSection
            }
            .listStyle(.plain)
            .listRowSpacing(16)
            .padding(.horizontal, 16)
            .marginBottom()
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .scrollIndicators(.hidden)
            .navigationDestination(isPresented: $showFAQ) {
                FAQView()
            }
            .navigationDestination(isPresented: $showFeedback) {
                FeedbackView()
            }
            .sheet(isPresented: $showShare) {
                if let url = URL(string: viewModel.appLink) {
                    ShareSheet(items: [url]).presentationDetents([
                        .medium, .large,
                    ])
                }
            }
        }
    }

    // MARK: - Theme Section
    private var themeSection: some View {
        VStack(alignment: .leading) {
            titleSection(title: "Theme")
            ForEach(ThemeColor.allCases, id: \.self) { option in
                Spacer().frame(height: 16)
                ThemeRow(
                    option: option,
                    onTap: { theme.setNewTheme(option) },
                    isSelected: option == theme.current
                )
            }
        }
        .configRow()
    }

    private var soundSection: some View {
        VStack(alignment: .leading) {
            titleSection(title: "Sound")
            SoundRow { value, settingSound in
                viewModel.onChangeToggle(item: settingSound, value: value)
            }
        }.configRow()
    }

    private var helpSection: some View {
        VStack(alignment: .leading) {
            Text("Help")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(theme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(SettingHelp.allCases, id: \.self) { item in
                buildDivider()
                HelpRow(
                    settingHelp: item,
                    isOpenRateUS: $isOpenRateUs, onTap: {
                        switch item {
                        case .faq:
                            showFAQ = true
                        case .feedback:
                            showFeedback = true
                        case .rateUs:
                            isOpenRateUs = true
                            openLinkURL(link: viewModel.appLink)
                        case .share:
                            showShare = true
                        case .privacyPolicy, .termsOfUse:
                            openLinkURL(link: viewModel.appPrivacyPolicy)
                        }
                    }
                )
            }
        }
        .configRow()
    }

    private var versionSection: some View {
        titleSection(title: viewModel.appVersion)
            .frame(maxWidth: .infinity, alignment: .leading)
            .configRow()
    }

    private func titleSection(title: String) -> some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
    }

    private func openLinkURL(link: String) {
        if let url = URL(string: link) {
            openURL(url)
        }
    }

}

// MARK: - Theme Row
struct ThemeRow: View {
    let option: ThemeColor
    let onTap: () -> Void
    var isSelected: Bool

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Color swatch
                Circle()
                    .stroke(option.color(), lineWidth: 2)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .fill(option.color())
                            .frame(width: 18, height: 18)
                            .opacity(isSelected ? 1 : 0)
                    )

                Text(option.displayName)
                    .foregroundStyle(.white)
                    .font(.headline)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct SoundRow: View {
    @EnvironmentObject var theme: ThemeManager
    var onChange: (Bool, SettingSound) -> Void

    @AppStorage(SettingSound.vibrate.rawValue) private var vibrate = true
    @AppStorage(SettingSound.beep.rawValue) private var beep = true
    @AppStorage(SettingSound.autoFocus.rawValue) private var autoFocus = true
    @AppStorage(SettingSound.touchFocus.rawValue) private var touchFocus = true

    var body: some View {
        VStack(spacing: 14) {

            buildToggle(item: .vibrate, isOnValue: $vibrate)

            buildDivider()
            buildToggle(item: .beep, isOnValue: $beep)

            buildDivider()
            buildToggle(item: .autoFocus, isOnValue: $autoFocus)

            buildDivider()
            buildToggle(item: .touchFocus, isOnValue: $touchFocus)

        }
    }
    


    private func buildToggle(item: SettingSound, isOnValue: Binding<Bool>)
        -> some View
    {
        Toggle(item.displayName, isOn: isOnValue)
            .foregroundStyle(.white)
            .font(.system(size: 18))
            .tint(theme.accent)
            .contentShape(Rectangle())
            .onChange(of: isOnValue.wrappedValue) { newValue in
                onChange(newValue, item)
            }
    }
}

struct HelpRow: View {
    let settingHelp: SettingHelp
    @Binding var isOpenRateUS: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if settingHelp == .rateUs {
                Text(isOpenRateUS ? "Rate (opened)" : settingHelp.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            } else {
                Text(settingHelp.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }

            if let description = settingHelp.description {
                Spacer().frame(height: 4)
                Text(description)
                    .font(.headline)
                    .foregroundStyle(Color.white.opacity(0.8))
            }
        }.onTapGesture {
            self.onTap()
        }
    }
}

fileprivate extension View {
     func configRow() -> some View {
        self.padding(16)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(
                EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            )
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color.backgroundColor)
            )
    }
    
    func buildDivider() -> some View {
        Divider().background(Color.white.opacity(0.8))
    }
    
}
