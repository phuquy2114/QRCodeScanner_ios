//
//  BaseViewController.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//  Requires iOS 15+, Swift 5.7+
//

import AVFoundation
import UIKit

// MARK: - BaseViewController
// @MainActor đảm bảo mọi UI update đều chạy trên Main Thread tự động

@MainActor
open class BaseViewController: UIViewController {

    // MARK: - Properties

    /// Loading overlay view
    private lazy var loadingOverlay: UIView = {
        let view = UIView(frame: UIScreen.current.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
        return view
    }()

    /// Toast label
    private var toastLabel: UILabel?

    /// Track keyboard height
    private(set) var keyboardHeight: CGFloat = 0

    /// Lưu Task keyboard để cancel khi view disappear
    private var keyboardTask: Task<Void, Never>?
    
    /// Lưu Task system (Theme, Language) để cancel khi deinit
    private var systemObserversTask: Task<Void, Never>?

    /// Safe area insets helper
    var safeTop: CGFloat { view.safeAreaInsets.top }
    var safeBottom: CGFloat { view.safeAreaInsets.bottom }
    var safeLeft: CGFloat { view.safeAreaInsets.left }
    var safeRight: CGFloat { view.safeAreaInsets.right }

    // MARK: - Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupBase()

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObserving()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopKeyboardObserving()
    }

    deinit {
        keyboardTask?.cancel()
        systemObserversTask?.cancel()
        print("✅ Deinit: \(String(describing: type(of: self)))")
    }

    // MARK: - Setup Base

    private func setupBase() {
        if let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let window = windowScene.windows.first
        {
            window.addSubview(loadingOverlay)
        }
        // Cài đặt text lần đầu tiên
        setupLocalizedTexts()

        // Lắng nghe sự kiện hệ thống (Theme, Language) bằng AsyncSequence
        startSystemObservers()
    }

    private func startSystemObservers() {
        systemObserversTask = Task { [weak self] in
            guard let self else { return }
            await withTaskGroup(of: Void.self) { group in
                
                // 1. Lắng nghe đổi ngôn ngữ
                group.addTask { [weak self] in
                    guard let self else { return }
                    for await _ in await NotificationCenter.default
                        .notifications(named: .languageDidChange) {
                        guard !Task.isCancelled else { break }
                        await self.handleLanguageChanged()
                    }
                }
                
                // 2. Lắng nghe đổi theme
                group.addTask { [weak self] in
                    guard let self else { return }
                    for await noti in await NotificationCenter.default
                        .notifications(named: .themeDidChange) {
                        guard !Task.isCancelled else { break }
                        await self.handleThemeChanged(noti: noti)
                    }
                }
            }
        }
    }

    private func handleLanguageChanged() {
        // Hàm này sẽ tự động chạy trên TẤT CẢ các màn hình đang sống khi user đổi ngôn ngữ
        setupLocalizedTexts()
    }
    
    private func handleThemeChanged(noti: Notification) {
        // Hàm này sẽ tự động chạy trên TẤT CẢ các màn hình đang sống khi user đổi theme
        guard let color = noti.object as? UIColor else { return }
        self.applyNewTheme(color: color)
    }

    // MARK: - Override Points

    open func setupUI() {}
    open func bindData() {}
    open func setupActions() {}

    /// Class con (HomeVC, SettingsVC...) sẽ override hàm này để gán text cho UI
    open func setupLocalizedTexts() {
        // Ví dụ: title = "screen_title".localized
    }
    
    open func applyNewTheme(color: UIColor) {
        
    }
    
    open func setBackgroundColor(color: UIColor? = nil) {
        view.backgroundColor = color ?? .backgroundColor
    }
}

// MARK: - Navigation Helpers

extension BaseViewController {

    func push(_ vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }

    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }

    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }

    /// Present modal — await đến khi present animation xong
    func presentModal(
        _ vc: UIViewController,
        style: UIModalPresentationStyle = .automatic,
        animated: Bool = true
    ) async {
        vc.modalPresentationStyle = style
        await withCheckedContinuation { continuation in
            present(vc, animated: animated) {
                continuation.resume()
            }
        }
    }

    /// Dismiss modal — await đến khi dismiss animation xong
    func dismissModal(animated: Bool = true) async {
        await withCheckedContinuation { continuation in
            dismiss(animated: animated) {
                continuation.resume()
            }
        }
    }

    func setBackButtonTitle(_ title: String = "") {
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: nil,
            action: nil
        )
    }

    func hideNavigationBar(_ hidden: Bool = true, animated: Bool = true) {
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
}

// MARK: - Loading Indicator

extension BaseViewController {

    /// Show loading với fade-in — await đến khi animation xong
    func showLoading() async {
        loadingOverlay.isHidden = false
        loadingOverlay.alpha = 0
        await animate(duration: 0.25) {
            self.loadingOverlay.alpha = 1
        }
    }

    /// Hide loading với fade-out — await đến khi animation xong
    func hideLoading() async {
        await animate(duration: 0.25) {
            self.loadingOverlay.alpha = 0
        }
        loadingOverlay.isHidden = true
    }

