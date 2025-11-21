//
//  PortfolioListView.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 21.11.2025.
//

import SwiftUI

struct PortfolioListView: View {
    let portfolios: [UserPortfolio]
    var onOpenPortfolio: (UserPortfolio) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                
                
                Text("Мои портфели")
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.bottom, AppSpacing.md)
                
                PortfolioSummaryHeader(summary: portfolios.combinedSummary)

                ForEach(portfolios) { portfolio in
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text(portfolio.name)
                                .font(AppTypography.headline(weight: .semibold))
                                .foregroundStyle(AppColors.textPrimary)

                            Spacer()

                            Text(String(format: "$%.0f", portfolio.summary.totalValue))
                                .foregroundStyle(AppColors.textPrimary)
                                .font(AppTypography.body(weight: .bold))
                        }

                        HStack {

                            Text("Инвестировано: \(Int(portfolio.summary.invested))$")
                                .foregroundStyle(AppColors.textSecondary)
                                .font(AppTypography.caption())
                            
                            Spacer()
                            
                            AssetChangeBadge(trend: .up(portfolio.summary.dailyChange))
                        }
                    }
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .onTapGesture { onOpenPortfolio(portfolio) }
                }
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
    }
}
