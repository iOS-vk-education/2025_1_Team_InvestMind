
import SwiftUI

struct GuideCard: View {
    let step: GuideStep

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: step.iconName)
                .font(.system(size: 32))
                .foregroundStyle(AppColors.accentPrimary)
                .frame(width: 64, height: 64)
                .background(AppColors.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text(step.title)
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)

            Text(step.description)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}


