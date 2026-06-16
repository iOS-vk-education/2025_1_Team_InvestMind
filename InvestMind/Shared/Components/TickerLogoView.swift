//
//  File.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 28.03.2026.
//

import Foundation
import SwiftUI

struct TickerLogoView: View {
    let ticker: String
    let fallbackSystemImage: String
    var size: CGFloat = 36
    var cornerRadius: CGFloat = 10
    var paddingInside: CGFloat = 6

    var body: some View {
        AsyncImage(url: LogoAPI.logoURL(for: ticker)) { phase in
            switch phase {
            case .empty:
                placeholder

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(paddingInside)
                    .frame(width: size, height: size)
                    .background(Color.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )

            case .failure:
                placeholder

            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
    }

    private var placeholder: some View {
        Image(systemName: fallbackSystemImage)
            .foregroundStyle(AppColors.textPrimary)
            .frame(width: size, height: size)
            .background(AppColors.backgroundSecondary)
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
    }
}
