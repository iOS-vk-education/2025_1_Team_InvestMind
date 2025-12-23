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
    
    init() {
        // Инициализация Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(portfolioStore)
        }
    }
}

