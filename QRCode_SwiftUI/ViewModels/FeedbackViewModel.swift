//
//  FeedbackViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 9/4/26.
//

import Combine
import SwiftUI

@MainActor
class FeedbackViewModel: BaseViewModel {
    let maxImages = 3
    let maxDescriptionLength = 500

    @Published var attachFiles: [UIImage] = []
    @Published var problemItems = [
        ProblemItem(title: "scan not working", isSelected: false),
        ProblemItem(title: "ads", isSelected: false),
        ProblemItem(
            title: "need more information after scanning",
            isSelected: false
        ),
        ProblemItem(title: "other", isSelected: false),
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
                return !title.trimmingCharacters(in: .whitespaces).isEmpty
                    && !description.trimmingCharacters(in: .whitespaces).isEmpty
            }
            .receive(on: RunLoop.main)
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }

    func onTapItemProblem(index: Int) {
        typeProblem = problemItems[index].title

        for position in problemItems.indices {
            problemItems[position].isSelected = position == index
        }
    }

    func submitFeedback() {
        let _ = FeedbackRequest(
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
