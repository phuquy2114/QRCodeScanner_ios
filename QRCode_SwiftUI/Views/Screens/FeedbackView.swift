//
//  ProblemsView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 8/4/26.
//

import SwiftUI

struct FeedbackView: View {

    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = FeedbackViewModel()

    @State private var text: String = "Describe your prolbem..."
        
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: 10)
            Text("What problems did you encounter?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Spacer().frame(height: 20)
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.problemItems.indices,  id: \.self) { index in
                    Button {
                        viewModel.onTapItemProblem(index: index)
                    } label: {
                        Text(viewModel.problemItems[index].0.uppercased())
                            .font(.headline)
                    }
                    .padding(12)
                    .foregroundStyle(
                        // Xoá dấu $ ở đây đi vì chúng ta chỉ đọc (Read) chứ không truyền tham chiếu
                        viewModel.problemItems[index].1 ? .blue : .white
                    )
                    .clipShape(.rect(cornerRadius:16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(viewModel.problemItems[index].1 ? .blue : .white, lineWidth: 1)
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.leading, 2)
            
            Spacer().frame(height: 20)
            TextInputTextEditor(
                placeholder: "Describe your problem...",
                maxLength: viewModel.maxDescriptionLength,
                text: $viewModel.description
            )
            Spacer().frame(height: 20)
            Text("Attach images (maximum \(self.viewModel.maxImages) images)")
                .font(.body)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            
            Spacer().frame(height: 8)
            ImageSection(
                listImage: $viewModel.attachFiles,
                maxImages: viewModel.maxImages
            )
            Spacer().frame(height: 30)
            ButtonTheme(title: "SUBMIT") {
                viewModel.submitFeedback()
            }
            .disabled(!viewModel.isFormValid)
        }
        .padding(.horizontal, 12)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .marginBottom()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Feedback")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}
