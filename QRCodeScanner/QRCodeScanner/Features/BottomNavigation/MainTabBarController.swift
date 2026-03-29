//
//  MainTabBarController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 22/3/26.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let tabBarHeight: CGFloat = 70
    private let tabBarMargin: CGFloat = 16  // khoảng cách 2 bên so với màn hình
    private let tabBarBottom: CGFloat = 8  // khoảng cách so với safe area bottom
    private let animationDuration: TimeInterval = 0.28
    private let tabBarBg = UIColor(white: 0.13, alpha: 1)  // dark charcoal

    private let customTabBar = UIView()
    private let selectionPill = UIView()
    private var tabItems: [TabItemView] = []
    private var themeObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true  // ẩn UITabBar mặc định
        setupViewControllers()
        setupCustomTabBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTabBar()
    }

    private func setupViewControllers() {
        let vcs: [UIViewController] = AppTab.allCases.map { tab in
            let vc = placeholderVC(for: tab)
            let navigation = UINavigationController(rootViewController: vc)
            navigation.setNavigationBarHidden(true, animated: true)
            return navigation
        }
        setViewControllers(vcs, animated: false)
    }

    private func placeholderVC(for tab: AppTab) -> UIViewController {
        // backgroundColor = UIColor(white: 0.08, alpha: 1)
        return tab.viewController()
    }

    private func setupCustomTabBar() {
        // Outer pill (dark background)
        customTabBar.backgroundColor = self.tabBarBg
        customTabBar.layer.cornerRadius = 35
        customTabBar.clipsToBounds = false
        customTabBar.layer.shadowColor = UIColor.black.cgColor
        customTabBar.layer.shadowOpacity = 0.35
        customTabBar.layer.shadowRadius = 16
        customTabBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        customTabBar.layer.borderWidth = 1
        customTabBar.layer.borderColor = ThemeManager.shared.themeColor.cgColor
        view.addSubview(customTabBar)
        
        self.additionalSafeAreaInsets.bottom = self.tabBarHeight + self.tabBarBottom

        // Selection pill (inside)
        selectionPill.clipsToBounds = true
        selectionPill.layer.cornerRadius = 26
        customTabBar.addSubview(selectionPill)

        // Tab items
        AppTab.allCases.forEach { tab in
            let item = TabItemView(tab: tab)
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(tabTapped(_:))
                )
            )
            item.tag = tab.rawValue
            customTabBar.addSubview(item)
            tabItems.append(item)
        }

        selectTab(index: 0, animated: false)
        observeThemeChanges()
    }

    // MARK: - Theme

    private func observeThemeChanges() {
        themeObserver = NotificationCenter.default.addObserver(
            forName: .themeDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                let newColor = notification.object as? UIColor
            else { return }
            self.applyTheme(newColor)
        }
    }
    
    

    private func applyTheme(_ color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.tabItems.enumerated().forEach { idx, item in
                item.updateTheme(
                    color: color,
                    isSelected: idx == self.selectedIndex
                )
            }
        }
    }

    private func layoutTabBar() {
        let safeBottom = view.window?.safeAreaInsets.bottom ?? 0
        let width = view.bounds.width - self.tabBarMargin * 2
        let height = self.tabBarHeight
        let y = view.bounds.height - safeBottom - height - self.tabBarBottom

        customTabBar.frame = CGRect(
            x: self.tabBarMargin,
            y: y,
            width: width,
            height: height
        )

        // Tab items equally spaced
        let itemWidth = width / CGFloat(AppTab.allCases.count)
        tabItems.enumerated().forEach { idx, item in
            item.frame = CGRect(
                x: CGFloat(idx) * itemWidth,
                y: 0,
                width: itemWidth,
                height: height
            )
        }

        // Reposition selection pill without animation during layout
        updateSelectionPill(index: selectedIndex, animated: false)
    }

    // MARK: - Selection

    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        selectTab(index: tag, animated: true)
    }

    private func selectTab(index: Int, animated: Bool) {
        guard index != selectedIndex || !animated else {
            // same tab tapped — bounce animation
            bounceItem(at: index)
            return
        }

        let previousIndex = selectedIndex
        selectedIndex = index
        selectedViewController = viewControllers?[index]

        updateSelectionPill(index: index, animated: animated)
        updateTabAppearance(from: previousIndex, to: index, animated: animated)

        // Haptic
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func updateSelectionPill(index: Int, animated: Bool) {
        let itemWidth =
            customTabBar.bounds.width / CGFloat(AppTab.allCases.count)
        let pillW: CGFloat = itemWidth - 8
        let pillH: CGFloat = self.tabBarHeight - 12
        let pillX = CGFloat(index) * itemWidth + 4
        let pillY: CGFloat = 6
        let targetFrame = CGRect(
            x: pillX,
            y: pillY,
            width: pillW,
            height: pillH
        )

        if animated {
            UIView.animate(
                withDuration: self.animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.72,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut
            ) {
                self.selectionPill.frame = targetFrame
            }
        } else {
            selectionPill.frame = targetFrame
        }
    }

    private func updateTabAppearance(from: Int, to: Int, animated: Bool) {
        let duration = animated ? self.animationDuration : 0
        UIView.animate(withDuration: duration) {
            self.tabItems[from].setSelected(false)
            self.tabItems[to].setSelected(true)
        }
    }

    private func bounceItem(at index: Int) {
        let item = tabItems[index]
        UIView.animate(
            withDuration: 0.12,
            animations: {
                item.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    usingSpringWithDamping: 0.5,
                    initialSpringVelocity: 0.8,
                    options: []
                ) {
                    item.transform = .identity
                }
            }
        )
    }

}
