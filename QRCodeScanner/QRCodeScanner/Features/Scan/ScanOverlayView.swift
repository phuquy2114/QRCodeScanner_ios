//
//  ScanOverlayView.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 23/3/26.
//

import UIKit

// MARK: - ScanOverlayView
final class ScanOverlayView: UIView {

    var themeColor: UIColor = ThemeManager.shared.themeColor {
        didSet {
            setNeedsDisplay()
            scanLine.backgroundColor = themeColor
        }
    }

    private let scanLine = UIView()
    private var scanLineTopConstraint: NSLayoutConstraint?
    private var isAnimating = false

    // MARK: Corner style
    private let cornerLength: CGFloat = 28
    private let cornerWidth: CGFloat = 12
    private let cornerRadius: CGFloat = 4

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        scanLine.backgroundColor = themeColor
        scanLine.layer.cornerRadius = 1
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scanLine)

        let topConstraint = scanLine.topAnchor.constraint(equalTo: topAnchor)
        scanLineTopConstraint = topConstraint

        NSLayoutConstraint.activate([
            scanLine.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 8
            ),
            scanLine.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -8
            ),
            topConstraint,
            scanLine.heightAnchor.constraint(equalToConstant: 2.5),
        ])
    }

    // MARK: Draw corner brackets

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)

        themeColor.setStroke()
        ctx.setLineWidth(cornerWidth)
        ctx.setLineCap(.square)

        let corners: [(CGPoint, [(CGFloat, CGFloat)])] = [
            // top-left
            (CGPoint(x: 0, y: 0), [(1, 0), (0, 0), (0, 1)]),
            // top-right
            (CGPoint(x: rect.width, y: 0), [(-1, 0), (0, 0), (0, 1)]),
            // bottom-left
            (CGPoint(x: 0, y: rect.height), [(1, 0), (0, 0), (0, -1)]),
            // bottom-right
            (
                CGPoint(x: rect.width, y: rect.height),
                [(-1, 0), (0, 0), (0, -1)]
            ),
        ]

        let L = cornerLength
        let R = cornerRadius

        for (origin, dirs) in corners {
            // Horizontal line
            let hDir = CGPoint(x: dirs[0].0, y: dirs[0].1)
            let vDir = CGPoint(x: dirs[2].0, y: dirs[2].1)

            let hStart = CGPoint(x: origin.x + hDir.x * R, y: origin.y)
            let hEnd = CGPoint(x: origin.x + hDir.x * L, y: origin.y)

            let vStart = CGPoint(x: origin.x, y: origin.y + vDir.y * R)
            let vEnd = CGPoint(x: origin.x, y: origin.y + vDir.y * L)

            ctx.move(to: hStart)
            ctx.addLine(to: hEnd)

            ctx.strokePath()

            ctx.move(to: vStart)
            ctx.addLine(to: vEnd)
            ctx.strokePath()

            // Arc at corner

        }
    }

    // MARK: Scan line animation

    func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        animateScanLine()
    }

    func stopAnimation() {
        isAnimating = false
        layer.removeAllAnimations()
        scanLine.layer.removeAllAnimations()
    }

    func flashSuccess() {
        UIView.animate(
            withDuration: 0.12,
            animations: {
                self.scanLine.backgroundColor = .white
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.scanLine.backgroundColor = self.themeColor
                }
            }
        )
    }

    private func animateScanLine() {
        guard isAnimating, let constraint = scanLineTopConstraint else {
            return
        }
        constraint.constant = 4
        layoutIfNeeded()

        UIView.animate(withDuration: 1.8, delay: 0, options: [.curveEaseInOut]) {
            constraint.constant = self.bounds.height - 8
            self.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self, self.isAnimating else { return }
            UIView.animate(withDuration: 1.8, delay: 0.1, options: [.curveEaseInOut]) {
                constraint.constant = 4
                self.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.animateScanLine()
            }
        }
        
    }
}
