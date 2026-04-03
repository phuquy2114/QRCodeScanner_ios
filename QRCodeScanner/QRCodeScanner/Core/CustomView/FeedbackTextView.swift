//
//  FeedbackTextView.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 3/4/26.
//

import UIKit

// MARK: FeedbackTextView
final class FeedbackTextView: UIView {
    var onTextChanged: ((String) -> Void)?

    private let textView = UITextView()
    private let placeholder = UILabel()
    private let counter = UILabel()
    private let maxLength: Int

    init(placeholder text: String, maxLength: Int) {
        self.maxLength = maxLength
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0.15, alpha: 1)
        layer.cornerRadius = 12
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: 140).isActive = true

        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 16)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        placeholder.text = text
        placeholder.font = .systemFont(ofSize: 16)
        placeholder.textColor = UIColor(white: 0.4, alpha: 1)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholder)

        counter.text = "0/\(maxLength)"
        counter.font = .systemFont(ofSize: 11)
        counter.textColor = UIColor(white: 0.4, alpha: 1)
        counter.translatesAutoresizingMaskIntoConstraints = false
        addSubview(counter)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            textView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 10
            ),
            textView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -10
            ),
            textView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -24
            ),

            placeholder.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: 7
            ),
            placeholder.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: 5
            ),

            counter.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -10
            ),
            counter.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -6
            ),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func setError(_ hasError: Bool) {
        layer.borderWidth = hasError ? 1 : 0
        layer.borderColor =
            hasError ? UIColor.systemRed.cgColor : UIColor.clear.cgColor
    }
}

extension FeedbackTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        if text.count > maxLength {
            textView.text = String(text.prefix(maxLength))
        }
        placeholder.isHidden = !textView.text.isEmpty
        counter.text = "\(textView.text.count)/\(maxLength)"
        onTextChanged?(textView.text)
    }
}
