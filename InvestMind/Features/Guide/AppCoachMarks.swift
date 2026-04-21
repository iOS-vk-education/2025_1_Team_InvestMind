import SwiftUI
import SSCoachMarks

struct MainGuideCoachMarksModifier: ViewModifier {
    let isEnabled: Bool
    let doneButtonText: String
    let onFinished: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var overlayColor: Color {
        Color.black
    }

    private var configuredCoachMarks: CoachMarkView {
        CoachMarkView(onCoachMarkFinished: onFinished)
            .coachMarkTitleViewStyle(
                foregroundStyle: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: Font.Weight.bold
            )
            .coachMarkDescriptionViewStyle(
                foregroundStyle: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: Font.Weight.medium
            )
            .overlayStyle(
                overlayColor: overlayColor,
                overlayOpacity: colorScheme == .dark ? 0.82 : 0.72
            )
            .nextButtonStyle(
                buttonText: "Далее",
                foregroundStyle: Color.white,
                backgroundColor: AppColors.buttonPrimary,
                fontSize: 14,
                fontWeight: Font.Weight.semibold
            )
            .backButtonStyle(
                buttonText: "Назад",
                foregroundStyle: AppColors.textPrimary,
                backgroundColor: AppColors.backgroundSecondary,
                fontSize: 14,
                fontWeight: Font.Weight.medium
            )
            .doneButtonStyle(
                buttonText: doneButtonText,
                foregroundStyle: Color.white,
                backgroundColor: AppColors.buttonPrimary,
                fontSize: 14,
                fontWeight: Font.Weight.semibold
            )
            .skipCoachMarkButtonStyle(
                buttonText: "Пропустить",
                foregroundStyle: AppColors.textPrimary,
                backgroundColor: AppColors.backgroundSecondary,
                fontSize: 14,
                fontWeight: Font.Weight.medium
            )
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content
                .modifier(configuredCoachMarks)
        } else {
            content
        }
    }
}

extension View {
    func appMainGuide(
        isEnabled: Bool,
        doneButtonText: String = "Готово",
        onFinished: @escaping () -> Void
    ) -> some View {
        modifier(
            MainGuideCoachMarksModifier(
                isEnabled: isEnabled,
                doneButtonText: doneButtonText,
                onFinished: onFinished
            )
        )
    }
}
