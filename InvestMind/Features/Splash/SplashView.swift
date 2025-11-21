//
//  SplashView.swift
//  InvestMind
//

import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Text("InvestMind")
                .font(AppTypography.logo(size: 48))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished()
            }
        }
    }
}