    /// Wrapper UIView.animate → async/await
    func animate(
        duration: TimeInterval,
        options: UIView.AnimationOptions = .curveEaseInOut,
        animations: @escaping () -> Void
    ) async {
        await withCheckedContinuation { continuation in
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: options,
                animations: animations
            ) { _ in
                continuation.resume()
            }
        }
    }
}

// MARK: - Alert & Toast

extension BaseViewController {

    /// Show simple alert — await đến khi user bấm OK
    func showAlert(
        title: String? = nil,
        message: String,
        okTitle: String = "OK"
    ) async {
        await withCheckedContinuation { continuation in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: okTitle, style: .default) { _ in
                    continuation.resume()
                }
            )
            present(alert, animated: true)
        }
    }

    /// Show confirm alert — trả về true nếu Confirm, false nếu Cancel
    func showConfirmAlert(
        title: String? = nil,
        message: String,
        confirmTitle: String? = nil,
        cancelTitle: String? = nil,
        confirmStyle: UIAlertAction.Style = .default
    ) async -> Bool {

        let finalConfirm = confirmTitle ?? "confirm_button".localized
        let finalCancel = cancelTitle ?? "cancel_button".localized

        return await withCheckedContinuation { continuation in
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: finalCancel, style: .cancel) { _ in
                    continuation.resume(returning: false)
                }
            )
            alert.addAction(
                UIAlertAction(title: finalConfirm, style: confirmStyle) { _ in
                    continuation.resume(returning: true)
                }
            )
            present(alert, animated: true)
        }
    }

    /// Show action sheet — trả về index được chọn, nil nếu Cancel
    func showActionSheet(
        title: String? = nil,
        message: String? = nil,
        actions: [(title: String, style: UIAlertAction.Style)],
        cancelTitle: String? = nil
    ) async -> Int? {
        let finalCancelTitle = cancelTitle ?? "cancel_button".localized

        return await withCheckedContinuation { continuation in
            let sheet = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .actionSheet
            )
            for (index, action) in actions.enumerated() {
                sheet.addAction(
                    UIAlertAction(title: action.title, style: action.style) {
                        _ in
                        continuation.resume(returning: index)
                    }
                )
            }
            sheet.addAction(
                UIAlertAction(title: finalCancelTitle, style: .cancel) { _ in
                    continuation.resume(returning: nil)
                }
            )
            if let popover = sheet.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
            present(sheet, animated: true)
        }
    }

    /// Show error alert
    func showError(_ error: Error, title: String? = nil) async {
        let newTitle = title ?? "error_title".localized
        await showAlert(title: newTitle, message: error.localizedDescription)
    }

    /// Show toast — await đến khi toast biến mất hoàn toàn
    func showToast(
        _ message: String,
        duration: TimeInterval = 2.5,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.75)
    ) async {
        toastLabel?.removeFromSuperview()

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true

        let maxWidth = view.bounds.width - 60
        let size = label.sizeThatFits(
            CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        )
        let padding: CGFloat = 14
        label.frame = CGRect(
            x: (view.bounds.width - size.width - padding * 2) / 2,
            y: view.bounds.height - safeBottom - 100,
            width: size.width + padding * 2,
            height: size.height + padding
        )
        label.alpha = 0
        view.addSubview(label)
        toastLabel = label

        await animate(duration: 0.3) { label.alpha = 1 }
        try? await Task.sleep(for: .seconds(duration))
        await animate(duration: 0.4) { label.alpha = 0 }
        label.removeFromSuperview()
    }

    /// Fire-and-forget toast (không cần await ở call site)
    func showToastAsync(_ message: String, duration: TimeInterval = 2.5) {
        Task { await showToast(message, duration: duration) }
    }
}

// MARK: - Camera & QR Permissions

extension BaseViewController {

    /// Request camera permission — trả về true/false (async)
    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        case .denied, .restricted:
            await showCameraPermissionDeniedAlert()
            return false
        @unknown default:
            return false
        }
    }

    /// Alert hướng dẫn Settings khi camera bị từ chối
    func showCameraPermissionDeniedAlert() async {
        let confirmed = await showConfirmAlert(
            title: "camera_permission_denied".localized,
            message:
                "content_message_requesting_camera_access".localized,
            confirmTitle: "open_settings".localized,
            cancelTitle: "cancel_button".localized
        )
        if confirmed, let url = URL(string: UIApplication.openSettingsURLString)
        {
            await UIApplication.shared.open(url)
        }
    }
}

// MARK: - Keyboard Handling (AsyncSequence)

extension BaseViewController {

    /// Override ở subclass để xử lý khi bàn phím xuất hiện
    public func keyboardWillShow(height: CGFloat, duration: TimeInterval) {}

    /// Override ở subclass để xử lý khi bàn phím ẩn
    public func keyboardWillHide(duration: TimeInterval) {}

