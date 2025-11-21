

import SwiftUI

struct StockDetailView: View {
    let asset: Asset

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                header
                performanceCard
                actions
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(asset.name)
                        .font(AppTypography.headline(weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(asset.ticker)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                AssetChangeBadge(trend: asset.change)
            }

            Text(String(format: "$%.2f", asset.price))
                .font(AppTypography.largeTitle(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    private var performanceCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Динамика")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.backgroundSecondary)
                .frame(height: 220)
                .overlay(
                    WaveformChart()
                        .stroke(AppColors.accentPrimary, lineWidth: 3)
                        .padding()
                )

            HStack {
                StatBadge(title: "1D", value: "+1.2%", trend: .up(1.2))
                StatBadge(title: "1M", value: "+12%", trend: .up(12))
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

struct WaveformChart: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude = rect.height / 4
        let midY = rect.midY
        let step = rect.width / 6

        path.move(to: CGPoint(x: 0, y: midY))
        for index in 0...6 {
            let x = CGFloat(index) * step
            let angle = CGFloat(index) * .pi / 2
            let y = midY - sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}


