//
//  PlaceholderView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 16/4/26.
//

import SwiftUI

struct PlaceholderView: View {
    
    let icon: String
    let title: String
    let content: String?
    
    var body: some View {

        GeometryReader { geo in
            VStack(alignment: .center) {
                
                Spacer()
                
                Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(.white)

                Text(title)
                .font(.title2)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                
                if let content = content {
                    Spacer().frame(height: 12)
                    Text(content)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .foregroundStyle(.white)
                }

                Spacer().frame(height: 8)
                
                Spacer().frame(height: geo.size.height / 2)

            }
        }
    }
}
