
import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                header
                settings
            }
            .padding()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(AppGradients.brand)
                .frame(width: 96, height: 96)
                .overlay(
                    Text("BT")
                        .font(AppTypography.title(weight: .bold))
                        .foregroundStyle(.white)
                )

            Text("Богдан Топорин")
                .font(AppTypography.headline(weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
            Text("bogdan@investmind.app")
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var settings: some View {
        VStack(spacing: AppSpacing.sm) {
            SettingsRow(icon: "bell.badge.fill", title: "Уведомления")
            SettingsRow(icon: "lock.fill", title: "Безопасность")
            SettingsRow(icon: "creditcard", title: "Подписка")
            SettingsRow(icon: "questionmark.circle", title: "Помощь и поддержка")
            SettingsRow(icon: "arrow.backward.circle", title: "Выйти")
        }
        .padding()
        .background(AppColors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .foregroundStyle(AppColors.accentPrimary)
                .background(AppColors.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(AppTypography.body(weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}


