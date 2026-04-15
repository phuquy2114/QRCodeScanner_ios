//
//  ScanViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI
import PhotosUI
import Vision
import AVFoundation
import Combine

final class ScanViewModel: BaseViewModel {

    // MARK: - Published
    @Published var isFlashOn = false
    @Published var zoom: Double = 1.0 {
        didSet { cameraService.setZoom(CGFloat(zoom)) }
    }

    @Published var scannedResult: String?
    @Published var showResult = false

    @Published var showPhotosPicker = false
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            guard selectedPhotoItem != nil else { return }
            Task { await run { try await self.scanFromPickedPhoto() } }
        }
    }

    // MARK: - Camera
    let cameraService = CameraService()

    // MARK: - Init
    override init() {
        super.init()
        cameraService.onQRCodeDetected = { [weak self] result in
            switch result {
            case .success(let value): self?.handleDetected(value)
            case .failure(let error): self?.presentError(error)
            }
        }
    }

    // MARK: - Lifecycle

    override func onAppear() {
        Task { await requestPermissionAndStart() }
    }

    override func onDisappear() {
        cameraService.stop()
        if isFlashOn {
            cameraService.setFlash(false)
            isFlashOn = false
        }
    }

    // MARK: - Permission

    private func requestPermissionAndStart() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCamera()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            granted ? startCamera() : presentError(.permissionDenied)
        default:
            presentError(.permissionDenied)
        }
    }

    private func startCamera() {
        cameraService.configure { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:          self?.cameraService.start()
                case .failure(let err): self?.presentError(err)
                }
            }
        }
    }

    // MARK: - Flash

    func toggleFlash() {
        isFlashOn.toggle()
        cameraService.setFlash(isFlashOn)
    }

    // MARK: - Flip

    func flipCamera() {
        if cameraService.currentPosition == .back, isFlashOn {
            isFlashOn = false
            cameraService.setFlash(false)
        }
        cameraService.flipCamera()
    }

    // MARK: - Photo Library

    func openPhotoLibrary() {
        showPhotosPicker = true
    }

    private func scanFromPickedPhoto() async throws {
        // 1. Load data
        guard
            let item = selectedPhotoItem,
            let data = try? await item.loadTransferable(type: Data.self)
        else { throw AppError.photoLoadFailed }

        // 2. Decode image
        guard let cgImage = UIImage(data: data)?.cgImage
        else { throw AppError.photoLoadFailed }

        // 3. Vision request
        let request = VNDetectBarcodesRequest()
        do {
            try VNImageRequestHandler(cgImage: cgImage).perform([request])
        } catch {
            throw AppError.photoScanFailed
        }

        // 4. Validate result
        guard let first = request.results?.first as? VNBarcodeObservation
        else { throw AppError.noQRCodeFound }

        guard let payload = first.payloadStringValue, !payload.isEmpty
        else { throw AppError.invalidQRPayload }

        handleDetected(payload)
    }

    // MARK: - Result

    private func handleDetected(_ value: String) {
        guard scannedResult == nil else { return }
        scannedResult = value
        showResult = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        cameraService.stop()
    }

    func dismissResult() {
        scannedResult = nil
        showResult = false
        selectedPhotoItem = nil
        cameraService.start()
    }

    // MARK: - Error override

    override func dismissError() {
        // permissionDenied → không resume camera
        if currentError != .permissionDenied {
            cameraService.start()
        }
        selectedPhotoItem = nil
        super.dismissError()
    }
}


