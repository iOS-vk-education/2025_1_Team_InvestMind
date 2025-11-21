

import SwiftUI

struct AuthView: View {
    var onAuthenticated: () -> Void
    var onShowRegister: () -> Void

    @State private var login = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errors: [String: String] = [:]
    @State private var showErrors: [String: Bool] = [:]
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field {
        case login, password
    }

    private var isFormValid: Bool {
        PhoneFormatter.isValid(login) &&
        !password.isEmpty && password.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                       .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        Spacer(minLength: 60)
                        
                        Text("Войди и продолжи свой путь инвестора!")
                            .multilineTextAlignment(.center)
                            .font(AppTypography.title(weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.lg)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            // Поле логина
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 20)
                                
                                TextField("Номер телефона", text: $login)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .foregroundStyle(.black)
                                    .focused($focusedField, equals: .login)
                                    .onChange(of: login) { _, newValue in
                                        login = PhoneFormatter.format(newValue)

                                        if errors["login"] != nil {
                                            withAnimation {
                                                errors.removeValue(forKey: "login")
                                                showErrors["login"] = false
                                            }
                                        }
                                    }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(errors["login"] != nil ? AppColors.danger : Color.clear, lineWidth: 1)
                            )
                            
                            if let loginError = errors["login"], showErrors["login"] == true {
                                Text(loginError)
                                    .font(AppTypography.caption())
                                    .foregroundStyle(AppColors.danger)
                                    .padding(.leading, AppSpacing.md)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.2), value: showErrors["login"] == true)
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
                                    TextField("Пароль", text: $password)
                                        .textContentType(.password)
                                } else {
                                    SecureField("Пароль", text: $password)
                                        .textContentType(.password)
                                }
                            }
                            .foregroundStyle(.black)
                            .focused($focusedField, equals: .password)
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
                    Button(action: {}) {
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
                        .disabled(isLoading)
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
                    
                    Spacer(minLength: 60)
                }
                .padding(.vertical, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("InvestMind")
                        .font(AppTypography.logo())
                        .foregroundStyle(.white)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
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
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            onAuthenticated()
        }
    }

    private func validate() -> Bool {
        var result = true
        if !PhoneFormatter.isValid(login) {
            errors["login"] = "Введите корректный номер телефона"
            result = false
        }
        if password.isEmpty || password.count < 6 {
            errors["password"] = "Минимум 6 символов"
            result = false
        }

        return result
    }
}


