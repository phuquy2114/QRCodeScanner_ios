//
//  FeedbackViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 9/4/26.
//

import Combine
import SwiftUI

class FeedbackViewModel: BaseViewModel {
    let maxImages = 3
    let maxDescriptionLength = 500

    @Published var attachFiles: [Image] = []
    @Published var problemItems = [
        ("scan not working", false),
        ("ads", false),
        ("need more information affter scanning", false),
        ("other", false),
    ]
    @Published var typeProblem: String = ""
    @Published var description: String = ""
    @Published var isFormValid: Bool = false

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        Publishers.CombineLatest($typeProblem, $description)
            .dropFirst()
            .map { title, description in
                return !title.trimmingCharacters(in: .whitespaces).isEmpty && !description.trimmingCharacters(in: .whitespaces).isEmpty
            }
            .receive(on: RunLoop.main)
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }

    func onTapItemProblem(index: Int) {
        typeProblem = problemItems[index].0

        for position in problemItems.indices {
            problemItems[position].1 = position == index
        }
    }

    func submitFeedback() {
        let request = FeedbackRequest(
            typeProblem: typeProblem.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            attachFiles: attachFiles,
            time: Date.now
        )
        
//        Task {
//            await run {
//                let result: FeedbackResponse = try await NetworkService.shared
//                    .upload(FeedbackEndpoint.submitFeedback, items: attachFiles)
//                
//            }
//
//        }

    }

}
