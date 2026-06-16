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
                .preferredColorScheme(selectedTheme.colorScheme)
        }
    }
}

