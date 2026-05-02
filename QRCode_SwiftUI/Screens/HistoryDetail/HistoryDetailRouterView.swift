import SwiftUI

struct HistoryDetailRouterView: View {
    @ObservedObject var entity: QRCodeEntity
    
    var body: some View {
        let type = CreateQREnums(rawValue: entity.qrType ?? "") ?? .text
        
        switch type {
        case .text, .location, .twitter, .instagram, .telephone:
            BasicDetailView(entity: entity)
        case .website:
            Website​Detail​View(entity: entity)
        case .wifi:
            WifiDetail​View(entity: entity)
        case .email:
            EmailDetail​View(entity: entity)
        default:
            // Tương lai sẽ điều hướng sang các View chi tiết phức tạp hơn (VD: WifiDetailView, ContactDetailView)
            // Tạm thời fallback về BasicDetailView
            BasicDetailView(entity: entity)
        }
    }
}
