//
//  CreateQRWebsiteView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 1/5/26.
//

import SwiftUI

struct CreateQRWebsiteView: View {
    let item: CreateQREnums
    @StateObject private var viewModel = CreateQRWebsiteViewModel()
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {
            TextImageTextField(
                text: $viewModel.url,
                placeholder: "https://",
                annotation: "URL Link"
            )

            Spacer().frame(height: 20)

            HStack(spacing: 12) {
                buildButton(title: viewModel.www)

                buildButton(title: viewModel.com)

                Spacer()
            }
            .padding(.leading, 1)
        }
    }

    private func buildButton(title: String) -> some View {
        Button {
            viewModel.onTapButton(value: title)
        } label: {
            Text(title)
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(theme.accent)
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.25))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.gray, lineWidth: 1)
                        }
                )
        }

    }

}
