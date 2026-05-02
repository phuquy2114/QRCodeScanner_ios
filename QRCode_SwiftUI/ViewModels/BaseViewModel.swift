import Combine
//
//  BaseViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//
import SwiftUI
import UIKit

@MainActor
class BaseViewModel: ObservableObject {

    // MARK: - Common state
    @Published var isLoading = false
    @Published var currentError: AppError?
    @Published var showError = false

    // MARK: - Lifecycle (override ở subclass)
    func onAppear() {}
    func onDisappear() {}

    // MARK: - Error handling
    func presentError(_ error: AppError) {
        currentError = error
        showError = true
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func dismissError() {
        currentError = nil
        showError = false
    }

    // MARK: - Loading
    /// Bọc một async task, tự set isLoading và bắt lỗi
    func run(_ task: () async throws -> Void) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await task()
        } catch let error as AppError {
            presentError(error)
        } catch {
            presentError(.unknown(error.localizedDescription))
        }
    }
}

// MARK: - Validation Helpers
extension BaseViewModel {
    /// Validate và trả về lỗi nếu có
    @discardableResult
    func validate(_ rules: [ValidationRule]) -> Bool {
        for rule in rules {
            if let error = rule.validate() {
                presentError(error)
                return false
            }
        }
        return true
    }
}
