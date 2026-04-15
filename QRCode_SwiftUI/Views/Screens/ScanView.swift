//
//  ScanView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import PhotosUI
import SwiftUI

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()

    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth * 0.8
        let height = width * 0.9

        ZStack {
            // Màn hình tối khi bị từ chối quyền
            CameraPreviewView(session: viewModel.cameraService.session)

            // Màn hình tối khi bị từ chối quyền
            if viewModel.currentError == .permissionDenied {
                PermissionDeniedOverlay()
            }

            VStack {
                // Status bar spacer
                Spacer().frame(height: 30)
                
                // Top toolbar
                CameraToolbar(
                    isFlashOn: $viewModel.isFlashOn,
                    onPhotoLibrary: { viewModel.openPhotoLibrary() },
                    onFlipCamera: { viewModel.flipCamera() },
                    onFlashToggle: { viewModel.toggleFlash() }
                )
                .padding(.horizontal, 16)

                Spacer()

                // Viewfinder - Đã thêm lại tham số scanLineOffset như code gốc
                ScannerFrame().frame(width: width, height: height)

                Spacer()

                // Zoom slider
                ZoomSlider(zoom: $viewModel.zoom).padding(.horizontal, 30)

                // Tab bar spacer
                Spacer().frame(height: 120)

            }

        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        // Photo picker
        .photosPicker(
            isPresented: $viewModel.showPhotosPicker,
            selection: $viewModel.selectedPhotoItem,
            matching: .images
        )
        // Kết quả quét
        .sheet(isPresented: $viewModel.showResult) {
            if let result = viewModel.scannedResult {
                ScanResultSheet(
                    result: result,
                    onDismiss: {
                        viewModel.dismissResult()
                    }
                )
            }
        }
        // Loading khi đang xử lý ảnh
        .withLoadingOverlay(isLoading: viewModel.isLoading, message: "Scanning image...")
        // Error sheet
        .withErrorSheet(
            isPresented: $viewModel.showError,
            error: viewModel.currentError,
            onDismiss: viewModel.dismissError
        )
    }

}
