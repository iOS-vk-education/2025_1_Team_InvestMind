//
//  StatChangeBadge.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import SwiftUI

struct StatChangeBadge: View {

    let title: String
    let value: Double?
    let percent: Double?

    private var isPositive: Bool {
        (percent ?? 0) >= 0
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            Text(formattedValue)
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(isPositive ? AppColors.accentSecondary : AppColors.danger)

            Text(formattedPercent)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var formattedValue: String {
        guard let value else { return "—" }
        return String(format: "%+.2f $", value)
    }

    private var formattedPercent: String {
        guard let percent else { return "—" }
        return String(format: "%+.2f%%", percent)
    }
}

struct StatChangeBadge_icon: View {

    let title: String
    let recommendation: Recommendation?
    let growthPotential: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .font(AppTypography.caption())
                .foregroundStyle(AppColors.textSecondary)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        if let recommendation {
            VStack(alignment: .leading, spacing: 4) {

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: recommendation.icon)
                        .font(.caption)
                        .font(AppTypography.headline(weight: .medium))
                        .foregroundStyle(recommendation.color)

                    Text(recommendation.rawValue)
                        .font(AppTypography.headline(weight: .medium))
                        .foregroundStyle(recommendation.color)
                }

                HStack(spacing: 2) {
                    Image(systemName: (growthPotential ?? 0) >= 0
                          ? "trending.up"
                          : "trending.down")
                        .font(.caption2)
                        .foregroundStyle((growthPotential ?? 0) >= 0 ? .green : .red)

                    Text(growthText)
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        } else {
            Text("Loading")
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private var growthText: String {
        guard let growthPotential else { return "Потенциал: --" }
        return String(format: "Прогноз: %+.1f%%", growthPotential)
    }
}
