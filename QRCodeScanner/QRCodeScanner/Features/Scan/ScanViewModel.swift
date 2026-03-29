//
//  ScanViewModel.swift
//  QRCodeScanner
//

import AVFoundation
import Combine
import UIKit

// MARK: - CameraActor
// Actor riêng biệt — toàn bộ AVFoundation chạy trên actor's executor (background)
// Không liên quan gì đến @MainActor
actor CameraActor {

    // MARK: - AVFoundation objects
    // Khai báo nonisolated để ScanViewController có thể bind previewLayer mà không cần await
    nonisolated let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?

    // MARK: - Capabilities (trả về qua async)
    private(set) var minZoom: CGFloat = 1.0
    private(set) var maxZoom: CGFloat = 5.0
    private(set) var hasTorch: Bool = false

    // MARK: - Configure

    func configure(
        position: CameraPosition,
        supportedTypes: [AVMetadataObject.ObjectType]
    ) {
        session.beginConfiguration()
        session.sessionPreset = .high

        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        guard let device = cameraDevice(for: position),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
            videoDeviceInput = input
        }

        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = supportedTypes
        }

        session.commitConfiguration()

        // Update capabilities
        minZoom = 1.0
        maxZoom = min(device.activeFormat.videoMaxZoomFactor, 8.0)
        hasTorch = device.hasTorch
    }

    // MARK: - Session Control

    func startRunning() {
        guard !session.isRunning else { return }
        session.startRunning()
    }

    func stopRunning() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Flash

    func setFlash(_ on: Bool) throws {
        guard let device = videoDeviceInput?.device, device.hasTorch else {
            throw CameraError.torchUnavailable
        }
        try device.lockForConfiguration()
        if on {
            try device.setTorchModeOn(level: 1.0)
        } else {
            device.torchMode = .off
        }
        device.unlockForConfiguration()
    }

    // MARK: - Zoom

    func setZoom(_ factor: CGFloat) {
        guard let device = videoDeviceInput?.device else { return }
        let clamped = max(minZoom, min(factor, maxZoom))
        try? device.lockForConfiguration()
        device.videoZoomFactor = clamped
        device.unlockForConfiguration()
    }

    // MARK: - Focus

    func setFocus(at point: CGPoint) {
        guard let device = videoDeviceInput?.device else { return }
        try? device.lockForConfiguration()
        if device.isFocusPointOfInterestSupported {
            device.focusPointOfInterest = point
            device.focusMode = .autoFocus
        }
        if device.isExposurePointOfInterestSupported {
            device.exposurePointOfInterest = point
            device.exposureMode = .autoExpose
        }
        device.unlockForConfiguration()
    }

    // MARK: - Metadata Delegate

    func setMetadataDelegate(
        _ delegate: AVCaptureMetadataOutputObjectsDelegate,
        queue: DispatchQueue = .main
    ) {
        metadataOutput.setMetadataObjectsDelegate(delegate, queue: queue)
    }

    // MARK: - Rect of Interest

    func setRectOfInterest(_ rect: CGRect) {
        metadataOutput.rectOfInterest = rect
    }

    // MARK: - Capabilities Snapshot (để ViewModel đọc sau configure)

    func capabilities() -> (minZoom: CGFloat, maxZoom: CGFloat, hasTorch: Bool)
    {
        (minZoom, maxZoom, hasTorch)
    }

    // MARK: - Private

    private func cameraDevice(for position: CameraPosition) -> AVCaptureDevice?
    {

        let avPos: AVCaptureDevice.Position = position == .back ? .back : .front
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera, .builtInDualCamera,
                .builtInWideAngleCamera,
            ],
            mediaType: .video,
            position: avPos
        )
        return discovery.devices.first
            ?? AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: avPos
            )
    }
}

// MARK: - ScanViewModel
// @MainActor từ BaseViewModel — chỉ quản lý state UI
// Mọi camera work đều delegate sang CameraActor

@MainActor
final class ScanViewModel: BaseViewModel {

    // MARK: - Published State
    @Published private(set) var scanResult: ScanResult? = nil
    @Published private(set) var cameraPosition: CameraPosition = .back
    @Published private(set) var isFlashOn: Bool = false
    @Published private(set) var zoomFactor: CGFloat = 1.0
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var hasTorch: Bool = false
    @Published private(set) var minZoom: CGFloat = 0.0
    @Published private(set) var maxZoom: CGFloat = 5.0

