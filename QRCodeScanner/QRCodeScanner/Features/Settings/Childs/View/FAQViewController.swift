//
//  FAQViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 30/3/26.
//

import UIKit

class FAQViewController: BaseViewController {

    private let heightButton: CGFloat = 48
    private let viewModel = FAQViewModel()
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
        buildProblemButton()
        buildListQuestion()
    }

    private func setupNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.setNavigationTitle(
            "FAQ",
            font: .boldSystemFont(ofSize: 24),
            color: .white
        )
    }

    private func buildProblemButton() {
        let button = UIButton()
        button.applyAccentBackground()
        button.backgroundColor = ThemeManager.shared.themeColor
        button.layer.cornerRadius = 6
        button.setTitleColor(.black, for: .normal)
        button.setTitle("STILL HAVE PROBLEMS", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.addAction(
            .init { [weak self] _ in
                self?.push(FeedbackViewController())
            },
            for: .touchUpInside
        )
        button.changeConstraints()
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            button.heightAnchor.constraint(equalToConstant: heightButton),
            button.widthAnchor
                .constraint(lessThanOrEqualTo: view.widthAnchor),
        ])
    }

    private func buildListQuestion() {
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            FAQItemCell.self,
            forCellReuseIdentifier: FAQItemCell.identifier
        )
        tableView.changeConstraints()
        view.addSubview(tableView)

        NSLayoutConstraint.activate(
            [
                tableView.topAnchor
                    .constraint(
                        equalTo: view.safeAreaLayoutGuide.topAnchor,
                        constant: self.heightButton + 32
                    ),
                tableView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                tableView.bottomAnchor
                    .constraint(
                        equalTo: view.safeAreaLayoutGuide
                            .bottomAnchor,
                        constant: -20
                    ),
            ]
        )

    }
}

// MARK: - UITableViewDataSource

extension FAQViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        viewModel.items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FAQItemCell.identifier,
                for: indexPath
            ) as? FAQItemCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.items[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FAQViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        haptic(.light)

        let wasExpanded = viewModel.items[indexPath.row].isExpanded
        viewModel.toggleItem(at: indexPath.row)

        tableView.performBatchUpdates {
            tableView.reloadRows(
                at: [indexPath],
                with: wasExpanded ? .fade : .fade
            )
        }
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 64
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat { .leastNormalMagnitude }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? { UIView() }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? { UIView() }

}
