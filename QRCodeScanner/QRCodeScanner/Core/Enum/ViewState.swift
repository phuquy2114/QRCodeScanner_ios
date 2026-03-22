//
//  ViewState.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//
// MARK: - ViewState
// Trạng thái chung của một màn hình

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case empty
    case error(String)

    var isLoading: Bool { self == .loading }
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}
