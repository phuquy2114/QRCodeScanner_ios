//
//  BaseViewModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//  Swift Concurrency — iOS 15+, Swift 5.7+
//

import Combine
import Foundation

// MARK: - BaseViewModel

@MainActor
open class BaseViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var state: ViewState = .idle
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var successMessage: String? = nil

    // MARK: - Task Management
    // Lưu các task đang chạy để cancel khi cần

    private var activeTasks: [String: Task<Void, Never>] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init / Deinit

    public init() {
        setupBindings()
    }

    deinit {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        print("✅ Deinit: \(String(describing: type(of: self)))")
    }

    // MARK: - Override Points

    /// Override để setup bindings giữa các @Published
    open func setupBindings() {}

    /// Override để load data lần đầu
    open func onAppear() async {}

    /// Override để cleanup khi view disappear
    open func onDisappear() {}
}

// MARK: - State Management

extension BaseViewModel {

    /// Cập nhật state chính
    func setState(_ newState: ViewState) {
        state = newState
        isLoading = newState.isLoading
        if case .error(let msg) = newState {
            errorMessage = msg
        } else {
            errorMessage = nil
        }
    }

    /// Reset về idle
    func resetState() {
        setState(.idle)
        successMessage = nil
    }

    /// Set success message (tự clear sau `autoClearAfter` giây)
    func setSuccess(
        _ message: String? = nil,
        autoClearAfter seconds: TimeInterval = 3
    ) {
        setState(.success)
        successMessage = message
        guard seconds > 0, message != nil else { return }
        Task {
            try? await Task.sleep(for: .seconds(seconds))
            successMessage = nil
        }
    }

    /// Set error từ Error type
    func setError(_ error: Error) {
        setState(.error(error.localizedDescription))
    }

    /// Set error từ String
    func setError(_ message: String) {
        setState(.error(message))
    }
}

// MARK: - Task Management

extension BaseViewModel {

    /// Chạy một async task có tên, tự quản lý loading state
    /// - Parameters:
    ///   - key: Định danh task (dùng để cancel riêng lẻ nếu cần)
    ///   - showLoading: Có set state = .loading không
    ///   - silently: Nếu true, lỗi sẽ không update state
    ///   - task: Công việc cần thực hiện
    func perform(
        key: String = "default",
        showLoading: Bool = true,
        silently: Bool = false,
        task: @escaping () async throws -> Void
    ) {
        cancelTask(key: key)

        activeTasks[key] = Task { [weak self] in
            guard let self else { return }

            if showLoading { self.setState(.loading) }

            do {
                try await task()
                self.activeTasks.removeValue(forKey: key)
            } catch is CancellationError {
                // Task bị cancel — không update state
                self.activeTasks.removeValue(forKey: key)
            } catch {
                self.activeTasks.removeValue(forKey: key)
                if !silently { self.setError(error) }
            }
        }
    }

    /// Chạy task và trả về giá trị (dùng khi cần kết quả)
    func performAndReturn<T: Sendable>(
        showLoading: Bool = true,
        task: @escaping () async throws -> T
    ) async throws -> T {
        if showLoading { setState(.loading) }
        do {
            let result = try await task()
            return result
        } catch {
            setError(error)
            throw error
        }
    }

    /// Cancel một task cụ thể theo key
    func cancelTask(key: String) {
        activeTasks[key]?.cancel()
        activeTasks.removeValue(forKey: key)
    }

    /// Cancel tất cả tasks đang chạy
    func cancelAllTasks() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }

    /// Số lượng tasks đang chạy
    var activeTaskCount: Int { activeTasks.count }
}

// MARK: - Pagination Support

extension BaseViewModel {

    /// Helper để quản lý phân trang
    class PaginationState<T: Sendable> {
        private(set) var items: [T] = []
        private(set) var currentPage: Int = 1
        private(set) var hasMore: Bool = true
        private(set) var isLoadingMore: Bool = false
        let pageSize: Int

        init(pageSize: Int = 20) {
            self.pageSize = pageSize
        }

        func append(_ newItems: [T]) {
            items.append(contentsOf: newItems)
            hasMore = newItems.count >= pageSize
            currentPage += 1
        }

        func reset() {
            items = []
            currentPage = 1
            hasMore = true
            isLoadingMore = false
        }

        func setLoadingMore(_ loading: Bool) {
            isLoadingMore = loading
        }
    }
}

// MARK: - Debounce / Throttle

extension BaseViewModel {

    /// Debounce một action (ví dụ: search)
    /// Ví dụ: debounce(key: "search", delay: 0.4) { await self.search(query) }
    func debounce(
        key: String = "debounce",
        delay: TimeInterval = 0.5,
        action: @escaping () async -> Void
    ) {
        cancelTask(key: key)
        activeTasks[key] = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
            await action()
            activeTasks.removeValue(forKey: key)
        }
    }
}

// MARK: - Combine Bridge

extension BaseViewModel {

    /// Lắng nghe @Published từ ViewModel khác và map sang async
    /// Ví dụ: observe($otherVM.state) { state in ... }
    func observe<T>(
        _ publisher: Published<T>.Publisher,
        handler: @escaping (T) -> Void
    ) {
        publisher
            .receive(on: RunLoop.main)
            .sink { handler($0) }
            .store(in: &cancellables)
    }

    /// Lưu AnyCancellable vào bag của ViewModel
    func store(_ cancellable: AnyCancellable) {
        cancellable.store(in: &cancellables)
    }
}

// MARK: - Validation Helpers

extension BaseViewModel {

    /// Validate và trả về lỗi nếu có
    @discardableResult
    func validate(_ rules: [ValidationRule]) -> Bool {
        for rule in rules {
            if let error = rule.validate() {
                setError(error)
                return false
            }
        }
        return true
    }
}

// MARK: - ValidationRule

public struct ValidationRule {
    let validate: () -> String?

    /// Field không được rỗng
    static func nonEmpty(_ value: String, fieldName: String) -> ValidationRule {
        ValidationRule {
            value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "\(fieldName) \("It_cannot_be_left_blank".localized)" : nil
        }
    }

    /// Độ dài tối thiểu
    static func minLength(_ value: String, min: Int, fieldName: String)
        -> ValidationRule
    {
        ValidationRule {
            value.count < min
                ? "\(fieldName) \("It_must_have_at_least".localized) \(min) \("characters".localized)"
                : nil
        }
    }

    /// Email format
    static func email(_ value: String) -> ValidationRule {
        ValidationRule {
            let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            return value.range(of: regex, options: .regularExpression) == nil
                ? "Invalid_email".localized : nil
        }
    }

    /// Custom rule
    static func custom(condition: Bool, message: String) -> ValidationRule {
        ValidationRule { condition ? message : nil }
    }
}
