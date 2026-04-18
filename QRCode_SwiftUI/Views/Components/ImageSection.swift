//
//  ImageSection.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 9/4/26.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ImageSection: View {
    @EnvironmentObject var theme: ThemeManager
    @Binding var listImage: [UIImage]
    @State private var selectedItems: [PhotosPickerItem] = []
    
    let maxImages: Int
    private let cornerRadius: CGFloat = 12
    private let size = CGSize(width: 80, height: 80)
    
    let columns: [GridItem] = [
        GridItem(),
        GridItem(),
        GridItem(),
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            if !listImage.isEmpty {
                ForEach(listImage.indices, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: listImage[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius:cornerRadius))

                        Image(systemName: "xmark") // Icon tắt chuẩn của iOS
                            .frame(width: 16, height: 16)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5).clipShape(Circle()))
                            .offset(x: -3, y: 3)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                listImage.remove(at: index)
                            }
                    }
                }
            }
            
            if listImage.count < maxImages {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    Image(systemName: "plus")
                        .font(.title)
                        .tint(theme.accent)
                        .frame(width: size.width, height: size.height)
                        .background(Color.backgroundColor)
                        .clipShape(.rect(cornerRadius:cornerRadius))
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(lineWidth: 2)
                                .fill(theme.accent)
                        }
                }
                // Lắng nghe khi người dùng chọn ảnh xong
                .onChange(of: selectedItems) { newValue in
                    // Kiểm tra và lấy ảnh đầu tiên
                    guard let item = newValue.first, listImage.count < maxImages else { return }
                    
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            // 2. Phải update mảng Image trên luồng chính (Main Thread)
                            await MainActor.run {
                                listImage.append(uiImage)
                                selectedItems.removeAll()
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
