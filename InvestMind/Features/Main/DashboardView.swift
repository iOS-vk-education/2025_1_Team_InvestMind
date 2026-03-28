import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    var onOpenAsset: (Asset) -> Void

    init(onOpenAsset: @escaping (Asset) -> Void) {
        self.onOpenAsset = onOpenAsset
        let bg   = UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1)
        let dark = UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
        UISegmentedControl.appearance().backgroundColor = bg
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: dark, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .selected
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                Text("Рынок")
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                Picker("Тип актива", selection: Binding(
                    get: { viewModel.selectedSegment },
                    set: { viewModel.selectSegment($0) }
                )) {
                    ForEach(MarketSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.selectedSegment == .stocks ? "Акции для покупки" : "Фонды для покупки")
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
            if viewModel.stockAssets.isEmpty {
                viewModel.loadMarket()
            }
        }
    }
}
