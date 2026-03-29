//
//  ScanViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import AVFoundation
import Combine
import PhotosUI
import UIKit

@MainActor
class ScanViewController: BaseViewController {

    @IBOutlet weak var zoomSlider: UISlider!
    @IBOutlet weak var flashButton: UIButton!

    private let viewModel = ScanViewModel()
    // Scan overlay (scanner frame + scan line)
    private let scanOverlayView = ScanOverlayView()
    private var cancellables = Set<AnyCancellable>()
    // Camera preview
    @IBOutlet weak var previewContainer: UIView!
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupZoomControls()
        setupUI()
        setupActions()
        bindData()
        Task { await viewModel.setupCamera() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(true)
        viewModel.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSession()
    }

    override func setupUI() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        setupPreview()
        setupScanOverlay()
        setupZoomControls()
        setupActions()
    }

    override func bindData() {
        // Flash state → update button icon
        viewModel.$isFlashOn
            .receive(on: RunLoop.main)
            .sink { [weak self] isOn in
                let name = isOn ? "bolt.fill" : "bolt.slash.fill"
                let img = UIImage(systemName: name)?
                    .withConfiguration(
                        UIImage.SymbolConfiguration(
                            pointSize: 22,
                            weight: .medium
                        )
                    )
                self?.flashButton.setImage(img, for: .normal)
                let color = isOn ? ThemeManager.shared.themeColor : .white
                self?.flashButton.tintColor = color
            }
            .store(in: &cancellables)

        // hasTorch → ẩn/hiện flash button
        viewModel.$hasTorch
            .receive(on: RunLoop.main)
            .sink { [weak self] has in
                self?.flashButton.alpha = has ? 1 : 0.3
                self?.flashButton.isUserInteractionEnabled = has
            }
            .store(in: &cancellables)

        // Zoom factor → sync slider (không trigger action)
        viewModel.$zoomFactor
            .receive(on: RunLoop.main)
            .sink { [weak self] factor in
                guard let self else { return }
                let range = self.viewModel.maxZoom - self.viewModel.minZoom
                let sliderVal = Float((factor - self.viewModel.minZoom) / range)
                self.zoomSlider.setValue(sliderVal, animated: true)
            }
            .store(in: &cancellables)

        // isScanning → overlay animation
        viewModel.$isScanning
            .receive(on: RunLoop.main)
            .sink { [weak self] scanning in
                scanning
                    ? self?.scanOverlayView.startAnimation()
                    : self?.scanOverlayView.stopAnimation()
            }
            .store(in: &cancellables)

        // Scan result
        viewModel.$scanResult
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { [weak self] result in
                self?.onScanResult(result)
            }
            .store(in: &cancellables)
        
        // let errorString = CameraError.permissionDenied.errorDescription?.localized
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                guard let self = self, let message = message, !message.isEmpty else {
                    return
                }
                Task {
                    await self.showCameraPermissionDeniedAlert()
                }
            }
            .store(in: &cancellables)

    }

    override func setupActions() {

        zoomSlider.addAction(
            .init { [weak self] _ in
                guard let self else { return }
                // Map slider 0–1 → minZoom–maxZoom
                let range = self.viewModel.maxZoom - self.viewModel.minZoom
                let factor =
                    self.viewModel.minZoom + CGFloat(self.zoomSlider.value)
                    * range
                self.viewModel.setZoom(factor)
            },
            for: .valueChanged
        )

        // Metadata delegate
        viewModel.setMetadataDelegate(self)

        // Pinch to zoom
        let pinch = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch(_:))
        )
        view.addGestureRecognizer(pinch)

        // Tap to focus
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapFocus(_:))
        )
        previewContainer.addGestureRecognizer(tap)
    }
    
    override func applyNewTheme(color: UIColor) {
        self.scanOverlayView.accentColor = color
        self.zoomSlider.minimumTrackTintColor = color
        zoomSlider.setThumbImage(makeSliderThumb(), for: .normal)
    }

    // MARK: Camera preview (full screen)
    private func setupPreview() {
        previewContainer.frame = view.bounds
        previewContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //previewContainer.backgroundColor = .black
        
        let layer = AVCaptureVideoPreviewLayer(
            session: viewModel.captureSession
        )
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        previewContainer.layer.addSublayer(layer)
        previewLayer = layer

    }

    // MARK: Scan overlay (centered square frame + scan line)
    private func setupScanOverlay() {
        scanOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanOverlayView)

        let size = UIScreen.current.bounds.width * 0.78
        NSLayoutConstraint.activate([
            scanOverlayView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            scanOverlayView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: -30
            ),
            scanOverlayView.widthAnchor.constraint(equalToConstant: size),
            scanOverlayView.heightAnchor.constraint(
                equalToConstant: size * 0.9
            ),
        ])

        // Scan region cho AVFoundation
        viewModel.captureSession.outputs
            .compactMap { $0 as? AVCaptureMetadataOutput }
            .first.flatMap { output in
                onMain { [weak self] in
                    self?.updateScanRect()
                }
                return Optional<Void>.none
            }

    }

    private func setupZoomControls() {
        // Slider style
        zoomSlider.minimumValue = 0
        zoomSlider.maximumValue = 1
        zoomSlider.value = 0
        zoomSlider.minimumTrackTintColor = ThemeManager.shared.themeColor
        zoomSlider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.3)
        zoomSlider.setThumbImage(makeSliderThumb(), for: .normal)

    }
    
    private func makeSliderThumb() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ThemeManager.shared.themeColor.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }

    // MARK: - Scan Result
    private func onScanResult(_ result: ScanResult) {
        haptic(.success)
        scanOverlayView.flashSuccess()

        // Navigate đến result screen
        let resultVC = ScanResultViewController(result: result) { [weak self] in
            self?.viewModel.resetScan()
        }
        resultVC.modalPresentationStyle = .pageSheet
        if let sheet = resultVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(resultVC, animated: true)
    }

    // MARK: - Photo Library

    private func openPhotoLibrary() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Scan Rect

    private func updateScanRect() {
        guard let previewLayer else { return }
        let overlayFrame = scanOverlayView.convert(
            scanOverlayView.bounds,
            to: previewContainer
        )
        let normalized = previewLayer.metadataOutputRectConverted(
            fromLayerRect: overlayFrame
        )
        
        let output = viewModel.captureSession.outputs.first(where: {$0 is AVCaptureMetadataOutput})
        if let output = output as? AVCaptureMetadataOutput {
            output.rectOfInterest = normalized
        }
    }

    // MARK: - Gestures

    private var baseZoomFactor: CGFloat = 1.0
 
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            baseZoomFactor = viewModel.zoomFactor
        case .changed:
            viewModel.setZoom(baseZoomFactor * gesture.scale)
        default: break
        }
    }

    @objc private func handleTapFocus(_ gesture: UITapGestureRecognizer) {
         let touchPoint = gesture.location(in: previewContainer)
         let focusPoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: touchPoint)
             ?? CGPoint(x: 0.5, y: 0.5)
         viewModel.setFocus(at: focusPoint)
         showFocusIndicator(at: touchPoint)
     }
  
     private func showFocusIndicator(at point: CGPoint) {
         let ring = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
         ring.center = point
         ring.layer.borderWidth  = 1.5
         ring.layer.borderColor  = ThemeManager.shared.themeColor.cgColor
         ring.layer.cornerRadius = 30
         ring.alpha = 0
         previewContainer.addSubview(ring)
  
         UIView.animateKeyframes(withDuration: 0.8, delay: 0) {
             UIView.addKeyframe(withRelativeStartTime: 0,   relativeDuration: 0.2) { ring.alpha = 1 }
             UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
                 ring.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
             }
             UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) { ring.alpha = 0 }
         } completion: { _ in ring.removeFromSuperview() }
     }

    @IBAction func handlePhotoButton(_ sender: UIButton) {
        openPhotoLibrary()
    }

    @IBAction func handleFlashButton(_ sender: UIButton) {
        viewModel.toggleFlash()
    }

    @IBAction func handleCameraButton(_ sender: UIButton) {
        Task { await self.viewModel.flipCamera() }
    }

    @IBAction func zoomOut(_ sender: UIButton) {
        self.viewModel.zoomOut()
    }

    @IBAction func zoomIn(_ sender: UIButton) {
        self.viewModel.zoomIn()
    }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let content = object.stringValue else { return }
        viewModel.handleScanResult(content, type: object.type)
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ScanViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
 
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            Task { await self?.viewModel.decodeQRFromImage(image) }
        }
    }
}