    /// Dùng NotificationCenter async sequence thay vì addObserver/selector
    private func startKeyboardObserving() {
        keyboardTask = Task { [weak self] in
            guard let self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { [weak self] in
                    guard let self else { return }
                    for await notification in NotificationCenter.default
                        .notifications(
                            named: UIResponder.keyboardWillShowNotification
                        )
                    {
                        guard !Task.isCancelled else { break }
                        await self.handleKeyboardShow(notification)
                    }
                }
                group.addTask { [weak self] in
                    guard let self else { return }
                    for await notification in NotificationCenter.default
                        .notifications(
                            named: UIResponder.keyboardWillHideNotification
                        )
                    {
                        guard !Task.isCancelled else { break }
                        await self.handleKeyboardHide(notification)
                    }
                }
            }
        }
    }

    private func stopKeyboardObserving() {
        keyboardTask?.cancel()
        keyboardTask = nil
    }

    private func handleKeyboardShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect,
            let duration = userInfo[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? TimeInterval
        else { return }
        keyboardHeight = frame.height
        keyboardWillShow(height: frame.height, duration: duration)
    }

    private func handleKeyboardHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[
                UIResponder.keyboardAnimationDurationUserInfoKey
            ] as? TimeInterval
        else { return }
        keyboardHeight = 0
        keyboardWillHide(duration: duration)
    }

    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UI Utilities

extension BaseViewController {

    func addChild(_ child: UIViewController, to containerView: UIView) {
        addChild(child)
        child.view.frame = containerView.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func removeChildViewController(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    func setNavigationTitle(
        _ title: String,
        font: UIFont = .boldSystemFont(ofSize: 17),
        color: UIColor = .label
    ) {
        navigationItem.title = title
        navigationController?.navigationBar.titleTextAttributes = [
            .font: font,
            .foregroundColor: color,
        ]
    }

    func addRightBarButton(
        title: String? = nil,
        image: UIImage? = nil,
        action: Selector
    ) {
        let btn: UIBarButtonItem =
            image != nil
            ? UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: action
            )
            : UIBarButtonItem(
                title: title,
                style: .plain,
                target: self,
                action: action
            )
        navigationItem.rightBarButtonItem = btn
    }

    func addLeftBarButton(
        title: String? = nil,
        image: UIImage? = nil,
        action: Selector
    ) {
        let btn: UIBarButtonItem =
            image != nil
            ? UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: action
            )
            : UIBarButtonItem(
                title: title,
                style: .plain,
                target: self,
                action: action
            )
        navigationItem.leftBarButtonItem = btn
    }
}

// MARK: - Device & Status Bar

extension BaseViewController {

    var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    var screenWidth: CGFloat { UIScreen.current.bounds.width }
    var screenHeight: CGFloat { UIScreen.current.bounds.height }

    public override var preferredStatusBarStyle: UIStatusBarStyle { .default }

    var isSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }
}

// MARK: - Haptic Feedback

extension BaseViewController {

    enum HapticType {
        case light, medium, heavy, success, warning, error, selection
    }

    func haptic(_ type: HapticType) {
        switch type {
        case .light: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy: UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .selection: UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Clipboard & Share

extension BaseViewController {

    func copyToClipboard(_ text: String, toastMessage: String? = nil) {
        let newToastMessage = toastMessage ?? "copied".localized
        UIPasteboard.general.string = text
        haptic(.light)
        showToastAsync(newToastMessage)
    }

    /// Share — await đến khi share sheet đóng
    func share(items: [Any]) async {
        await withCheckedContinuation { continuation in
            let activity = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            activity.completionWithItemsHandler = { _, _, _, _ in
                continuation.resume()
            }
            if let popover = activity.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
            }
            present(activity, animated: true)
        }
    }

    /// Open URL (async)
    func openURL(_ urlString: String) async {
        guard let url = URL(string: urlString) else {
            await showAlert(
                title: "error_title".localized,
                message: "invalid_URL".localized
            )
            return
        }

        await UIApplication.shared.open(url)
    }
}

// MARK: - Concurrency Helpers

extension BaseViewController {

//    @MainActor
//    func onMain(_ block: @escaping () -> Void) {
//        block()
//    }
    
    func onMain(_ work: @escaping @MainActor () -> Void) {
        Task {
            await MainActor.run {
                work()
            }
        }
    }

    /// Chạy task nặng ở background, kết quả tự động trả về @MainActor
    /// Ví dụ: let result = try await runInBackground { try parseJSON(data) }
    func runInBackground<T: Sendable>(
        _ priority: TaskPriority = .userInitiated,
        _ work: @Sendable @escaping () throws -> T
    ) async throws -> T {
        try await Task.detached(priority: priority) {
            try work()
        }.value
    }

    // Chạy task nặng ở background, không cần trả về kiểu dữ liệu, hàm Void
    static func onBackground(
        priority: TaskPriority = .userInitiated,
        operation: @Sendable @escaping () async -> Void
    ) {
        Task.detached(priority: priority) {
            await operation()
        }
    }

    /// Delay — thay thế asyncAfter
    /// Ví dụ: await sleep(seconds: 1.5)
    func delay(seconds: TimeInterval) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    /// Chạy nhiều async tasks song song, chờ tất cả xong
    /// Ví dụ: await parallel({ await loadUser() }, { await loadConfig() })
    func parallel(_ tasks: [() async -> Void]) async {
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask { await task() }
            }
        }
    }
}
