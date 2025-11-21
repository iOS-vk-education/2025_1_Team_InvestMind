

import SwiftUI

struct DashboardView: View {
    var assets: [Asset]
    var onOpenAsset: (Asset) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                Text("Рынок")
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Активы для покупки")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                LazyVStack(spacing: 0) {
                    ForEach(assets) { asset in
                        MarketAssetRow(asset: asset)
                            .onTapGesture { onOpenAsset(asset) }

                        Divider()
                            .background(AppColors.backgroundSecondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
    }
}


