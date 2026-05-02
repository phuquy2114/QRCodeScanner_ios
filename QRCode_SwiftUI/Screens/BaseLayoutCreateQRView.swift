//
//  BaseLayoutCreateQRView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 30/4/26.
//

import SwiftUI

struct BaseLayoutCreateQRView<Content: View, ViewModel: BaseCreateQRViewModel>: View {
    let item: CreateQREnums
    @ObservedObject var viewModel: ViewModel
    @ViewBuilder var content: () -> Content
    @State private var showShareSheet: Bool = false
    @State private var showSaveAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer().frame(height: 16)
                
                // 1. PHẦN GIAO DIỆN RIÊNG CỦA TỪNG MÀN HÌNH CON
                content()
                
                Spacer().frame(height: 36)

                // 2. PHẦN GIAO DIỆN CHUNG (NÚT TẠO QR)
                ButtonTheme(title: "CREATE") {
                    // Gọi thẳng hàm handleCreateQR từ ViewModel gốc
                    // ViewModel con sẽ tự lo việc Validation bên trong hàm này
                    viewModel.handleCreateQR()
                }
                
                // 3. KẾT QUẢ QR CẦN HIỂN THỊ
                if viewModel.qrCodeSuccessGen, let image = viewModel.generatedImage {
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
                            // Gọi thẳng hàm Save từ ViewModel
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
        .sheet(isPresented: $showShareSheet) {
            if let imageToShare = viewModel.generatedImage {
                ShareSheet(items: [imageToShare])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Success", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("QR Code has been saved to your history.")
        }
        // THÊM ALERT THÔNG BÁO LỖI VALIDATION Ở ĐÂY
//        .alert("Invalid Input", isPresented: $viewModel.showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(viewModel.errorMessage)
//        }
        // Error sheet
        .withErrorSheet(
            isPresented: $viewModel.showError,
            error: viewModel.currentError,
            onDismiss: viewModel.dismissError
        )
    }
}
