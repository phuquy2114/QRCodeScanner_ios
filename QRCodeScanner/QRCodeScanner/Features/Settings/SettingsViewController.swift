//
//  SettingsViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import Combine
import UIKit

final class SettingsViewController: BaseViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let viewModel = SettingsViewModel()
    // Theme section
    private var themeRadioViews: [ThemeRadioView] = []

    // Sound section
    private lazy var vibrateToggle = makeToggle()
    private lazy var beepToggle = makeToggle()
    private lazy var autoFocusToggle = makeToggle()
    private lazy var touchFocusToggle = makeToggle()

    private var cancellables = Set<AnyCancellable>()
    private let version = "1.3.2"
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindData()
    }

    // MARK: - Setup UI

    override func setupUI() {
        view.backgroundColor = UIColor(white: 0.06, alpha: 1)
        setNavigationTitle("Settings")

        // ScrollView
        scrollView.showsVerticalScrollIndicator = false
        scrollView.changeConstraints()
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
        ])

        // Content stack
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.changeConstraints()
        contentStack.distribution = .fillProportionally
        scrollView.addSubview(contentStack)
        
        let content = scrollView.contentLayoutGuide
        let frame = scrollView.frameLayoutGuide
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: content.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: content.bottomAnchor),
            contentStack.leadingAnchor
                .constraint(equalTo: content.leadingAnchor, constant: 16),
            contentStack.centerXAnchor
                .constraint(equalTo: content.centerXAnchor),
            contentStack.widthAnchor
                .constraint(equalTo: frame.widthAnchor, constant: -32)
        ])

        buildThemeSection()
        buildSoundSection()
        buildHelpSection()
        buildVersionSection()
    }

    override func applyNewTheme(color: UIColor) {
        vibrateToggle.onTintColor = color
        beepToggle.onTintColor = color
        autoFocusToggle.onTintColor = color
        touchFocusToggle.onTintColor = color
    }
    
    // MARK: - Theme Section

    private func buildThemeSection() {
        let card = makeCard()
        let titleLabel = makeSectionTitle("Theme")
        card.addArrangedSubview(titleLabel)
    
        AppThemeColor.allCases.forEach { theme in
            let radio = ThemeRadioView(theme: theme)
            radio.onTap = { [weak self] in
                self?.viewModel.selectedTheme = theme
            }
            card.addArrangedSubview(radio)
            themeRadioViews.append(radio)
        }
    }

    // MARK: - Sound Section

    private func buildSoundSection() {
        let card = makeCard()
        let titleLabel = makeSectionTitle("Sound")
        card.addArrangedSubview(titleLabel)
        
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        card.addArrangedSubview(view)

        let rows: [(String, UISwitch)] = [
            ("Vibrate", vibrateToggle),
            ("Beep", beepToggle),
            ("Auto Focus", autoFocusToggle),
            ("Touch Focus", touchFocusToggle),
        ]

        rows.forEach { title, toggle in
            let row = makeToggleRow(title: title, toggle: toggle)
            card.addArrangedSubview(row)
        }

    }

    // MARK: - Help Section

    private func buildHelpSection() {
        let card = makeCard()
        let title = makeSectionTitle("Help")
        title.applyThemeColor()  // reactive màu theme
        card.addArrangedSubview(title)
        
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        card.addArrangedSubview(view)
        /*
        typealias HelpTuple = (title: String, desc: String?, index: Int)
        
        let rows: [HelpTuple] = [
            (title: "FAQ", desc: nil, 1),
            (title: "Feedback", desc: "Report bugs and tell us what to improve", 2),
            (title: "Rate Us", desc: "Your best reward to us.", 3),
            (title: "Share", desc: "Share app with others", 4),
            (title: "Privacy Policy", desc: nil, 5),
            (title: "Terms of use", desc: nil, 6),
        ]
        
        rows.forEach { (title: String, desc: String?, index: Int) in
            let row = makeHelpRow(title, desc, index)
            card.addArrangedSubview(row)
        }
        */
        HelpSetting.allCases.forEach { item in
            let row = makeHelpRow(item.title, item.description, item.rawValue)
            card.addArrangedSubview(row)
        }
        
    }
    
    //MARK: - Version Section
    
    private func buildVersionSection() {
        let card = makeCard()
        let title = makeSectionTitle("Version \(self.version)")
        card.addArrangedSubview(title)
        
        let view = UIView()
        view.backgroundColor = .clear
        view.changeConstraints()
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        card.addArrangedSubview(view)
    }

    // MARK: - Bind Data

    override func bindData() {
        // Theme selection
        viewModel.$selectedTheme
            .receive(on: RunLoop.main)
            .sink { [weak self] selected in
                self?.themeRadioViews.forEach {
                    $0.setSelected($0.theme == selected)
                }
            }
            .store(in: &cancellables)

        // Toggles
        viewModel.$isVibrate.assign(to: \.isOn, on: vibrateToggle).store(
            in: &cancellables
        )
        viewModel.$isBeep.assign(to: \.isOn, on: beepToggle).store(
            in: &cancellables
        )
        viewModel.$isAutoFocus.assign(to: \.isOn, on: autoFocusToggle).store(
            in: &cancellables
        )
        viewModel.$isTouchFocus.assign(to: \.isOn, on: touchFocusToggle).store(
            in: &cancellables
        )

        // Toggle actions
        vibrateToggle.addAction(
            .init { [weak self] _ in
                self?.viewModel.isVibrate = self?.vibrateToggle.isOn ?? true
            },
            for: .valueChanged
        )
        beepToggle.addAction(
            .init { [weak self] _ in
                self?.viewModel.isBeep = self?.beepToggle.isOn ?? true
            },
            for: .valueChanged
        )
        autoFocusToggle.addAction(
            .init { [weak self] _ in
                self?.viewModel.isAutoFocus = self?.autoFocusToggle.isOn ?? true
            },
            for: .valueChanged
        )
        touchFocusToggle.addAction(
            .init { [weak self] _ in
                self?.viewModel.isTouchFocus =
                    self?.touchFocusToggle.isOn ?? true
            },
            for: .valueChanged
        )
    }

    // MARK: - Builders

    private func makeCard() -> UIStackView {
        let container = UIView()
        container.backgroundColor = .backgroundColor
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        contentStack.addArrangedSubview(container)
        container.changeConstraints()
        container.widthAnchor.constraint(
            equalTo: contentStack.widthAnchor).isActive = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .equalSpacing
        stack.changeConstraints()
        container.addSubview(stack)
                
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 16
            ),
            stack.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 16
            ),
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -4
            ),
        ])

        return stack
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        return label
    }

    private func makeToggle() -> UISwitch {
        let sw = UISwitch()
        sw.onTintColor = ThemeManager.shared.themeColor
        return sw
    }

    private func makeToggleRow(title: String, toggle: UISwitch) -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        toggle.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(toggle)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toggle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 1, alpha: 0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        container.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(
                equalTo: container.trailingAnchor
            ),
            divider.topAnchor.constraint(equalTo: container.topAnchor),
        ])
        
        return container
    }

    private func makeHelpRow(_ title: String, _ desc: String?, _ index: Int) -> UIView {
        
        let onTap = UITapGestureRecognizer(
            target: self,
            action: #selector(onTapHelpRow(_:))
        )
        
        let container = UIView()
        let height: CGFloat = desc == nil ? 48 : 60
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        container.tag = index
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(onTap)

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 1, alpha: 0.1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        container.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            divider.trailingAnchor.constraint(
                equalTo: container.trailingAnchor
            ),
            divider.topAnchor.constraint(equalTo: container.topAnchor),
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        titleLabel.changeConstraints()
        
        container.addSubview(titleLabel)
        
        if desc == nil {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])
        } else {
            let descLabel = UILabel()
            descLabel.text = desc
            descLabel.font = .systemFont(ofSize: 16)
            descLabel.textColor = UIColor(white: 0.85, alpha: 1)
            descLabel.numberOfLines = 1
            descLabel.lineBreakMode = .byTruncatingTail
            descLabel.changeConstraints()
            container.addSubview(descLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.topAnchor
                    .constraint(equalTo: container.topAnchor, constant: 10),
                
                descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                descLabel.trailingAnchor
                    .constraint(lessThanOrEqualTo: container.trailingAnchor),
                descLabel.topAnchor
                    .constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            ])
        }

        return container
        
        /*
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(white: 0.5, alpha: 1)
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.trailingAnchor.constraint(
                equalTo: container.trailingAnchor
            ),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
        ])
        
        return container
         */
    }
    
    @objc private func onTapHelpRow(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else {
            return
        }

        let setting = HelpSetting.allCases[view.tag]
        switch setting {
        case .faq, .feedback:
            let vc = setting == .faq ? FAQViewController() : FeedbackViewController()
            self.push(vc)
            
        case .rateUs:
            view.subviews.forEach { subview in
                
                guard let label = subview as? UILabel,
                      let title = label.text else {
                    return
                }

                if setting.title == title {
                    label.text = "Rate (opened)"
                    return
                }
            }

        case .share:
            Task {
                await self.share(items: [self])
            }
        case .privacyPolicy, .termsOfUse:
            let url = ""
            Task {
                await self.openURL(url)
            }
        }

    }
}

