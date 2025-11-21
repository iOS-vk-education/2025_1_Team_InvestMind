//
//  ContentView.swift
//  InvestMind
//
//  Created by Богдан Топорин on 19.11.2025.
//

import SwiftUI
struct ContentView: View {
    @State private var flowStep: FlowStep = .splash
    @State private var isGoingForward = true

    var body: some View {
        ZStack {
            AppColors.backgroundPrimary
                .ignoresSafeArea()

            switch flowStep {
            case .splash:
                SplashView {
                    flowStep = .onboarding
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
                    onAuthenticated: { flowStep = .postAuthGuide },
                    onShowRegister: { flowStep = .register }
                )
                .transition(.move(edge: .trailing))
            case .register:
                RegisterView(
                    onRegistered: { flowStep = .postAuthGuide },
                    onShowLogin: { flowStep = .auth }
                )
                .transition(.move(edge: .trailing))
            case .postAuthGuide:
                PostAuthGuideView(steps: MockData.postAuthGuide) {
                    flowStep = .main
                }
                .transition(.opacity)
            case .main:
                MainTabView(
                    assets: MockData.assets,
                    portfolios: MockData.userPortfolios
                )
                .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: flowStep)
    }
}

#Preview {
    ContentView()
}
