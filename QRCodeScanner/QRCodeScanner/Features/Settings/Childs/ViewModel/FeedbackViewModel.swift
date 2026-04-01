//
//  FeedbackViewModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 31/3/26.
//

class FeedbackViewModel: BaseViewModel {
    
    private var previousIndex: Int = -1
    
    private(set) var items: [ProblemItem] = [
        ProblemItem(title: "scanning not working"),
        ProblemItem(title:"ads"),
        ProblemItem(title:"need more information affter scanning"),
        ProblemItem(title:"other")
    ]
    
    func toggleItem(at index: Int) {
        guard index < items.count else { return }
        
        if previousIndex == -1 || previousIndex != index {
            previousIndex = index
            for (position, _) in items.enumerated() {
                items[position].setDefaultValue()
            }
            
            items[index].isSelected.toggle()
            return
        }
        
        if previousIndex == index {
            previousIndex = -1
            items[index].isSelected.toggle()
            return
        }

    }
    
}
