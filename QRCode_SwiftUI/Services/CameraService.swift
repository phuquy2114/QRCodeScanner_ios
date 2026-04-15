//
//  CameraService.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import AVFoundation
import UIKit

final class CameraService: NSObject {

    // MARK: - Public

    let session = AVCaptureSession()

    var onQRCodeDetected: ((Result<String, AppError>) -> Void)?

    private(set) var currentPosition: AVCaptureDevice.Position = .back

    // MARK: - Private

    private var videoInput: AVCaptureDeviceInput?
    private let metadataOutput = AVCaptureMetadataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    // MARK: - Setup

    private var isConfigured = false

    /// Async — không bao giờ block main thread
    func configure(completion: @escaping (Result<Void, AppError>) -> Void) {
        guard !isConfigured else {
            completion(.success(()))
            return
        }
        sessionQueue.async { [weak self] in
            guard let self else { return }
            do {
                try self.setupSession()
                self.isConfigured = true
                completion(.success(()))
            } catch {
                completion(.failure(error as? AppError ?? .cameraUnavailable))
            }
        }
    }

    private func setupSession() throws {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard
            let device = bestCamera(position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            throw AppError.cameraUnavailable
        }
        session.addInput(input)
        videoInput = input

        guard session.canAddOutput(metadataOutput) else {
            session.commitConfiguration()
            throw AppError.cameraUnavailable
        }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8, .code128, .code39, .pdf417, .aztec]

        session.commitConfiguration()
    }

    // MARK: - Session lifecycle
    func start() {
        // Bỏ [weak self] để đảm bảo session được start trọn vẹn trong background queue
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        // Quan trọng: KHÔNG dùng [weak self] ở đây.
        // Giữ strong self đảm bảo session được stop xong xuôi trên background queue
        // rồi `CameraService` mới được deinit ở background, giúp Main Thread mượt mà.
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    /*
    func start() {
        sessionQueue.async { [weak self] in
            guard let self, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
     */
    
    // MARK: - Flash
    func setFlash(_ on: Bool) {
        guard
            let device = videoInput?.device,
            device.hasTorch,
            (try? device.lockForConfiguration()) != nil
        else { return }

        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    // MARK: - Flip camera

    func flipCamera() {
        let nextPosition: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        guard let newDevice = bestCamera(position: nextPosition),
              let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()

            if let old = self.videoInput {
                self.session.removeInput(old)
            }

            if self.session.canAddInput(newInput) {
                self.session.addInput(newInput)
                self.videoInput = newInput
                self.currentPosition = nextPosition
            }

            self.session.commitConfiguration()
        }
    }

    // MARK: - Zoom

    /// zoom: 1.0 → 5.0
    func setZoom(_ factor: CGFloat) {
        guard
            let device = videoInput?.device,
            (try? device.lockForConfiguration()) != nil
        else { return }

        let clamped = max(device.minAvailableVideoZoomFactor,
                         min(factor, device.maxAvailableVideoZoomFactor))
        device.videoZoomFactor = clamped
        device.unlockForConfiguration()
    }

    // MARK: - Helpers

    private func bestCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInWideAngleCamera
        ]
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: position
        )
        return session.devices.first
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CameraService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let value = object.stringValue,
            !value.isEmpty
        else {
            onQRCodeDetected?(.failure(.invalidQRPayload))
            return
        }

        onQRCodeDetected?(.success(value))
    }
}
