import SwiftUI

struct BasicDetailView: View {
    @ObservedObject var entity: QRCodeEntity

    var body: some View {
        // Gọi Layout dùng chung, truyền entity và title vào
        BaseLayoutDetailView(
            entity: entity,
            title: entity.rawContent ?? ""
        ) {

        }
    }
}
