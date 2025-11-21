

import SwiftUI

struct OnboardingView: View {
    let pages: [OnboardingPage]
    var onStartFree: () -> Void
    var onSelectLogin: () -> Void

    @State private var selection = 0
    @State private var buttonsUnlocked = false

    var body: some View {
        ZStack {
            Image("BackgroundOnboardImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            AppColors.backgroundPrimary.opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Text("InvestMind")
                    .font(AppTypography.logo())
                    .foregroundStyle(.white)
                    .padding(.top, AppSpacing.xl)

                Spacer()

                TabView(selection: $selection) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: AppSpacing.md) {
                            Text(page.title)
                                .multilineTextAlignment(.center)
                                .font(AppTypography.largeTitle(weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.xl)

                            Text(page.subtitle)
                                .multilineTextAlignment(.center)
                                .font(AppTypography.body())
                                .foregroundStyle(AppColors.textSecondary)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                        .padding(.top, AppSpacing.xl)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selection)
                .onChange(of: selection) { oldValue, newValue in
                    if newValue == pages.count - 1 {
                        buttonsUnlocked = true
                    }
                    
                }

                HStack(spacing: AppSpacing.sm) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == selection ? Color.white : Color.white.opacity(0.35))
                            .frame(width: index == selection ? 30 : 10, height: 6)
                            .animation(.easeInOut, value: selection)
                    }
                }

                let showsButton = pages[min(selection, pages.count - 1)].showsAuthActions || buttonsUnlocked
                VStack(spacing: AppSpacing.sm) {
                    FilledButton(
                        title: "Начать бесплатно",
                        color: AppColors.buttonPrimary,
                        textColor: .white,
                        action: onStartFree
                    )
                    .opacity(showsButton ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.4), value: showsButton)
                    
                    Button(action: onSelectLogin) {
                        Text("Уже есть аккаунт? Войти")
                            .font(AppTypography.body())
                            .foregroundStyle(.white)
                    }
                    .opacity(showsButton ? 1.0 : 0.0)
                    .padding(.top, AppSpacing.xs)
                }
                .padding(.top, AppSpacing.sm)
                .animation(.easeInOut(duration: 0.3), value: showsButton)

                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.xl)
        }
    }
}


