//
//  SplashView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

struct SplashView: View {
    private let color: Color = .yellow

    var body: some View {
        ZStack {
            Rectangle().fill(color)
            Image("icon_splash_screen")
                .frame(width: 50, height: 50, alignment: .center)
        }
    }
}
