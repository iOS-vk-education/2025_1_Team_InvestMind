//
//  ProfileView.swift
//  InvestMind
//
//  Wrapper для интеграции UIKit ProfileViewController в SwiftUI
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        ProfileViewControllerRepresentable(authService: authService)
            .ignoresSafeArea()
    }
}

struct ProfileViewControllerRepresentable: UIViewControllerRepresentable {
    let authService: AuthService

    func makeUIViewController(context: Context) -> ProfileViewController {
        return ProfileViewController(authService: authService)
    }

    func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
        uiViewController.updateAuthState()
    }
}


