//
//  FeedbackViewModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//

import Combine
import Foundation
import UIKit
import Alamofire

@MainActor
final class FeedbackViewModel: BaseViewModel {
    
    // MARK: - Input fields
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var attachFiles: [UIImage] = []

    // MARK: - Upload progress (0.0 → 1.0)
    @Published private(set) var uploadProgress: Double = 0

    // MARK: - Validation errors
    @Published private(set) var titleError: String?
    @Published private(set) var descriptionError: String?

    // MARK: - Constants
    let maxImages = 3
    let maxDescriptionLength = 500

    // MARK: - Service
    private let service = FeedbackService()
    private var cancellables = Set<AnyCancellable>()
    
    private var index: Int = -1
    
    private(set) var items: [ProblemItem] = [
        ProblemItem(title: "scanning not working"),
        ProblemItem(title: "ads"),
        ProblemItem(title: "need more information affter scanning"),
        ProblemItem(title: "other")
    ]
    
    var canAddMoreImages: Bool { attachFiles.count < maxImages }
    
    // MARK: - Submit
    var isFormValid: Bool {
        let a1 = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let a2 = !description.trimmingCharacters(in: .whitespaces).isEmpty
        let a3 = titleError == nil
        let a4 = descriptionError == nil
        let a5: String = title
        let a6: String  = description
        
        
        print("titleError \(title == "" ? 1 : 2)")
        print("titleError \(description == "" ? 1 : 2)")
        return !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        titleError == nil && descriptionError == nil
    }
    
    override init() {
        super.init()
        setupValidation()
    }
    
    // MARK: - Realtime Validation
    private func setupValidation() {
        $title
            .dropFirst()
            .map { title -> String? in
                if title.trimmingCharacters(in: .whitespaces).isEmpty {
                    return "The problem type cannot be left blank."
                }
                return nil
            }
            .assign(to: &$titleError)
        
        $description
            .dropFirst()
            .map { desc -> String? in
                if desc.trimmingCharacters(in: .whitespaces).isEmpty {
                    return "The description cannot be left blank."
                }
                if desc.count > self.maxDescriptionLength {
                    return "Description (maximum \(self.maxDescriptionLength) characters)"
                }
                return nil
            }
            .assign(to: &$descriptionError)
    }

    func toggleItem(at index: Int) {
        guard index < items.count else { return }
        
        if self.index == -1 || self.index != index {
            self.index = index
            
            for (position, _) in items.enumerated() {
                items[position].setDefaultValue()
            }
            items[index].isSelected.toggle()
            title = items[index].title
            print("titleError1 \(title == "" ? 1 : 2)")
            let b = self.title
            return
        }
        
        if self.index == index {
            self.index = -1
            items[index].isSelected.toggle()
            title = ""
            return
        }
    }
    
    func addImage(_ image: UIImage) {
        guard attachFiles.count < maxImages else { return }
        attachFiles.append(image)
    }

    func removeImage(at index: Int) {
        guard index < attachFiles.count else { return }
        attachFiles.remove(at: index)
    }
    
    func submitFeedback() {
        guard validate([
            .nonEmpty(title, fieldName: "Type of problem"),
            .nonEmpty(description, fieldName: "Describe"),
            .maxLength(description, max: maxDescriptionLength, fieldName: "Describe")
        ]) else { return }

        let request = FeedbackRequest(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            attachFiles: attachFiles,
            time: Date.now
        )
        
        perform(key: "submit") {
            // Service tự quyết JSON hay multipart, ViewModel chỉ nhận progress
            let response = try await self.service.submit(request) {
                [weak self] progress in
                Task { @MainActor in self?.uploadProgress = progress }
            }
            let _ = response
            self.setSuccess("Feedback submitted successfully!")
            self.resetForm()
        }
    }
    
    // MARK: - Reset
    private func resetForm() {
        title = ""
        description = ""
        attachFiles = []
        uploadProgress = 0
    }
}
