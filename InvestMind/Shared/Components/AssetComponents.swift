
import SwiftUI

struct AssetChangeBadge: View {
    let trend: Asset.Trend

    var body: some View {
        let isPositive = trend.isPositive
        let symbol = isPositive ? "arrow.up.right" : "arrow.down.right"
        let color = isPositive ? AppColors.accentSecondary : AppColors.danger
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.caption)
            Text(String(format: "%.2f%%", trend.value))
                .font(AppTypography.caption(weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct AssetCompactCard: View {
    let asset: Asset

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: asset.icon)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Spacer()

                AssetChangeBadge(trend: asset.change)
            }

            Text(asset.ticker)
                .font(AppTypography.headline())
                .foregroundStyle(AppColors.textPrimary)

            Text(asset.name)
                .font(AppTypography.caption(weight: .regular))
                .foregroundStyle(AppColors.textSecondary)

            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "$%.2f", asset.price))
                    .font(AppTypography.title(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: AppColors.cardShadow, radius: 12, y: 4)
    }
}

struct MarketAssetRow: View {
    let asset: Asset

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: asset.icon)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 32, height: 32)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text(asset.ticker)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", asset.price))
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                AssetChangeBadge(trend: asset.change)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}


struct StatBadge: View {
    let title: String
    let value: String
    let trend: Asset.Trend?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
            Text(value)
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            if let trend {
                AssetChangeBadge(trend: trend)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}


