
import SwiftUI

struct PortfolioView: View {
    let portfolio: UserPortfolio
    var onOpenAsset: (Asset) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                assetList
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(portfolio.name)
                    .font(AppTypography.headline(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Стоимость портфеля")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            Text(String(format: "$%.0f", portfolio.summary.totalValue))
                .font(AppTypography.largeTitle(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                AssetChangeBadge(trend: .up(portfolio.summary.dailyChange))
                Text("Инвестировано: \(Int(portfolio.summary.invested))$")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var assetList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Активы")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(portfolio.assets) { item in
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(item.asset.name)
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text(String(format: "$%.2f", item.asset.price))
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    HStack {
                        Text("\(item.amount, specifier: "%.1f") шт · \(item.asset.ticker)")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(AppTypography.caption())
                        Spacer()
                        Text(String(format: "%@%.0f$", item.profit >= 0 ? "+" : "-", abs(item.profit)))
                            .foregroundStyle(item.profit >= 0 ? AppColors.accentSecondary : AppColors.danger)
                            .font(AppTypography.caption(weight: .bold))
                    }
                }
                .padding()
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture { onOpenAsset(item.asset) }
            }
        }
    }
}


