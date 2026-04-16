//
//  EmptyView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 16/4/26.
//

import SwiftUI

struct EmptyView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black
            Text(title)
                .foregroundStyle(.white)
                .font(.title2)
                .fontWeight(.semibold)
        }.ignoresSafeArea()
    }
}
