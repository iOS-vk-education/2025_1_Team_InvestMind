//
//  ProfileViewController.swift
//  InvestMind
//
//  Created by Auto on 2025.
//

import UIKit

class ProfileViewController: UIViewController {

    var authService: AuthService?
    var onSignOut: (() -> Void)?

    var selectedThemeRawValue: String = AppTheme.system.rawValue {
        didSet {
            applyTheme()
            updateThemeControlSelection()
        }
    }
    
    var email: String? {
        didSet {
            emailLabel.text = email ?? ""
        }
    }

    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Профиль"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        // Заглушка для изображения профиля - градиент или текстурированное изображение
        return imageView
    }()
    
    private func setupProfileImage() {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = [
                UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 1.0).cgColor,
                UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0).cgColor,
                UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0).cgColor
            ]
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 0.5, 1.0]) {
                context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            }
            // Добавляем простой паттерн для текстуры
            context.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.1).cgColor)
            for i in 0..<5 {
                for j in 0..<5 {
                    if (i + j) % 2 == 0 {
                        context.cgContext.fillEllipse(in: CGRect(x: CGFloat(i) * 20, y: CGFloat(j) * 20, width: 10, height: 10))
                    }
                }
            }
        }
        profileImageView.image = image
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Команда"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private let signOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Выйти", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        return button
    }()

    private let deleteAccountButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Удалить учётную запись"
        config.baseForegroundColor = .systemRed
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let themeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Тема"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private let themeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Система", "Светлая", "Тёмная"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupProfileImage()
        updateThemeControlSelection()
        applyTheme()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1.0)
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(themeTitleLabel)
        contentView.addSubview(themeSegmentedControl)
        contentView.addSubview(signOutButton)
        contentView.addSubview(deleteAccountButton)

        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        themeSegmentedControl.addTarget(self, action: #selector(themeChanged), for: .valueChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Profile image
            profileImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            // Email label
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            themeTitleLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            themeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            themeTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            themeSegmentedControl.topAnchor.constraint(equalTo: themeTitleLabel.bottomAnchor, constant: 12),
            themeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            themeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            signOutButton.topAnchor.constraint(equalTo: themeSegmentedControl.bottomAnchor, constant: 24),
            signOutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            signOutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            signOutButton.heightAnchor.constraint(equalToConstant: 52),

            deleteAccountButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 16),
            deleteAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 52),
            deleteAccountButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    // MARK: - Actions

    @objc private func signOutTapped() {
        onSignOut?()
    }

    @objc private func deleteAccountTapped() {
        showDeleteAccountConfirmation()
    }

    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Удалить учётную запись",
            message: "Это действие необратимо. Все данные будут удалены. Введите пароль для подтверждения.",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Пароль"
            textField.isSecureTextEntry = true
            textField.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self,
                  let password = alert.textFields?.first?.text,
                  !password.isEmpty else {
                self?.showErrorAlert(message: "Введите пароль")
                return
            }
            self.performAccountDeletion(password: password)
        })
        present(alert, animated: true)
    }

    private func performAccountDeletion(password: String) {
        guard let authService = authService else { return }
        let loadingAlert = UIAlertController(title: "Удаление...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)

        Task { @MainActor in
            do {
                try await authService.deleteAccount(password: password)
                loadingAlert.dismiss(animated: true)
            } catch {
                loadingAlert.dismiss(animated: true)
                showErrorAlert(message: authService.errorMessage ?? "Не удалось удалить аккаунт")
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func themeChanged() {
        let newTheme: AppTheme
        switch themeSegmentedControl.selectedSegmentIndex {
        case 1:
            newTheme = .light
        case 2:
            newTheme = .dark
        default:
            newTheme = .system
        }

        UserDefaults.standard.set(newTheme.rawValue, forKey: "selectedTheme")
        selectedThemeRawValue = newTheme.rawValue
    }

    private func updateThemeControlSelection() {
        let theme = AppTheme(rawValue: selectedThemeRawValue) ?? .system
        switch theme {
        case .system:
            themeSegmentedControl.selectedSegmentIndex = 0
        case .light:
            themeSegmentedControl.selectedSegmentIndex = 1
        case .dark:
            themeSegmentedControl.selectedSegmentIndex = 2
        }
    }

    func applyTheme() {
        guard isViewLoaded else { return }

        let selectedTheme = AppTheme(rawValue: selectedThemeRawValue) ?? .system
        let isDark: Bool

        switch selectedTheme {
        case .dark:
            isDark = true
        case .light:
            isDark = false
        case .system:
            isDark = traitCollection.userInterfaceStyle == .dark
        }

        if isDark {
            view.backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1.0)
            contentView.backgroundColor = .clear
            titleLabel.textColor = .white
            nameLabel.textColor = .white
            emailLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            themeTitleLabel.textColor = .white

            themeSegmentedControl.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1.0)
            themeSegmentedControl.selectedSegmentTintColor = UIColor(red: 0.78, green: 0.80, blue: 0.84, alpha: 1.0)
            themeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            themeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)

            signOutButton.backgroundColor = UIColor(red: 0.25, green: 0.27, blue: 0.35, alpha: 1.0)
            signOutButton.setTitleColor(.white, for: .normal)
        } else {
            view.backgroundColor = .systemBackground
            contentView.backgroundColor = .clear
            titleLabel.textColor = .label
            nameLabel.textColor = .label
            emailLabel.textColor = .secondaryLabel
            themeTitleLabel.textColor = .label

            themeSegmentedControl.backgroundColor = .secondarySystemBackground
            themeSegmentedControl.selectedSegmentTintColor = .systemBackground
            themeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
            themeSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)

            signOutButton.backgroundColor = .secondarySystemBackground
            signOutButton.setTitleColor(.label, for: .normal)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            let theme = AppTheme(rawValue: selectedThemeRawValue) ?? .system
            if theme == .system {
                applyTheme()
            }
        }
    }
}

