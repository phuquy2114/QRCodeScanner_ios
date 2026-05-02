//
//  ScanViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import Combine
import Vision
import _PhotosUI_SwiftUI

@MainActor
final class ScanViewModel: BaseViewModel {

    // MARK: - Published
    @Published var isFlashOn = false
    @Published var zoom: Double = 1.0
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
    private var detectionTask: Task<Void, Never>?

    // MARK: - Lifecycle
    override func onAppear() {
        Task { await requestPermissionAndStart() }
    }

    override func onDisappear() {
        stopDetection()
        Task {
            if isFlashOn { try? await cameraService.setFlash(false) }
            await cameraService.stop()
        }
        isFlashOn = false
    }

    // MARK: - Permission
    private func requestPermissionAndStart() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            await startCamera()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                await startCamera()
            } else {
                presentError(.permissionDenied)
            }
        default:
            presentError(.permissionDenied)
        }
    }

    private func startCamera() async {
        do {
            try await cameraService.configure()
            await cameraService.start()
            startDetection()
        } catch let error as AppError {
            presentError(error)
        } catch {
            presentError(.cameraUnavailable)
        }
    }

    // MARK: - Detection
    private func startDetection() {
        stopDetection()
        detectionTask = Task { [weak self] in
            guard let self else { return }
            for await result in cameraService.detectionStream {
                guard !Task.isCancelled else { return }
                switch result {
                case .success(let value): handleDetected(value)
                case .failure(let error): presentError(error)
                }
            }
        }
    }

    private func stopDetection() {
        detectionTask?.cancel()
        detectionTask = nil
    }

    // MARK: - Flash
    func toggleFlash() {
        isFlashOn.toggle()
        let on = isFlashOn
        Task {
            do {
                try await cameraService.setFlash(on)
            } catch {
                isFlashOn = !on
            }
        }
    }

    // MARK: - Zoom
    func applyZoom() {
        let factor = CGFloat(zoom)
        Task { try? await cameraService.setZoom(factor) }
    }

    // MARK: - Flip
    func flipCamera() {
        Task {
            let pos = await cameraService.position
            if pos == .back, isFlashOn {
                isFlashOn = false
                try? await cameraService.setFlash(false)
            }
            do {
                try await cameraService.flip()
            } catch {
                presentError(.cameraUnavailable)
            }
        }
    }

    // MARK: - Photo Library
    func openPhotoLibrary() {
        showPhotosPicker = true
    }

    private func scanFromPickedPhoto() async throws {

        guard
            let item = selectedPhotoItem,
            let data = try? await item.loadTransferable(type: Data.self),
            let cgImage = UIImage(data: data)?.cgImage
        else {
            throw AppError.photoLoadFailed
        }

        /*
        // Vision synchronous + CPU heavy → global queue tránh block
        let payload: String = try await withCheckedThrowingContinuation {
            continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNDetectBarcodesRequest()
                do {
                    try VNImageRequestHandler(cgImage: cgImage, options: [:])
                        .perform([request])
                } catch {
                    continuation.resume(throwing: AppError.photoScanFailed)
                    return
                }
                guard
                    let obs = request.results?.first as? VNBarcodeObservation,
                    let value = obs.payloadStringValue,
                    !value.isEmpty
                else {
                    continuation.resume(throwing: AppError.noQRCodeFound)
                    return
                }
                continuation.resume(returning: value)
            }
        }
        handleDetected(payload)
        */

        let value: String = try await Task.detached(priority: .userInitiated) {
            let request = VNDetectBarcodesRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                throw AppError.photoScanFailed
            }

            guard
                let obs = request.results?.first as? VNBarcodeObservation,
                let payload = obs.payloadStringValue,
                !payload.isEmpty
            else {
                throw AppError.noQRCodeFound
            }

            return payload
        }.value

        handleDetected(value)
    }

    // MARK: - Result
    private func handleDetected(_ value: String) {
        guard scannedResult == nil else { return }
        scannedResult = value
        showResult = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        stopDetection()
        Task { await cameraService.stop() }
    }

    func dismissResult() {
        scannedResult = nil
        showResult = false
        selectedPhotoItem = nil
        Task {
            await cameraService.start()
            startDetection()
        }
    }

    // MARK: - Error override
    override func dismissError() {
        selectedPhotoItem = nil
        if currentError != .permissionDenied {
            Task {
                await cameraService.start()
                startDetection()
            }
        }
        super.dismissError()
    }
}
