//
//  PortfolioListView.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 21.11.2025.
//

import SwiftUI
import SSCoachMarks

struct PortfolioListView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore

    let portfolios: [UserPortfolio]
    var onOpenPortfolio: (UserPortfolio) -> Void
    var onAddPortfolio: () -> Void = {}
    var onRefresh: () async -> Void = {}
    let isRefreshing: Bool

    private var currency: AppCurrency { portfolioStore.selectedCurrency }

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
                    .showCoachMark(
                        order: 0,
                        title: "Портфели",
                        description: "Здесь собраны твои портфели с общей стоимостью, вложенной суммой и текущим результатом.",
                        highlightViewCornerRadius: 18,
                        coachMarkBackGroundColor: AppColors.backgroundSecondary
                    )

                PortfolioSummaryHeader(
                    summary: portfolios.combinedSummary,
                    currencySymbol: currency.symbol
                )
                .showCoachMark(
                    order: 1,
                    title: "Общая сводка",
                    description: "Этот блок показывает суммарную стоимость портфелей и изменение результата по всем вложениям.",
                    highlightViewCornerRadius: 24,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )

                VStack(spacing: AppSpacing.md) {
                    ForEach(portfolios) { portfolio in
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack {
                                Text(portfolio.name)
                                    .font(AppTypography.headline(weight: .semibold))
                                    .foregroundStyle(AppColors.textPrimary)

                                Spacer()

                                Text(String(format: "%@%.0f", currency.symbol, portfolio.summary.totalValue))
                                    .foregroundStyle(AppColors.textPrimary)
                                    .font(AppTypography.body(weight: .bold))
                            }

                            HStack {
                                Text("Вложено: \(currency.symbol)\(Int(portfolio.summary.invested))")
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
                .showCoachMark(
                    order: 2,
                    title: "Список портфелей",
                    description: "Открой любой портфель, чтобы посмотреть состав, отдельные акции и результат по каждой позиции.",
                    highlightViewCornerRadius: 24,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )
            }
            .padding()
        }
        .refreshable {
            await onRefresh()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .toolbar {
            
//            ToolbarItem(placement: .principal) {
  //              Text("Мои портфели")
    //                .font(AppTypography.largeTitle(weight: .bold))
      //              .foregroundStyle(AppColors.textPrimary)
        //            .padding(.bottom, AppSpacing.md)
          //          .showCoachMark(
            //            order: 0,
              //          title: "Портфели",
                //        description: "Здесь собраны твои портфели с общей стоимостью, вложенной суммой и текущим результатом.",
                  //      highlightViewCornerRadius: 18,
                    //    coachMarkBackGroundColor: AppColors.backgroundSecondary
                   // )
            //}
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddPortfolio) {
                    Image(systemName: "plus")
                }
                .showCoachMark(
                    order: 3,
                    title: "Добавить портфель",
                    description: "Нажми сюда, чтобы создать новый портфель и начать учитывать покупки акций.",
                    highlightViewCornerRadius: 14,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )
            }
        }
    }
}
