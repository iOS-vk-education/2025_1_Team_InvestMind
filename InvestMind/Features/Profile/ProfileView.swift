//
//  ProfileView.swift
//  InvestMind
//
//  Wrapper для интеграции UIKit ProfileViewController в SwiftUI
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @AppStorage("selectedTheme") private var selectedThemeRawValue = AppTheme.system.rawValue

    var body: some View {
        ProfileViewControllerRepresentable(
            authService: authService,
            email: authService.currentUser?.email,
            selectedThemeRawValue: selectedThemeRawValue,
            onSignOut: {
                try? authService.signOut()
            }
        )
        .ignoresSafeArea()
    }
}

struct ProfileViewControllerRepresentable: UIViewControllerRepresentable {
    let authService: AuthService
    let email: String?
    let selectedThemeRawValue: String
    let onSignOut: () -> Void

    func makeUIViewController(context: Context) -> ProfileViewController {
        let vc = ProfileViewController()
        vc.authService = authService
        vc.onSignOut = onSignOut
        vc.email = email
        vc.selectedThemeRawValue = selectedThemeRawValue
        return vc
    }

    func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
        uiViewController.authService = authService
        uiViewController.onSignOut = onSignOut
        uiViewController.email = email
        uiViewController.selectedThemeRawValue = selectedThemeRawValue
        uiViewController.applyTheme()
    }
}


