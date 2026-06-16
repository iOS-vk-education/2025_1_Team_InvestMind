

import SwiftUI

struct RegisterView: View {
    var onRegistered: () -> Void
    var onShowLogin: () -> Void
    
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var errors: [String: String] = [:]
    @State private var showErrors: [String: Bool] = [:]
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword
    }
    
    private var isFormValid: Bool {
        isValidEmail(email) &&
        !password.isEmpty && password.count >= 6 &&
        !confirmPassword.isEmpty && password == confirmPassword
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
                    
                    Text("Пройди регистрацию и начни свой путь инвестора!")
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
                                    .textContentType(.newPassword)
                                } else {
                                    SecureField(
                                        "",
                                        text: $password,
                                        prompt: Text("Пароль").foregroundStyle(Color.gray)
                                    )
                                    .textContentType(.newPassword)
                                }
                            }
                            .foregroundStyle(.black)
                            .focused($focusedField, equals: .password)
                            .id("password")
                            .onChange(of: password) { _, newPassword in
                                handlePasswordChange(newPassword)
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
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Поле повторения пароля
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color.gray)
                                .frame(width: 20)
                            
                            Group {
                                if isConfirmPasswordVisible {
                                    TextField(
                                        "",
                                        text: $confirmPassword,
                                        prompt: Text("Повторите пароль").foregroundStyle(Color.gray)
                                    )
                                    .textContentType(.newPassword)
                                } else {
                                    SecureField(
                                        "",
                                        text: $confirmPassword,
                                        prompt: Text("Повторите пароль").foregroundStyle(Color.gray)
                                    )
                                    .textContentType(.newPassword)
                                }
                            }
                            .foregroundStyle(.black)
                            .focused($focusedField, equals: .confirmPassword)
                            .id("confirmPassword")
                            .onChange(of: confirmPassword) { _, newConfirmPassword in
                                handleConfirmPasswordChange(newConfirmPassword)
                            }
                            
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(errors["confirmPassword"] != nil ? AppColors.danger : Color.clear, lineWidth: 1)
                        )
                        
                        if let confirmPasswordError = errors["confirmPassword"], showErrors["confirmPassword"] == true {
                            Text(confirmPasswordError)
                                .font(AppTypography.caption())
                                .foregroundStyle(AppColors.danger)
                                .padding(.leading, AppSpacing.md)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .animation(.easeInOut(duration: 0.2), value: showErrors["confirmPassword"] == true)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Кнопка Регистрация
                    Button(action: handleSubmit) {
                        Text("Зарегистрироваться")
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
                            HStack(spacing: 8) {
                                Image(systemName: "applelogo")
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
                    
                    // Есть аккаунт? Войти
                    Button(action: onShowLogin) {
                        Text("Есть аккаунт? Войти")
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
                                switch field {
                                case .email:
                                    proxy.scrollTo("email", anchor: .center)
                                case .password:
                                    proxy.scrollTo("password", anchor: .center)
                                case .confirmPassword:
                                    proxy.scrollTo("confirmPassword", anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func handlePasswordChange(_ newPassword: String) {
        if errors["password"] != nil {
            withAnimation {
                errors.removeValue(forKey: "password")
                showErrors["password"] = false
            }
        }
        
        // Если пароли не совпадают и confirmPassword заполнен, показываем ошибку
        if !confirmPassword.isEmpty && newPassword != confirmPassword {
            withAnimation {
                errors["confirmPassword"] = "Пароли не совпадают"
                showErrors["confirmPassword"] = true
            }
        } else if errors["confirmPassword"] == "Пароли не совпадают" {
            withAnimation {
                errors.removeValue(forKey: "confirmPassword")
                showErrors["confirmPassword"] = false
            }
        }
    }
    
    private func handleConfirmPasswordChange(_ newConfirmPassword: String) {
        if errors["confirmPassword"] != nil {
            if password == newConfirmPassword {
                withAnimation {
                    errors.removeValue(forKey: "confirmPassword")
                    showErrors["confirmPassword"] = false
                }
            }
        }
        
        // Проверяем совпадение паролей
        if !password.isEmpty && password != newConfirmPassword {
            withAnimation {
                errors["confirmPassword"] = "Пароли не совпадают"
                showErrors["confirmPassword"] = true
            }
        } else if password == newConfirmPassword && !newConfirmPassword.isEmpty {
            if errors["confirmPassword"] == "Пароли не совпадают" {
                withAnimation {
                    errors.removeValue(forKey: "confirmPassword")
                    showErrors["confirmPassword"] = false
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
                try await authService.signUp(email: email, password: password)
                
                // Успешная регистрация
                await MainActor.run {
                    onRegistered()
                }
            } catch {
                await MainActor.run {
                    // Показываем ошибку
                    if let errorMessage = authService.errorMessage {
                        if errorMessage.contains("уже используется") {
                            errors["email"] = "Этот email уже зарегистрирован"
                            showErrors["email"] = true
                        } else {
                            errors["email"] = errorMessage
                            showErrors["email"] = true
                        }
                    } else {
                        errors["email"] = "Ошибка регистрации. Попробуйте позже."
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
        
        if confirmPassword.isEmpty {
            errors["confirmPassword"] = "Повторите пароль"
            result = false
        } else if password != confirmPassword {
            errors["confirmPassword"] = "Пароли не совпадают"
            result = false
        }
        
        return result
    }
    
}
