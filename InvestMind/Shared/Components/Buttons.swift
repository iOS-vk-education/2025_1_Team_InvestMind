
import SwiftUI

struct PrimaryButton: View {
    let title: String
    var action: () -> Void
    var icon: String? = nil
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text(title)
                        .font(AppTypography.headline())
                        .foregroundStyle(Color.white)
                }

                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(AppGradients.brand)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: AppColors.cardShadow, radius: 18, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct FilledButton: View {
    let title: String
    var color: Color
    var textColor: Color = .white
    var borderColor: Color? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.headline())
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(borderColor ?? Color.clear, lineWidth: borderColor == nil ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.body(weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SocialLoginButton: View {
    enum Provider {
        case apple
        case vk

        var title: String {
            switch self {
            case .apple: return "Apple"
            case .vk: return "VK"
            }
        }

        var iconName: String? {
            switch self {
            case .apple: return "applelogo"
            case .vk: return nil
            }
        }
    }

    let provider: Provider
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let iconName = provider.iconName {
                    Image(systemName: iconName)
                        .font(.headline)
                } else {
                    Text(provider.title.prefix(2))
                        .font(AppTypography.body(weight: .bold))
                }
                Text("Войти через \(provider.title)")
                    .font(AppTypography.body(weight: .semibold))
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


