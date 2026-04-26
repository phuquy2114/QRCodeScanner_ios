//
//  SplashView.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 5/4/26.
//

import SwiftUI

struct SplashView: View {

    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        ZStack {
            Rectangle().fill(theme.accent)
            Image("icon_splash_screen")
                .frame(width: 50, height: 50, alignment: .center)
        }
    }
}
