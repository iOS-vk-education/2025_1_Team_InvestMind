//
//  AuthService.swift
//  InvestMind
//
//  Created for Firebase Authentication
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Слушаем изменения состояния авторизации
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // Регистрация с email и паролем
    func signUp(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // Вход с email и паролем
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // Выход
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // Сброс пароля
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // Обработка ошибок Firebase
    private func handleAuthError(_ error: Error) -> String {
        guard let authError = error as NSError? else {
            return "Произошла неизвестная ошибка"
        }
        
        switch authError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            return "Неверный формат email"
        case AuthErrorCode.userNotFound.rawValue:
            return "Пользователь не найден"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Неверный пароль"
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "Email уже используется"
        case AuthErrorCode.weakPassword.rawValue:
            return "Пароль слишком слабый"
        case AuthErrorCode.networkError.rawValue:
            return "Ошибка сети. Проверьте подключение к интернету"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Слишком много запросов. Попробуйте позже"
        default:
            return authError.localizedDescription
        }
    }
}


