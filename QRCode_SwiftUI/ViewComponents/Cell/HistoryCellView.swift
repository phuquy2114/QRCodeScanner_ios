import SwiftUI

struct HistoryCellView: View {
    @EnvironmentObject var theme: ThemeManager
    @ObservedObject var entity: QRCodeEntity

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            let qrType = entity.qrType ?? ""
            let qrEnum = CreateQREnums(rawValue: qrType) ?? .text

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.accent, lineWidth: 1)
                    .frame(width: 60, height: 60)

                qrEnum.icon()?
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(theme.accent)
            }
            .overlay(alignment: .top) {
                Text(qrEnum.title())
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4).fill(theme.accent)
                    )
                    .frame(maxWidth: 50)
                    .alignmentGuide(.top) { dimen in
                        dimen[VerticalAlignment.center]
                    }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(entity.rawContent ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                if let createdAt = entity.createdAt {
                    let timeStr = formatDate(createdAt)
                    let text = "\(qrEnum.title()) • \(timeStr)"
                    Text(text)
                        .font(.body)
                        .foregroundStyle(Color.gray)
                }
            }

            Spacer()

            // Favorite Button
            Button(action: {
                withAnimation {
                    entity.isFavorite.toggle()
                    CoreDataManager.shared.saveContext()
                }
            }) {
                Image(systemName: entity.isFavorite ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(theme.accent)
            }
            .buttonStyle(.borderless)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 16)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            let timeString = date.formatted(date: .omitted, time: .shortened)
            return "Today \(timeString)"
        } else {
            return date.formatted(date: .numeric, time: .shortened)
        }
    }
}
