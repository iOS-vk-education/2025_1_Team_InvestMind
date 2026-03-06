import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    var onOpenAsset: (Asset) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
                Text("Рынок")
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Активы для покупки")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(AppColors.danger)
                        .font(AppTypography.caption())
                        .padding(.top, 8)
                }

                LazyVStack(spacing: 0) {
                    ForEach(viewModel.assets) { asset in
                        MarketAssetRow(asset: asset)
                            .contentShape(Rectangle())
                            .onTapGesture { onOpenAsset(asset) }

                        Divider()
                            .background(AppColors.backgroundSecondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .refreshable {
            viewModel.loadMarket()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            if viewModel.assets.isEmpty {
                viewModel.loadMarket()
            }
        }
    }
}
