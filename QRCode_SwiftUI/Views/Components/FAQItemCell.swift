//
//  FAQItemCell.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 8/4/26.
//

import SwiftUI

struct FAQItemCell: View {
    @State private var isExpanded = false
    let item: FAQItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .scaledToFit()
                
                Text(item.question)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
        
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .scaledToFit()
            }
            
            if isExpanded {
                Text(item.answer)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(16) // Padding bên trong nội dung của Cell
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.backgroundColor)
        )
        // Bấm vào khu vực nào của Cell cũng sổ xuống được
        .contentShape(Rectangle()) 
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
