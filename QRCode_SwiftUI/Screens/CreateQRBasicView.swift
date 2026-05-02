//
//  CreateQRBasicView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 19/4/26.
//

import SwiftUI
/*
struct CreateQRBasicView: View {
    let item: CreateQREnums
    var initialContent: String = ""
    @StateObject private var viewModel = CreateQRBasicViewModel()
    @State var qrCodeSuccessGen: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showEmptyValidationAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 16)

                TextThemeTextEditor(
                    placeholder: "URL or content",
                    maxLength: viewModel.maxLength,
                    text: $viewModel.content
                ).frame(minHeight: 160)

                Spacer().frame(height: 36)

                ButtonTheme(title: "CREATE") {
                    if viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showEmptyValidationAlert = true
                    } else {
                        viewModel.generateQR()
                        if viewModel.generatedImage != nil {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation {
                                qrCodeSuccessGen = true
                            }
                        }
                    }
                }
                
                if qrCodeSuccessGen, let image = viewModel.generatedImage {
                    Spacer().frame(height: 36)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                        
                        Image(uiImage: image)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(20)
                    }
                    .frame(width: 240, height: 240)
                    
                    Spacer().frame(height: 24)
                    
                    HStack(spacing: 12) {
                        ButtonTheme(title: "SAVE IMAGE", radius: 8) {
                            let success = viewModel.saveQRToDatabase(type: item)
                            if success {
                                showSaveAlert = true
                            }
                        }
                        
                        ButtonTheme(title: "SHARE IMAGE", radius: 8) {
                            showShareSheet = true
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
        .scrollIndicators(.hidden)
        .marginBottom()
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.title())
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .alert("Success", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("QR Code has been saved to History!")
        }
        .alert("Validation Error", isPresented: $showEmptyValidationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter some text or URL to generate a QR Code.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let imageToShare = viewModel.generatedImage {
                ShareSheet(items: [imageToShare])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            if !initialContent.isEmpty && viewModel.content.isEmpty {
                viewModel.content = initialContent
            }
        }
    }
}
*/

struct CreateQRBasicView: View {
    let item: CreateQREnums
    var initialContent: String = ""
    @StateObject private var viewModel = CreateQRBasicViewModel()
    
    var body: some View {
        BaseLayoutCreateQRView(item: item, viewModel: viewModel) {
            TextThemeTextEditor(
                placeholder: "URL or content",
                maxLength: viewModel.maxLength,
                annotation: "URL or content",
                text: $viewModel.content
            ).frame(minHeight: 160)
        }
        .onAppear {
            if !initialContent.isEmpty && viewModel.content.isEmpty {
                viewModel.content = initialContent
            }
        }
    }
}
