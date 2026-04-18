//
//  CameraService.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import AVFoundation

actor CameraService {

    // MARK: - Public
    // nonisolated(unsafe): CameraPreviewView đọc trực tiếp, không qua await.
    // An toàn vì session chỉ được mutate bên trong actor.
    nonisolated(unsafe) let session = AVCaptureSession()

    // AsyncStream là Sendable → nonisolated let hợp lệ không cần unsafe.
    nonisolated let detectionStream: AsyncStream<Result<String, AppError>>

    private(set) var position: AVCaptureDevice.Position = .back

    // MARK: - Private
    private let output = AVCaptureMetadataOutput()
    private let delegate: MetadataDelegate

    private var currentInput: AVCaptureDeviceInput?
    private var configured = false

    // MARK: - Init
    init() {
        let del = MetadataDelegate()
        // closure chạy synchronously → del.continuation được set trước khi AsyncStream init return
        detectionStream = AsyncStream { del.continuation = $0 }
        delegate = del
    }

    // MARK: - Configure
    func configure() async throws {
        guard !configured else { return }

        // AVCaptureDevice.DiscoverySession và AVCaptureDeviceInput.init
        // là @MainActor trong Xcode 16 SDK → hop sang MainActor đúng chỗ.
        let pos = position
        let input = try await MainActor.run {
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInTripleCamera, .builtInDualWideCamera,
                    .builtInWideAngleCamera,
                ],
                mediaType: .video,
                position: pos
            ).devices
            guard let device = devices.first else {
                throw AppError.cameraUnavailable
            }
            return try AVCaptureDeviceInput(device: device)
        }

        // AVCaptureSession methods KHÔNG phải @MainActor —
        // thread-safe, gọi thẳng trên actor executor.
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .high

        guard session.canAddInput(input) else {
            throw AppError.cameraUnavailable
        }
        session.addInput(input)
        currentInput = input

        guard session.canAddOutput(output) else {
            throw AppError.cameraUnavailable
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(delegate, queue: .main)
        output.metadataObjectTypes = [
            .qr, .ean13, .ean8, .code128, .code39, .pdf417, .aztec,
        ]

        configured = true
    }

    // MARK: - Lifecycle
    // AVCaptureSession.startRunning / stopRunning KHÔNG phải @MainActor.
    func start() {
        guard !session.isRunning else { return }
        session.startRunning()
    }

    func stop() {
        guard session.isRunning else { return }
        session.stopRunning()
    }

    // MARK: - Flash
    // AVCaptureDevice config methods là @MainActor → MainActor.run.
    func setFlash(_ on: Bool) async throws {
        guard let device = currentInput?.device else {
            throw AppError.cameraUnavailable
        }
        try await MainActor.run {
            guard device.hasTorch else { return }
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        }
    }

    // MARK: - Flip
    func flip() async throws {
        let next: AVCaptureDevice.Position = position == .back ? .front : .back

        let newInput = try await MainActor.run {
            let devices = AVCaptureDevice.DiscoverySession(
                deviceTypes: [
                    .builtInTripleCamera, .builtInDualWideCamera,
                    .builtInWideAngleCamera,
                ],
                mediaType: .video,
                position: next
            ).devices
            guard let device = devices.first else {
                throw AppError.cameraUnavailable
            }
            return try AVCaptureDeviceInput(device: device)
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        if let old = currentInput { session.removeInput(old) }
        guard session.canAddInput(newInput) else {
            throw AppError.cameraUnavailable
        }

        session.addInput(newInput)
        currentInput = newInput
        position = next
    }

    // MARK: - Zoom
    // AVCaptureDevice zoom properties là @MainActor → MainActor.run.
    func setZoom(_ factor: CGFloat) async throws {
        guard let device = currentInput?.device else {
            throw AppError.cameraUnavailable
        }
        try await MainActor.run {
            try device.lockForConfiguration()
            device.videoZoomFactor = min(
                max(factor, device.minAvailableVideoZoomFactor),
                device.maxAvailableVideoZoomFactor
            )
            device.unlockForConfiguration()
        }
    }
}

// MARK: - MetadataDelegate
//
// Tách NSObject riêng vì actor không conform được ObjC protocol.
//
// @unchecked Sendable: delegate được share qua actor boundary.
// An toàn vì:
//   · continuation set đúng 1 lần trong actor init (synchronous)
//   · continuation.yield chỉ gọi từ main queue (queue: .main)
//
// extension riêng + nonisolated trên method:
//   override @MainActor inference mà Swift 6 tự gán cho conformance
//   với AVCaptureMetadataOutputObjectsDelegate.

private final class MetadataDelegate: NSObject, @unchecked Sendable {
    // Đánh dấu biến này để actor có thể cập nhật trong hàm init an toàn khi class bị gán là @MainActor.
    nonisolated(unsafe) var continuation:
        AsyncStream<Result<String, AppError>>.Continuation?

    // Ghi đè init thành nonisolated để có thể khởi tạo đồng bộ từ bên trong Actor.
    nonisolated override init() {
        super.init()
    }
}

extension MetadataDelegate: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput objects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let obj = objects.first as? AVMetadataMachineReadableCodeObject,
            let value = obj.stringValue,
            !value.isEmpty
        else { return }

        continuation?.yield(.success(value))
    }
}
