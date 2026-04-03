//
//  TextInputTextView.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 1/4/26.
//

import UIKit
class TextInputTextView: UIView {
    var onTextChanged: ((String) -> Void)?
    
    private let counter = UILabel()
    private let smallLabelTop = UILabel()
    private let placeholderLabel = UILabel()
    private let textView = UITextView()
    private(set) var maxLength: Int = 500

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            smallLabelTop.text = placeholder
        }
    }
    
    var textInsets: UIEdgeInsets {
        get {
            return self.textView.contentInset
        }
        set {
            self.textView.contentInset = newValue
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    
    init(placeholder: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        setUp()
    }

    private func setUp() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.textView.backgroundColor = .backgroundColor
        self.textView.isEditable = true
        self.textView.layer.borderColor = UIColor.clear.cgColor
        self.textView.layer.borderWidth = 1.0
        self.textView.layer.cornerRadius = 8.0
        self.textView.clipsToBounds = true
        self.textView.textColor = UIColor(white: 0.9, alpha: 1)
        self.textView.font = .systemFont(ofSize: 20)
        self.textView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.textView.isUserInteractionEnabled = true
        self.textView.isScrollEnabled = true
        textView.delegate = self
        self.addSubview(textView)
        textView.changeConstraints()
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            heightAnchor.constraint(equalToConstant: 150),
        ])
        
        placeholderLabel.text = placeholder
        placeholderLabel.font = .systemFont(ofSize: 20)
        placeholderLabel.textColor = UIColor(white: 0.65, alpha: 1)
        placeholderLabel.textAlignment = .left
        placeholderLabel.sizeToFit()
        placeholderLabel.numberOfLines = 2
        placeholderLabel.lineBreakMode = .byTruncatingTail
        placeholderLabel.textAlignment = .left
        self.addSubview(placeholderLabel)
        placeholderLabel.changeConstraints()
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor
                .constraint(equalTo: self.textView.topAnchor, constant: 15),
            placeholderLabel.leadingAnchor
                .constraint(equalTo: self.textView.leadingAnchor, constant: 10),
            placeholderLabel.centerXAnchor
                .constraint(equalTo: self.textView.centerXAnchor),
        ])
        
        counter.text = "0/\(maxLength)"
        counter.font = .systemFont(ofSize: 11)
        counter.textColor = UIColor(white: 0.4, alpha: 1)
        counter.changeConstraints()
        addSubview(counter)
        
        NSLayoutConstraint.activate([
            counter.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -10
            ),
            counter.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -6
            ),
        ])

        smallLabelTop.text = placeholder
        smallLabelTop.font = .systemFont(ofSize: 15)
        smallLabelTop.textColor = UIColor(white: 0.8, alpha: 1)
        smallLabelTop.textAlignment = .left
        smallLabelTop.sizeToFit()
        smallLabelTop.isHidden = true
        smallLabelTop.numberOfLines = 1
        smallLabelTop.lineBreakMode = .byTruncatingTail
        smallLabelTop.backgroundColor = .backgroundColor
        
        self.addSubview(smallLabelTop)
        smallLabelTop.changeConstraints()
        
        NSLayoutConstraint.activate([
            smallLabelTop.centerYAnchor
                .constraint(equalTo: self.textView.topAnchor),
            smallLabelTop.leadingAnchor
                .constraint(equalTo: self.textView.leadingAnchor, constant: 16),
            smallLabelTop.widthAnchor.constraint(lessThanOrEqualToConstant: 180)
        ])
        
    }
    
    func handleDidFocus() {
        placeholderLabel.isHidden = true
        smallLabelTop.isHidden = false
        self.textView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func setTextViewDelegate(delegate: UITextViewDelegate) {
        self.textView.delegate = delegate
    }
    
    func setMaxLength(length: Int) {
        self.maxLength = length
    }
    
    func setError(_ hasError: Bool) {
        if hasError {
            self.textView.layer.borderWidth = 1
            self.textView.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            self.textView.layer.borderWidth =  0
            self.textView.layer.borderColor = UIColor.clear.cgColor
        }

    }
}
extension TextInputTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        if text.count > maxLength {
            textView.text = String(text.prefix(maxLength))
        }
//        placeholderLabel.isHidden = !textView.text.isEmpty
        counter.text = "\(textView.text.count)/\(maxLength)"
        onTextChanged?(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.handleDidFocus()
    }
}
