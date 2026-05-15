

import SwiftUI
import Charts

struct StockDetailView: View {
    @StateObject private var viewModel: StockDetailViewModel

    @State private var isBuyPresented = false
    @State private var isSellPresented = false

    init(asset: Asset) {
        _viewModel = StateObject(wrappedValue: StockDetailViewModel(asset: asset))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                header
                performanceCard
                actions
            }
            .padding()
            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .refreshable {
            viewModel.load()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            viewModel.load()
        }
        .sheet(isPresented: $isBuyPresented) {
            BuyStockView(asset: viewModel.asset, pricePerShare: currentPrice)
        }
        .sheet(isPresented: $isSellPresented) {
            SellStockView(asset: viewModel.asset, pricePerShare: currentPrice)
        }
    }

    private var currentPrice: Double {
        viewModel.price ?? viewModel.asset.price
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {

            // MARK: Top row
            HStack(alignment: .center) {

                TickerLogoView(
                    ticker: viewModel.asset.ticker,
                    fallbackSystemImage: viewModel.asset.icon,
                    size: 44,
                    cornerRadius: 12,
                    paddingInside: 6
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.asset.name)
                        .font(AppTypography.headline(weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(viewModel.asset.ticker)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                if let percent = viewModel.dayChangePercent {
                    //HStack(alignment: .firstTextBaseline, spacing: 8) {
                    //    Text("За сегодня").font(AppTypography.caption()).foregroundStyle(AppColors.textSecondary)

                        //if let percent = viewModel.dayChangePercent {
                            //Text(String(format: "%+.2f%%", percent)).font(AppTypography.caption(weight: .medium))
                                //.foregroundStyle(percent >= 0 ? AppColors.accentSecondary: AppColors.danger)
                        //}
                        //}
                    VStack( spacing: 8) {
                        Text("За сегодня").font(AppTypography.caption()).foregroundStyle(AppColors.textSecondary)
                        AssetChangeBadge(
                            trend: percent >= 0
                            ? .up(percent)
                            : .down(abs(percent))
                        )
                    }
                }
            }

            // MARK: Price block
            VStack(alignment: .leading, spacing: 6) {

                if let price = viewModel.price {
                    Text(String(format: "$%.2f", price))
                        .font(AppTypography.largeTitle(weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    //HStack(alignment: .firstTextBaseline, spacing: 8) {
                    //    Text("За сегодня").font(AppTypography.caption()).foregroundStyle(AppColors.textSecondary)

                        //if let percent = viewModel.dayChangePercent {
                            //Text(String(format: "%+.2f%%", percent)).font(AppTypography.caption(weight: .medium))
                                //.foregroundStyle(percent >= 0 ? AppColors.accentSecondary: AppColors.danger)
                        //}
                        //}
                } else {
                    ProgressView()
                }
                
            }
        }
    }
    
    private var periodStatTitle: String {
        switch viewModel.selectedPeriod {
        case .month1: return "1 месяц"
        case .month3: return "3 месяца"
        case .month6: return "6 месяцев"
        case .year: return "1 год"
        }
    }

    private var periodChangeValue: Double? {
        switch viewModel.selectedPeriod {
        case .month1: return viewModel.month1ChangeValue
        case .month3: return viewModel.month3ChangeValue
        case .month6: return viewModel.month6ChangeValue
        case .year: return viewModel.yearChangeValue
        }
    }

    private var periodChangePercent: Double? {
        switch viewModel.selectedPeriod {
        case .month1: return viewModel.month1ChangePercent
        case .month3: return viewModel.month3ChangePercent
        case .month6: return viewModel.month6ChangePercent
        case .year: return viewModel.yearChangePercent
        }
    }

    private var performanceCard: some View {
        //VStack(alignment: .leading, spacing: AppSpacing.md)
        VStack(alignment: .leading, spacing: 12){
            Text("Динамика")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            PriceChartView(prices: viewModel.chartPrices)
                .overlay {
                    if viewModel.chartPrices.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(AppColors.backgroundSecondary.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .tint(AppColors.accentPrimary)
//            .environment(\.colorScheme, .dark)
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                viewModel.loadChartPrices()
            }

            // Period stats
            HStack(spacing: AppSpacing.md) {

                StatChangeBadge(
                    title: periodStatTitle,
                    value: periodChangeValue,
                    percent: periodChangePercent
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                StatChangeBadge_icon(
                    title: "Аналитика",
                    //recommendation: viewModel.recommendation,
                    recommendation: viewModel.recommendation,
                    growthPotential: viewModel.growthPotential
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 100) //
            
        }
    }


    
    private var actions: some View {
        HStack(spacing: AppSpacing.md) {

            // Купить
            Button(action: { isBuyPresented = true }) {
                HStack {
                    Text("Купить")
                        .font(AppTypography.headline(weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            // Продать
            Button(action: { isSellPresented = true }) {
                HStack {
                    Text("Продать")
                        .font(AppTypography.headline(weight: .semibold))
                }
                .foregroundStyle(AppColors.danger)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.danger.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

}


