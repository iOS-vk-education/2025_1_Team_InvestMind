

import SwiftUI
import Charts

struct StockDetailView: View {
    @StateObject private var viewModel: StockDetailViewModel

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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.asset.name)
                        .font(AppTypography.headline(weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(viewModel.asset.ticker)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                if let percent = viewModel.dayChangePercent {
                    AssetChangeBadge(
                        trend: percent >= 0
                            ? .up(percent)
                            : .down(abs(percent))
                    )
                }
            }

            if let price = viewModel.price {
                Text(String(format: "$%.2f", price))
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }

    private var performanceCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Динамика")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Chart {
                ForEach(Array(viewModel.chartPrices.enumerated()), id: \.offset) { index, price in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Price", price)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.accentPrimary)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(AppColors.border)

                    AxisValueLabel()
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(AppColors.border)

                    AxisValueLabel()
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .frame(height: 220)
            .padding()
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .tint(AppColors.accentPrimary)
            .environment(\.colorScheme, .dark)
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                viewModel.loadChartPrices()
            }

            HStack(spacing: AppSpacing.md) {
                StatChangeBadge(
                    title: "1D",
                    value: viewModel.dayChangeValue,
                    percent: viewModel.dayChangePercent
                )

                StatChangeBadge(
                    title: "1Y",
                    value: viewModel.yearChangeValue,
                    percent: viewModel.yearChangePercent
                )
            }
        }
    }


    private var actions: some View {
        VStack(spacing: AppSpacing.md) {

            // Купить
            Button(action: {}) {
                HStack {
                    Image(systemName: "cart.fill.badge.plus")
                        .font(.headline)
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
            Button(action: {}) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.headline)
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


