//
//  InvestMindApp.swift
//  InvestMind
//
//  Created by Богдан Топорин on 19.11.2025.
//

import SwiftUI
import FirebaseCore

@main
struct InvestMindApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var portfolioStore = PortfolioStore()
    @StateObject private var guideSession = AppGuideSession()

    @AppStorage("selectedTheme") private var selectedThemeRawValue = AppTheme.system.rawValue

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRawValue) ?? .system
    }

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(portfolioStore)
                .environmentObject(guideSession)
                .preferredColorScheme(selectedTheme.colorScheme)
                .onAppear {
                    // Если пользователь уже залогинен при запуске — сразу подключаем Firestore
                    if let uid = authService.currentUser?.uid {
                        portfolioStore.setup(userId: uid)
                    }
                }
                .onChange(of: authService.isAuthenticated) { isAuth in
                    if isAuth, let uid = authService.currentUser?.uid {
                        portfolioStore.setup(userId: uid)
                    } else {
                        portfolioStore.tearDown()
                    }
                }
        }
    }
}
