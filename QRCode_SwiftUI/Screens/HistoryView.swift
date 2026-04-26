import CoreData
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var theme: ThemeManager
    @FetchRequest var items: FetchedResults<QRCodeEntity>
    @State private var itemToDelete: QRCodeEntity?
    @State private var showDeleteAlert = false
    
    var isFavoriteOnly: Bool

    init(isFavoriteOnly: Bool) {
        self.isFavoriteOnly = isFavoriteOnly

        let request: NSFetchRequest<QRCodeEntity> = NSFetchRequest<
            QRCodeEntity
        >(entityName: "QRCodeEntity")
        request.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        if isFavoriteOnly {
            request.predicate = NSPredicate(format: "isFavorite == YES")
        }

        _items = FetchRequest(fetchRequest: request, animation: .default)
    }

    var body: some View {
        ZStack {

            if items.isEmpty {
                let data = getDefaultData()
                PlaceholderView(
                    icon: data.icon,
                    title: data.title,
                    content: data.content)
            } else {
                buildList()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isFavoriteOnly ? "Favorite" : "History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .marginBottom()
        .background(Color.black)
        .alert(
            "Delete QR Code",
            isPresented: $showDeleteAlert,
            presenting: itemToDelete
        ) { item in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                withAnimation {
                    CoreDataManager.shared.context.delete(item)
                    CoreDataManager.shared.saveContext()
                }
            }
        } message: { item in
            Text(
                "Are you sure you want to delete this QR code? This action cannot be undone."
            )
        }
    }
    
    private func getDefaultData() -> (icon: String, title: String, content: String) {
        
        let icon = isFavoriteOnly ? "heart.slash" : "doc.text.magnifyingglass"
        let title = isFavoriteOnly ? "No favorites yet." : "No history yet."
        let content = isFavoriteOnly ? "On the history screen, tap the star icon to view the data there." : "Create your first QR code to get the data on this screen"
        
        return (icon, title, content)
    }
    
    private func buildList() -> some View {
        List {
            ForEach(items) { item in
                buildCell(item: item)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
    }
    
    private func buildCell(item: FetchedResults<QRCodeEntity>.Element) -> some View {
        ZStack {
            // 1. NavigationLink ảo dùng để điều hướng mà không hiện mũi tên (chevron)
            NavigationLink(destination: HistoryDetailRouterView(entity: item)) {
                EmptyView()
            }.opacity(0)
            
            // 2. Giao diện thực của Cell đè lên trên
            HistoryCellView(entity: item)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                itemToDelete = item
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
        }
    }
}
