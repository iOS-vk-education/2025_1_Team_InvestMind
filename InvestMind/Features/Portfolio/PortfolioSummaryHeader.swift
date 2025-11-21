//
//  PortfolioSummaryHeader.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 21.11.2025.
//

import SwiftUI

struct PortfolioSummaryHeader: View {
    let summary: PortfolioSummary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {

            Text("Суммарная стоимость")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            Text(String(format: "$%.0f", summary.totalValue))
                .font(AppTypography.largeTitle(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: AppSpacing.md) {
                AssetChangeBadge(trend: .up(summary.dailyChange))

                Text("Инвестировано: \(Int(summary.invested))$")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppColors.cardShadow, radius: 10, y: 4)
    }
}

