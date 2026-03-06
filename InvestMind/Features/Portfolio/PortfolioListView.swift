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
    var onAddPortfolio: () -> Void = {}
    var onRefresh: () async -> Void = {}
    let isRefreshing: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                
                if isRefreshing {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
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
                            
                            AssetChangeBadge(
                                trend: portfolio.summary.totalReturnPercent >= 0
                                    ? .up(portfolio.summary.totalReturnPercent)
                                    : .down(abs(portfolio.summary.totalReturnPercent))
                            )
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
        .refreshable {
            await onRefresh()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddPortfolio) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
