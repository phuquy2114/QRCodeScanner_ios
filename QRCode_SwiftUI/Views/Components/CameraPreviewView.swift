//
//  CameraPreviewView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 6/4/26.
//

import SwiftUI
import AVFoundation

/// Drop vào bất kỳ View nào, truyền session là chạy
struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

final class PreviewUIView: UIView {

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    // Không cần layoutSubviews — AVCaptureVideoPreviewLayer là backing layer
    // của view này (layerClass override), nên tự resize theo bounds của view.
    // Set frame thủ công ở đây là thừa và gây flush CALayer pipeline
    // mỗi layout pass, bao gồm cả lúc animate chuyển tab.
}
