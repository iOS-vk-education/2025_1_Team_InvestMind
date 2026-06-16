
import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore
    @Environment(\.dismiss) private var dismiss
    @State private var isRenamePresented = false
    @State private var isDeleteConfirmationPresented = false
    @State private var editedName = ""
    let portfolioId: UUID
    var onOpenAsset: (Asset) -> Void

    private var portfolio: UserPortfolio? {
        portfolioStore.portfolios.first(where: { $0.id == portfolioId })
    }

    var body: some View {
        Group {
            if let portfolio {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        header(portfolio)
                        assetList(portfolio)
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
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Переименовать") {
                                editedName = portfolio.name
                                isRenamePresented = true
                            }

                            Button(role: .destructive) {
                                isDeleteConfirmationPresented = true
                            } label: {
                                Text("Удалить")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .alert("Переименовать портфель", isPresented: $isRenamePresented) {
                    TextField("Название", text: $editedName)
                    Button("Отмена", role: .cancel) {}
                    Button("Сохранить") {
                        portfolioStore.renamePortfolio(id: portfolio.id, newName: editedName)
                    }
                } message: {
                    Text("Введите новое название портфеля")
                }
                .alert("Удалить портфель?", isPresented: $isDeleteConfirmationPresented) {
                    Button("Удалить", role: .destructive) {
                        portfolioStore.deletePortfolio(id: portfolio.id)
                        dismiss()
                    }

                    Button("Отмена", role: .cancel) {}

                } message: {
                    Text("Это действие нельзя отменить")
                }
            } else {
                Text("Портфель не найден")
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColors.backgroundPrimary.ignoresSafeArea())
            }
        }
    }

    private func header(_ portfolio: UserPortfolio) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Стоимость портфеля")
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            Text(String(format: "$%.0f", portfolio.summary.totalValue))
                .font(AppTypography.largeTitle(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            HStack {
                AssetChangeBadge(
                    trend: portfolio.summary.totalReturnPercent >= 0
                        ? .up(portfolio.summary.totalReturnPercent)
                        : .down(abs(portfolio.summary.totalReturnPercent))
                )
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

    private func assetList(_ portfolio: UserPortfolio) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Активы")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(portfolio.assets) { item in
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        TickerLogoView(
                            ticker: item.asset.ticker,
                            fallbackSystemImage: item.asset.icon,
                            size: 32,
                            cornerRadius: 8,
                            paddingInside: 5
                        )
                        Text(item.asset.name)
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        Spacer()
                        Text(String(format: "$%.2f", item.amount * item.asset.price))
                            .foregroundStyle(AppColors.textPrimary)
                    }

                    HStack {
                        Text("\(item.amount, specifier: "%.1f") шт · \(item.asset.ticker)")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(AppTypography.caption())
                        Spacer()
                        let profitPercent = item.invested > 0 ? item.profit / item.invested * 100 : 0
                        Text(
                            String(
                                format: "%@%.0f$ (%@%.2f%%)",
                                item.profit >= 0 ? "+" : "-",
                                abs(item.profit),
                                profitPercent >= 0 ? "+" : "-",
                                abs(profitPercent)
                            )
                        )
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


