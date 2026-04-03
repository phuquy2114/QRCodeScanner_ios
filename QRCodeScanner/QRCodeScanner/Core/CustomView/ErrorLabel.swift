//
//  ErrorLabel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 2/4/26.
//
// MARK: ErrorLabel

import UIKit

final class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = .systemFont(ofSize: 12)
        textColor = .systemRed
        isHidden = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func setText(_ text: String?) {
        self.text = text
        isHidden = text == nil
    }
}
