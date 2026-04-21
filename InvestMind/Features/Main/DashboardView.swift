import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var isSearchPresented = false
    var onOpenAsset: (Asset) -> Void

    private var sectionTitle: String {
        switch viewModel.selectedSegment {
        case .stocks: return "Акции для покупки"
        case .funds:  return "Фонды для покупки"
        case .crypto: return "Криптовалюты для покупки"
        }
    }

    init(onOpenAsset: @escaping (Asset) -> Void) {
        self.onOpenAsset = onOpenAsset

        let segmentedBackground = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1)
                : UIColor.secondarySystemBackground
        }
        let selectedSegmentTint = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor.systemBackground
        }
        let normalTextColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor.label
        }
        let selectedTextColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
                : UIColor.label
        }

        UISegmentedControl.appearance().backgroundColor = segmentedBackground
        UISegmentedControl.appearance().selectedSegmentTintColor = selectedSegmentTint
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: normalTextColor,   .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: selectedTextColor, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
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

                Text(sectionTitle)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSearchPresented = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
        }
        .sheet(isPresented: $isSearchPresented) {
            MarketSearchView { asset in
                isSearchPresented = false
                onOpenAsset(asset)
            }
        }
    }
}
