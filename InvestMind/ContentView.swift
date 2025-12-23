//
//  ContentView.swift
//  InvestMind
//
//  Created by Богдан Топорин on 19.11.2025.
//

import SwiftUI
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var portfolioStore: PortfolioStore
    @State private var flowStep: FlowStep = .splash
    @State private var isGoingForward = true

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            switch flowStep {
            case .splash:
                SplashView {
                    // Проверяем состояние авторизации
                    if authService.isAuthenticated {
                        flowStep = .main
                    } else {
                        flowStep = .onboarding
                    }
                }
                .transition(.opacity)
            case .onboarding:
                OnboardingView(
                    pages: MockData.onboardingPages,
                    onStartFree: {
                        isGoingForward = true
                        flowStep = .survey
                    },
                    onSelectLogin: {
                        isGoingForward = true
                        flowStep = .auth
                    }
                )
                .transition(isGoingForward
                            ? .move(edge: .trailing)
                            : .move(edge: .leading))
            case .survey:
                SurveyView(
                    onComplete: { isGoingForward = true; flowStep = .register },
                    onBack: { isGoingForward = false; flowStep = .onboarding }
                )
                .transition(isGoingForward
                            ? .move(edge: .trailing)
                            : .move(edge: .leading))
            case .auth:
                AuthView(
                    onAuthenticated: { flowStep = .main },
                    onShowRegister: { flowStep = .register }
                )
                .transition(.move(edge: .trailing))
            case .register:
                RegisterView(
                    onRegistered: { flowStep = .main },
                    onShowLogin: { flowStep = .auth }
                )
                .transition(.move(edge: .trailing))
            case .postAuthGuide:
                PostAuthGuideView(steps: MockData.postAuthGuide) {
                    flowStep = .main
                }
                .transition(.opacity)
            case .main:
                MainTabView()
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: flowStep)
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if !isAuthenticated {
                if flowStep == .main {
                    flowStep = .auth
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
        .environmentObject(PortfolioStore())
}
