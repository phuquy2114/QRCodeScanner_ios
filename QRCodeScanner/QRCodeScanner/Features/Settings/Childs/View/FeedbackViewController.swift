//
//  FeedbackViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//
import UIKit

class FeedbackViewController: BaseViewController {

    private let heightButton: CGFloat = 48
    private let submitButton: UIButton = UIButton()
    private let imageContainer: UIView = UIView()
    private let viewModel = FeedbackViewModel()
    private let titleLabel = UILabel()
    private let tableView: UITableView = UITableView(
        frame: .zero,
        style: .plain
    )

    override func viewDidLoad() {
        setupUI()

    }

    override func setupUI() {
        self.view.backgroundColor = .black
        setupNavigationBar()
        buildTitle()
        buildTableView()
        buildSubmitButton()
        buildAttachFile()
        buildDesc()
    }

    private func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationTitle(
            "Feedback",
            font: .boldSystemFont(ofSize: 24),
            color: .white
        )
    }

    private func buildTableView() {
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.register(
            FeedbackItemCell.self,
            forCellReuseIdentifier: FeedbackItemCell.identifier
        )
        tableView.changeConstraints()
        view.addSubview(tableView)

        NSLayoutConstraint.activate(
            [
                tableView.topAnchor
                    .constraint(
                        equalTo: self.titleLabel.bottomAnchor,
                        constant: 16
                    ),
                tableView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.heightAnchor.constraint(lessThanOrEqualToConstant: 250)
            ]
        )
    }

    private func buildTitle() {
        titleLabel.textColor = .white
        titleLabel.text = "What problems did you encounter?"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.changeConstraints()
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 4
            ),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            titleLabel.widthAnchor
                .constraint(lessThanOrEqualTo: view.widthAnchor),
        ])

    }
    
    private func buildDesc() {
        let textView = UITextView()
        textView.isEditable = true
        textView.backgroundColor = .backgroundColor
        textView.textColor = UIColor(white: 0.9, alpha: 1)
        textView.font = .systemFont(ofSize: 18)
        textView.text = "đááds"
        textView.contentInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        textView.layer.cornerRadius = 6
        view.addSubview(textView)
        textView.changeConstraints()
        
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            textView.trailingAnchor
                .constraint(equalTo: tableView.trailingAnchor),
            textView.bottomAnchor
                .constraint(equalTo: imageContainer.topAnchor, constant: -16),
            textView.topAnchor.constraint(
                    lessThanOrEqualTo: tableView.bottomAnchor,
                    constant: 16)
        ])
    
    }
    
    private func buildAttachFile() {
        imageContainer.backgroundColor = UIColor(white: 0.2, alpha: 1)
        imageContainer.layer.cornerRadius = 18
        imageContainer.clipsToBounds = true
        imageContainer.layer.borderColor = UIColor.clear.cgColor
        imageContainer.isUserInteractionEnabled = true
        view.addSubview(imageContainer)
        imageContainer.changeConstraints()
        
        NSLayoutConstraint.activate([
            imageContainer.heightAnchor.constraint(equalToConstant: 48),
            imageContainer.widthAnchor.constraint(equalToConstant: 54),
            imageContainer.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 16),
            imageContainer.bottomAnchor
                .constraint(equalTo: submitButton.topAnchor, constant: -24),
        ])
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(tapImage(_:))
        )
        imageContainer.addGestureRecognizer(tap)
        let image = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        
        image.image = UIImage(
            systemName: "camera.fill",
            withConfiguration: config
        )?.withRenderingMode(.alwaysTemplate)
        image.tintColor = UIColor(white: 0.8, alpha: 1)
        image.contentMode = .scaleAspectFit
        
        imageContainer.addSubview(image)
        image.changeConstraints()
        
        NSLayoutConstraint.activate([
            image.centerXAnchor
                .constraint(equalTo: imageContainer.centerXAnchor),
            image.centerYAnchor
                .constraint(equalTo: imageContainer.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 32),
            image.widthAnchor.constraint(equalToConstant: 32),
        ])
        
        let label = UILabel()
        label.text = "Attach image"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.backgroundColor = .clear
        label.textColor = UIColor(white: 0.8, alpha: 1)
        view.addSubview(label)
        label.changeConstraints()
        
        NSLayoutConstraint.activate([
            label.leadingAnchor
                .constraint(equalTo: imageContainer.trailingAnchor, constant: 16),
            label.centerYAnchor
                .constraint(equalTo: imageContainer.centerYAnchor),
            label.trailingAnchor.constraint(
                    lessThanOrEqualTo: view.trailingAnchor,
                    constant: -70)
        ])
        
        let imageTick = UIImageView()
        imageTick.tintColor = .green
        imageTick.contentMode = .scaleAspectFit
        imageTick.image = UIImage(systemName: "camera.fill")
        view.addSubview(imageTick)
        imageTick.changeConstraints()
        
        NSLayoutConstraint.activate([
            imageTick.centerYAnchor
                .constraint(equalTo: label.centerYAnchor),
            imageTick.leadingAnchor
                .constraint(equalTo: label.trailingAnchor, constant: 12),
            imageTick.widthAnchor.constraint(equalToConstant: 28),
            imageTick.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    private func buildSubmitButton() {
        submitButton.applyAccentBackground()
        submitButton.backgroundColor = ThemeManager.shared.themeColor
        submitButton.layer.cornerRadius = 6
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        submitButton.addAction(
            .init { [weak self] _ in
                
            },
            for: .touchUpInside
        )
        submitButton.changeConstraints()
        view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            submitButton.heightAnchor.constraint(equalToConstant: heightButton),
            submitButton.widthAnchor
                .constraint(lessThanOrEqualTo: view.widthAnchor),
        ])
    }
    
    @objc private func tapImage(_ sender: UITapGestureRecognizer) {
        print("dssadasdasd")
    }
}

// MARK: - UITableViewDataSource

extension FeedbackViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        self.viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedbackItemCell.identifier, for: indexPath) as? FeedbackItemCell
        else {
            return UITableViewCell()
        }
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item, indexPath.row)
        
        cell.onTapButton = { [weak self] index in
            self?.viewModel.toggleItem(at: index)
            self?.tableView.reloadData()
        }
        return cell
    }
}

