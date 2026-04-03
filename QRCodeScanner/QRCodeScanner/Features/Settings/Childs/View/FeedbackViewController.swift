//
//  FeedbackViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//
import UIKit
import Combine

class FeedbackViewController: BaseViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let submitButton = FilledButton()
    private let viewModel = FeedbackViewModel()
    private let titleLabel = UILabel()
    private let textView = TextInputTextView(placeholder: "Describe your problem...")
    private let tableView: UITableView = UITableView(
        frame: .zero,
        style: .plain
    )
    private var cancellables  = Set<AnyCancellable>()
    
    // Image picker
    private let imageSection = ImageSection()
    
    override func viewDidLoad() {
        setupUI()
        setupActions()
        bindData()
    }

    override func setupUI() {
        self.view.backgroundColor = .black
        setupNavigationBar()
        setupScrollView()
        buildTitle()
        buildTableView()
        buildDesc()
        buildAttachFile()
        buildSubmitButton()
    }
    
    override func setupActions() {
        // Description
        textView.onTextChanged = { [weak self] text in
            self?.viewModel.description = text
        }
        
        // Add image
        imageSection.onAddTapped = { [weak self] in
            self?.presentImagePicker()
        }
        
        imageSection.onRemoveTapped = { [weak self] index in
            self?.viewModel.removeImage(at: index)
        }
        
        submitButton.addAction(
            .init { [weak self] _ in
                self?.viewModel.submitFeedback()
            },
            for: .touchUpInside
        )
    }
    
    override func bindData() {
        viewModel.$title
            .receive(on: RunLoop.main)
            .combineLatest(viewModel.$description.receive(on: RunLoop.main))
            .map { newTitle, newDesc in 
                let titleOk = !newTitle.trimmingCharacters(in: .whitespaces).isEmpty
                let descOk  = !newDesc.trimmingCharacters(in: .whitespaces).isEmpty
                return titleOk && descOk
            }
            .sink { [weak self] valid in
                self?.submitButton.setEnabled(valid)
            }
            .store(in: &cancellables)
        
        // Validation errors
        viewModel.$titleError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let errorMessage = error {
                    self?.showToastAsync(errorMessage)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$descriptionError
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                if let errorMessage = error {
                    self?.showToastAsync(errorMessage)
                }
                self?.textView.setError(error != nil)
            }
            .store(in: &cancellables)
        
        // Images
        viewModel.$attachFiles
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                guard let self else { return }
                self.imageSection.setImages(
                    images,
                    canAdd: self.viewModel.canAddMoreImages
                )
            }
            .store(in: &cancellables)
        
        // ViewState
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loading:
                    self.submitButton.setLoading(true)
                case .success:
                    self.submitButton.setLoading(false)
                    self.showToastAsync("Feedback submitted successfully! 🎉")
                    Task {
                        await self.delay(seconds: 1.5)
                        self.pop()
                    }
                case .error(let msg):
                    self.submitButton.setLoading(false)
                    Task { await self.showAlert(title: "Error: ", message: msg) }
                default:
                    self.submitButton.setLoading(false)
                }
            }
            .store(in: &cancellables)
    }

    private func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationTitle(
            "Feedback",
            font: .boldSystemFont(ofSize: 24),
            color: .white
        )
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.changeConstraints()
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -(48 + 8 + 24))
        ])
    }
    
    private func buildTitle() {
        titleLabel.textColor = .white
        titleLabel.text = "What problems did you encounter?"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.changeConstraints()
        scrollView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.topAnchor
                .constraint(equalTo: scrollView.topAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor)
        ])
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
        scrollView.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: self.titleLabel.bottomAnchor,
                constant: 16),
            tableView.leadingAnchor
                .constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: 250),
        ])
    }

    private func buildDesc() {
        scrollView.addSubview(textView)
        textView.changeConstraints()
        NSLayoutConstraint.activate([
            textView.leadingAnchor
                .constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            textView.topAnchor
                .constraint(equalTo: tableView.bottomAnchor, constant: 8),
        ])
    }
    
    private func buildAttachFile() {
        let label = UILabel()
        label.text = "Attach images (maximum \(self.viewModel.maxImages) images)"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.backgroundColor = .clear
        label.textColor = UIColor(white: 0.8, alpha: 1)
        scrollView.addSubview(label)
        label.changeConstraints()

        NSLayoutConstraint.activate([
            label.leadingAnchor
                .constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            label.centerXAnchor
                .constraint(equalTo: scrollView.centerXAnchor),
            label.topAnchor.constraint(
                equalTo: textView.bottomAnchor, constant: 16),
            label.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        scrollView.addSubview(imageSection)
        imageSection.changeConstraints()
        NSLayoutConstraint.activate([
            imageSection.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor, constant: 16),
            imageSection.trailingAnchor.constraint(
                lessThanOrEqualTo: scrollView.trailingAnchor,
                constant: -16),
            imageSection.topAnchor.constraint(
                equalTo: label.bottomAnchor, constant: 6),
            imageSection.bottomAnchor
                .constraint(equalTo: scrollView.bottomAnchor, constant: -50)
        ])

    }

    private func buildSubmitButton() {
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.setTitle("SUBMIT", for: .normal)
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
            submitButton.widthAnchor
                .constraint(lessThanOrEqualTo: view.widthAnchor),
        ])
    }
    
    private func presentImagePicker() {
        Task {
            let choice = await showActionSheet(
                title: "Add images",
                actions: [
                    ("Take a photo", .default),
                    ("Choose from the library", .default),
                ]
            )
            switch choice {
            case 0: self.openCamera()
            case 1: self.openPhotoLibrary()
            default: break
            }
        }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Keyboard

    override func keyboardWillShow(height: CGFloat, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = height
        }
    }

    override func keyboardWillHide(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
        }
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

// MARK: - UIImagePickerControllerDelegate
extension FeedbackViewController: UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard
            let image = info[.editedImage] as? UIImage
                ?? info[.originalImage] as? UIImage
        else { return }
        viewModel.addImage(image)
    }
}