    // MARK: - Camera Actor (nonisolated — truy cập tự do)
    let camera = CameraActor()

    // Expose session để ViewController bind previewLayer (nonisolated, an toàn)
    var captureSession: AVCaptureSession { camera.session }

    // MARK: - Setup

    func setupCamera() async {
        guard await requestCameraPermission() else {
            setError(CameraError.permissionDenied)
            return
        }
        await configureCamera(position: cameraPosition)
        await camera.startRunning()
    }

    // MARK: - Configure (gọi camera actor ở background, update state ở main)
    private func configureCamera(position: CameraPosition) async {
        await camera.configure(
            position: position,
            supportedTypes: supportedCodeTypes
        )
        // Đọc capabilities về main để update @Published
        let caps = await camera.capabilities()
        minZoom = caps.minZoom
        maxZoom = caps.maxZoom
        hasTorch = caps.hasTorch
        zoomFactor = 1.0
        if position == .front { isFlashOn = false }
    }

    // MARK: - Session Control

    func startSession() {
        Task {
            isScanning = true
            await camera.startRunning()
        }
    }

    func stopSession() {
        Task {
            isScanning = false
            await camera.stopRunning()
        }
    }

    func pauseSession() { isScanning = false }
    func resumeSession() { isScanning = true }

    // MARK: - Flash

    func toggleFlash() {
        guard hasTorch, cameraPosition == .back else { return }
        let newState = !isFlashOn
        Task {
            do {
                try await camera.setFlash(newState)
                isFlashOn = newState
            } catch {
                setError(error)
            }
        }
    }

    // MARK: - Flip Camera

    func flipCamera() async {
        isFlashOn = false
        cameraPosition.toggle()
        await configureCamera(position: cameraPosition)
    }

    // MARK: - Zoom

    func setZoom(_ factor: CGFloat) {
        let clamped = max(minZoom, min(factor, maxZoom))
        zoomFactor = clamped
        Task { await camera.setZoom(clamped) }
    }

    func zoomIn() { setZoom(zoomFactor + 0.5) }
    func zoomOut() { setZoom(zoomFactor - 0.5) }

    // MARK: - Focus

    func setFocus(at point: CGPoint) {
        Task { await camera.setFocus(at: point) }
    }

    // MARK: - Metadata Delegate

    func setMetadataDelegate(
        _ delegate: AVCaptureMetadataOutputObjectsDelegate,
        queue: DispatchQueue = .main
    ) {
        Task { await camera.setMetadataDelegate(delegate, queue: queue) }
    }

    func setRectOfInterest(_ rect: CGRect) {
        Task { await camera.setRectOfInterest(rect) }
    }

    // MARK: - Scan Result

    func handleScanResult(_ content: String, type: AVMetadataObject.ObjectType)
    {
        guard isScanning else { return }
        pauseSession()
        scanResult = ScanResult(content: content, type: type)
    }

    func resetScan() {
        scanResult = nil
        resumeSession()
    }

    // MARK: - Decode QR from Image

    func decodeQRFromImage(_ image: UIImage) async {
        perform(key: "decode") {
            
            let result = try await Task.detached(priority: .userInitiated) {
                
                guard let ciImage = CIImage(image: image) else {
                    let error: String = await MainActor.run {
                        return "Unable_to_process_the_image".localized
                    }
                    throw NSError(domain: "QR", code: 0, userInfo:
                                    [NSLocalizedDescriptionKey: error ])
                }
                
                let detector = CIDetector(
                    ofType: CIDetectorTypeQRCode,
                    context: nil,
                    options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                )
                
                let features =
                    detector?.features(in: ciImage) as? [CIQRCodeFeature]
                
                guard let code = features?.first?.messageString, !code.isEmpty else {

                    let error: String = await MainActor.run {
                        return "No_QR_code_found_in_the_image".localized
                    }

                    throw NSError(domain: "QR", code: 1, userInfo:
                                    [NSLocalizedDescriptionKey: error])

                }
                return code
            }.value
            
            self.handleScanResult(result, type: .qr)
        }
    }

    // MARK: - Supported Code Types
    var supportedCodeTypes: [AVMetadataObject.ObjectType] {
        [
            .qr, .ean8, .ean13, .pdf417, .aztec, .code128,
            .code39, .code93, .dataMatrix, .interleaved2of5, .itf14, .upce,
        ]
    }

    // MARK: - Camera Permission
    private func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}
