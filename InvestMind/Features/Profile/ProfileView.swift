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
        ProfileViewControllerRepresentable(
            email: authService.currentUser?.email,
            onSignOut: {
                try? authService.signOut()
            }
        )
            .ignoresSafeArea()
    }
}

struct ProfileViewControllerRepresentable: UIViewControllerRepresentable {

    let email: String?
    let onSignOut: () -> Void
    
    func makeUIViewController(context: Context) -> ProfileViewController {
        let vc = ProfileViewController()
        vc.onSignOut = onSignOut
        vc.email = email
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ProfileViewController, context: Context) {
        uiViewController.onSignOut = onSignOut
        uiViewController.email = email
    }
}


