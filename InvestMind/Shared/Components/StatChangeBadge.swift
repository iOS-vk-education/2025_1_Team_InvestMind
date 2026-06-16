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
