//
//  ProfileView.swift
//  InvestMind
//
//  Wrapper для интеграции UIKit ProfileViewController в SwiftUI
//

import SwiftUI
import SSCoachMarks

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @AppStorage("selectedTheme") private var selectedThemeRawValue = AppTheme.system.rawValue

    var body: some View {
        ZStack {
            ProfileViewControllerRepresentable(
                authService: authService,
                email: authService.currentUser?.email,
                selectedThemeRawValue: selectedThemeRawValue,
                onSignOut: {
                    try? authService.signOut()
                }
            )
            .ignoresSafeArea()

            ProfileGuideOverlay()
        }
    }
}

private struct ProfileGuideOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let safeTop = geometry.safeAreaInsets.top
            let contentWidth = max(0, geometry.size.width - 32)

            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .frame(width: contentWidth, height: 336)
                    .showCoachMark(
                        order: 0,
                        title: "Настройки",
                        description: "Здесь можно посмотреть почту аккаунта, выбрать тему приложения, выйти из профиля или удалить учётную запись.",
                        highlightViewCornerRadius: 24,
                        coachMarkBackGroundColor: AppColors.backgroundSecondary
                    )

                Spacer()
            }
            .padding(.top, safeTop + 72)
            .padding(.horizontal, 16)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .allowsHitTesting(false)
        }
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
