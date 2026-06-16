

import SwiftUI

struct AuthView: View {
    var onAuthenticated: () -> Void
    var onShowRegister: () -> Void

    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errors: [String: String] = [:]
    @State private var showErrors: [String: Bool] = [:]
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    private var isFormValid: Bool {
        isValidEmail(email) &&
        !password.isEmpty && password.count >= 6
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        ZStack {
            Image("BackgroundOnboardImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            AppColors.authOverlay
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        Text("InvestMind")
                            .font(AppTypography.logo())
                            .foregroundStyle(.white)
                            .padding(.top, AppSpacing.lg)
                            .id("top")
                    
                    Text("Войди и продолжи свой путь инвестора!")
                            .multilineTextAlignment(.center)
                            .font(AppTypography.title(weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.lg)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            // Поле email
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 20)
                                
                                TextField(
                                    "",
                                    text: $email,
                                    prompt: Text("Email").foregroundStyle(Color.gray)
                                )
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .foregroundStyle(.black)
                                    .focused($focusedField, equals: .email)
                                    .id("email")
                                    .onChange(of: email) { _, newValue in
                                        if errors["email"] != nil {
                                            withAnimation {
                                                errors.removeValue(forKey: "email")
                                                showErrors["email"] = false
                                            }
                                        }
                                    }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(errors["email"] != nil ? AppColors.danger : Color.clear, lineWidth: 1)
                            )
                            
                            if let emailError = errors["email"], showErrors["email"] == true {
                                Text(emailError)
                                    .font(AppTypography.caption())
                                    .foregroundStyle(AppColors.danger)
                                    .padding(.leading, AppSpacing.md)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.2), value: showErrors["email"] == true)
                            }

                        }
                        .padding(.horizontal, AppSpacing.lg)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Поле пароля
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color.gray)
                                .frame(width: 20)
                            
                            Group {
                                if isPasswordVisible {
                                    TextField(
                                        "",
                                        text: $password,
                                        prompt: Text("Пароль").foregroundStyle(Color.gray)
                                    )
                                    .textContentType(.password)
                                } else {
                                    SecureField(
                                        "",
                                        text: $password,
                                        prompt: Text("Пароль").foregroundStyle(Color.gray)
                                    )
                                    .textContentType(.password)
                                }
                            }
                            .foregroundStyle(.black)
                            .focused($focusedField, equals: .password)
                            .id("password")
                            .onChange(of: password) { _, _ in
                                if errors["password"] != nil {
                                    withAnimation {
                                        errors.removeValue(forKey: "password")
                                        showErrors["password"] = false
                                    }
                                }
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(errors["password"] != nil ? AppColors.danger : Color.clear, lineWidth: 1)
                        )
                        
                        if let passwordError = errors["password"], showErrors["password"] == true {
                            Text(passwordError)
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.danger)
                                .padding(.leading, AppSpacing.md)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.2), value: showErrors["password"] == true)
                        }

                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Забыли пароль
                    Button(action: {
                        handleForgotPassword()
                    }) {
                        Text("Забыли пароль?")
                            .font(AppTypography.body(weight: .medium))
                            .foregroundStyle(.white)
                    }
                    
                    // Кнопка Войти
                        // Кнопка Войти
                        Button(action: handleSubmit) {
                            Text("Войти")
                                .font(AppTypography.headline())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                                .background(AppColors.buttonPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .disabled(authService.isLoading)
                        .padding(.horizontal, AppSpacing.lg)

                    
                    // Разделитель
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("Войти")
                            .font(AppTypography.caption())
                            .foregroundStyle(Color.white.opacity(0.7))
                            .padding(.horizontal, AppSpacing.sm)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    
                    // Кнопки социальных сетей
                    VStack(spacing: AppSpacing.md) {
                        // VK
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image("VK")
                                    .font(.title3)

                                Text("Продолжить с Вконтакте")
                                    .font(AppTypography.body(weight: .medium))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        
                        // Apple
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundStyle(.black)
                                    .font(.title3)
                                Text("Продолжить с Apple")
                                    .font(AppTypography.body(weight: .medium))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Нет аккаунта? Регистрация
                    Button(action: onShowRegister) {
                        Text("Нет аккаунта? Регистрация")
                            .font(AppTypography.body(weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.bottom, AppSpacing.xl)
                    
                    }
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                    .safeAreaInset(edge: .bottom) {
                        Color.clear
                            .frame(height: focusedField != nil ? 20 : 0)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newField in
                    if let field = newField {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(field == .email ? "email" : "password", anchor: .center)
                            }
                        }
                    }
                }
            }
        }
    }

    private func handleSubmit() {
        errors.removeAll()
        showErrors = [:]
        guard validate() else {
            // Анимируем появление ошибок
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                for key in errors.keys {
                    showErrors[key] = true
                }
            }
            return
        }
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                
                // Успешный вход
                await MainActor.run {
                    onAuthenticated()
                }
            } catch {
                await MainActor.run {
                    // Показываем ошибку
                    if let errorMessage = authService.errorMessage {
                        errors["email"] = errorMessage
                        showErrors["email"] = true
                    } else {
                        errors["email"] = "Ошибка входа. Проверьте данные."
                        showErrors["email"] = true
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        for key in errors.keys {
                            showErrors[key] = true
                        }
                    }
                }
            }
        }
    }

    private func validate() -> Bool {
        var result = true
        if email.isEmpty {
            errors["email"] = "Введите email"
            result = false
        } else if !isValidEmail(email) {
            errors["email"] = "Введите корректный email"
            result = false
        }
        if password.isEmpty || password.count < 6 {
            errors["password"] = "Минимум 6 символов"
            result = false
        }

        return result
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty && isValidEmail(email) else {
            errors["email"] = "Введите корректный email"
            showErrors["email"] = true
            return
        }
        
        Task {
            do {
                try await authService.resetPassword(email: email)
                // Показываем сообщение об успехе (можно добавить alert)
            } catch {
                await MainActor.run {
                    if let errorMessage = authService.errorMessage {
                        errors["email"] = errorMessage
                        showErrors["email"] = true
                    }
                }
            }
        }
    }
}


