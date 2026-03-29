//
//  AppUtils.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 19/3/26.
//

import Foundation

open class AppUtils {

    static func onMain(_ work: @escaping @MainActor () -> Void) {
        Task {
            await MainActor.run {
                work()
            }
        }
    }

    /// Chạy task nặng ở background, kết quả tự động trả về @MainActor
    /// Ví dụ: let result = try await runInBackground { try parseJSON(data) }
    static func runInBackground<T: Sendable>(
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
    static func delay(seconds: TimeInterval) async {
        try? await Task.sleep(for: .seconds(seconds))
    }

    static func parallel(_ tasks: [() async -> Void]) async {
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask { await task() }
            }
        }
    }
}
