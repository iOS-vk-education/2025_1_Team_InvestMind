

import SwiftUI



// Булат: При этой реализации можно пролистать первый вопрос, не ответив, ответить только на вторйо и нажать далее.
// Мне кажется, надо сделать опрос строго пошаговым, без пролистывания вопросов
struct SurveyView: View {
    var onComplete: () -> Void
    var onBack: () -> Void
    
    @State private var currentPage = 0
    @State private var selectedExperience: Int? = nil
    @State private var selectedInterest: Int? = nil
    
    private let experienceOptions = [
        "Никогда не инвестировал",
        "Имею большой опыт",
        "Давно занимаюсь"
    ]
    
    private let interestOptions = [
        "Обучение инвестициям",
        "Ведение портфеля",
        "Новости рынка"
    ]
    
    var body: some View {
        ZStack {
            Image("BackgroundOnboardImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            AppColors.backgroundPrimary.opacity(0.75)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(14)
                    }
                    .glassEffect(in: .circle)
                    
                    Spacer()

                }
                .padding(.horizontal)
                .padding(.top)
                .overlay(
                    Text("InvestMind")
                        .font(AppTypography.logo())
                        .foregroundStyle(.white)
                )
            
            TabView(selection: $currentPage) {
                // Первая страница - опыт в инвестициях
                VStack(spacing: AppSpacing.xl) {
                    Text("Какой ваш опыт\nв инвестициях?")
                        .multilineTextAlignment(.center)
                        .font(AppTypography.largeTitle(weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.xl)
                    
                    VStack(spacing: AppSpacing.md) {
                        ForEach(Array(experienceOptions.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectedExperience = index
                            }) {
                                Text(option)
                                    .font(AppTypography.body(weight: .medium))
                                    .foregroundStyle(selectedExperience == index ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.md)
                                    .background(selectedExperience == index ? Color.white : Color.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Text("Выбирай ответы, это поможет нам лучше настроить приложение")
                        .multilineTextAlignment(.center)
                        .font(AppTypography.caption())
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(.horizontal, AppSpacing.xl)
                }
                .tag(0)
                
                // Вторая страница - интересы
                VStack(spacing: AppSpacing.xl) {
                    Text("Что вас интересует?")
                        .multilineTextAlignment(.center)
                        .font(AppTypography.largeTitle(weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.xl)
                    
                    VStack(spacing: AppSpacing.md) {
                        ForEach(Array(interestOptions.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectedInterest = index
                            }) {
                                Text(option)
                                    .font(AppTypography.body(weight: .medium))
                                    .foregroundStyle(selectedInterest == index ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.md)
                                    .background(selectedInterest == index ? Color.white : Color.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Text("Выбирай ответы, это поможет нам лучше настроить приложение")
                        .multilineTextAlignment(.center)
                        .font(AppTypography.caption())
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(.horizontal, AppSpacing.xl)
                }
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
            // Вот тут запретил свайп
            .highPriorityGesture(
                currentPage == 0 ? DragGesture().onChanged { _ in } : nil
            )
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(0..<2, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                        .frame(width: index == currentPage ? 30 : 10, height: 6)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            
            if currentPage == 0 {
                Button(action: {
                    if selectedExperience != nil {
                        withAnimation {
                            currentPage = 1
                        }
                    }
                }) {
                    Text("Далее")
                        .font(AppTypography.headline())
                        .foregroundStyle(selectedExperience != nil ? .white : Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(selectedExperience != nil ? AppColors.buttonPrimary : Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .disabled(selectedExperience == nil)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
            } else if currentPage == 1 {
                Button(action: {
                    if selectedInterest != nil {
                        onComplete()
                    }
                }) {
                    Text("Далее")
                        .font(AppTypography.headline())
                        .foregroundStyle(selectedInterest != nil ? .white : Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(selectedInterest != nil ? AppColors.buttonPrimary : Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .disabled(selectedInterest == nil)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
            }
            
                Spacer(minLength: AppSpacing.xl)
            }
            .padding(.top)
        }
    }
}

