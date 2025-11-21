

import SwiftUI

struct PostAuthGuideView: View {
    let steps: [GuideStep]
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Как пользоваться InvestMind")
                .font(AppTypography.largeTitle(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, AppSpacing.xl)

            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(steps) { step in
                        GuideCard(step: step)
                    }
                }
            }

            PrimaryButton(title: "Перейти к приложению", action: onFinish, icon: "arrow.right")
        }
        .padding()
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
    }
}


