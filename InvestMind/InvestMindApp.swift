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
    
    init() {
        // Инициализация Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
        }
    }
}

