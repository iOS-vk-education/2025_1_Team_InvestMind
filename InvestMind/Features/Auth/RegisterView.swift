

import SwiftUI

struct RegisterView: View {
    var onRegistered: () -> Void
    var onShowLogin: () -> Void

    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var errors: [String: String] = [:]
    @State private var showErrors: [String: Bool] = [:]
    @State private var isLoading = false
    @FocusState private var focusedField: Field?

    enum Field {
        case phone, password, confirmPassword
    }

    private var isFormValid: Bool {
        PhoneFormatter.isValid(phone) &&
        !password.isEmpty && password.count >= 6 &&
        !confirmPassword.isEmpty && password == confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        Spacer(minLength: 60)
                        
                        Text("Пройди регистрацию и начни свой путь инвестора!")
                            .multilineTextAlignment(.center)
                            .font(AppTypography.title(weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.lg)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            // Поле номера телефона
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "phone.fill")
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 20)
                                
                                TextField("Номер телефона", text: $phone)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .foregroundStyle(.black)
                                    .focused($focusedField, equals: .phone)
                                    .onChange(of: phone) { _, newValue in
                                        phone = PhoneFormatter.format(newValue)

                                        if errors["phone"] != nil {
                                            withAnimation {
                                                errors.removeValue(forKey: "phone")
                                                showErrors["phone"] = false
                                            }
                                        }
                                    }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(errors["phone"] != nil ? AppColors.danger : Color.clear, lineWidth: 1)
                            )
                            
                            if let phoneError = errors["phone"], showErrors["phone"] == true {
                                Text(phoneError)
                                    .font(AppTypography.caption())
                                    .foregroundStyle(AppColors.danger)
                                    .padding(.leading, AppSpacing.md)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                    .animation(.easeInOut(duration: 0.2), value: showErrors["phone"] == true)
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
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Пароль", text: $password)
                                            .textContentType(.newPassword)
                                    }
                                }
                                .foregroundStyle(.black)
                                .focused($focusedField, equals: .password)
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
                                        TextField("Повторите пароль", text: $confirmPassword)
                                            .textContentType(.newPassword)
                                    } else {
                                        SecureField("Повторите пароль", text: $confirmPassword)
                                            .textContentType(.newPassword)
                                    }
                                }
                                .foregroundStyle(.black)
                                .focused($focusedField, equals: .confirmPassword)
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
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isLoading = false
            onRegistered()
        }
    }

    private func validate() -> Bool {
        var result = true
        if !PhoneFormatter.isValid(phone) {
            errors["phone"] = "Введите корректный номер телефона"
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
