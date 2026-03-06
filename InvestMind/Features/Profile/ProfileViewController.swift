//
//  ProfileViewController.swift
//  InvestMind
//
//  Created by Auto on 2025.
//

import UIKit

class ProfileViewController: UIViewController {

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        label.text = "team@mail.ru"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private let inviteFriendsCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let inviteIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor(red: 0.36, green: 0.69, blue: 0.98, alpha: 1.0)
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        if let image = UIImage(systemName: "dollarsign.circle.fill") {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
            imageView.image = image.withConfiguration(config)
            imageView.tintColor = .white
        }
        return imageView
    }()
    
    private let inviteTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Пригласи друзей"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let inviteSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Пригласи друзей 3-x и получи скидку на подписку в 20%"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private let inviteArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        return imageView
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Menu Items
    
    private lazy var menuItems: [MenuItem] = [
        MenuItem(icon: "person.fill", title: "Акаунт"),
        MenuItem(icon: "hand.raised.fill", title: "Безопасность"),
        MenuItem(icon: "creditcard.fill", title: "Покупки"),
        MenuItem(icon: "textformat", title: "Язык", subtitle: "Русский"),
        MenuItem(icon: "gearshape.fill", title: "Настройки"),
        MenuItem(icon: "questionmark.circle.fill", title: "FAQ"),
        MenuItem(icon: "trash.fill", title: "Удалить аккаунт", subtitle: nil, isDestructive: true)
    ]
    
    struct MenuItem {
        let icon: String
        let title: String
        let subtitle: String?
        let isDestructive: Bool

        init(icon: String, title: String, subtitle: String? = nil, isDestructive: Bool = false) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.isDestructive = isDestructive
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupProfileImage()
        updateAuthState()
    }

    /// Обновляет отображение email/имени из текущего пользователя AuthService
    func updateAuthState() {
        if let email = authService.currentUser?.email {
            emailLabel.text = email
        }
        if let displayName = authService.currentUser?.displayName, !displayName.isEmpty {
            nameLabel.text = displayName
        } else if let email = authService.currentUser?.email {
            nameLabel.text = email.components(separatedBy: "@").first ?? "Пользователь"
        }
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
        contentView.addSubview(inviteFriendsCard)
        contentView.addSubview(menuTableView)
        
        inviteFriendsCard.addSubview(inviteIconView)
        inviteFriendsCard.addSubview(inviteTitleLabel)
        inviteFriendsCard.addSubview(inviteSubtitleLabel)
        inviteFriendsCard.addSubview(inviteArrowImageView)
        
        // Setup table view
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "MenuCell")
        
        // Add tap gesture to invite friends card
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(inviteFriendsTapped))
        inviteFriendsCard.addGestureRecognizer(tapGesture)
        inviteFriendsCard.isUserInteractionEnabled = true
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
            
            // Invite friends card
            inviteFriendsCard.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 24),
            inviteFriendsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            inviteFriendsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            inviteFriendsCard.heightAnchor.constraint(equalToConstant: 80),
            
            // Invite icon
            inviteIconView.centerYAnchor.constraint(equalTo: inviteFriendsCard.centerYAnchor),
            inviteIconView.leadingAnchor.constraint(equalTo: inviteFriendsCard.leadingAnchor, constant: 16),
            inviteIconView.widthAnchor.constraint(equalToConstant: 50),
            inviteIconView.heightAnchor.constraint(equalToConstant: 50),
            
            // Invite title
            inviteTitleLabel.topAnchor.constraint(equalTo: inviteIconView.topAnchor, constant: 4),
            inviteTitleLabel.leadingAnchor.constraint(equalTo: inviteIconView.trailingAnchor, constant: 16),
            inviteTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: inviteArrowImageView.leadingAnchor, constant: -8),
            
            // Invite subtitle
            inviteSubtitleLabel.topAnchor.constraint(equalTo: inviteTitleLabel.bottomAnchor, constant: 4),
            inviteSubtitleLabel.leadingAnchor.constraint(equalTo: inviteTitleLabel.leadingAnchor),
            inviteSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: inviteArrowImageView.leadingAnchor, constant: -8),
            
            // Invite arrow
            inviteArrowImageView.centerYAnchor.constraint(equalTo: inviteFriendsCard.centerYAnchor),
            inviteArrowImageView.trailingAnchor.constraint(equalTo: inviteFriendsCard.trailingAnchor, constant: -16),
            
            // Menu table view
            menuTableView.topAnchor.constraint(equalTo: inviteFriendsCard.bottomAnchor, constant: 24),
            menuTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            menuTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            menuTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            menuTableView.heightAnchor.constraint(equalToConstant: CGFloat(menuItems.count * 60))
        ])
    }
    
    // MARK: - Actions
    
    @objc private func inviteFriendsTapped() {
        
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuTableViewCell
        let item = menuItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = menuItems[indexPath.row]
        if item.isDestructive && item.title == "Удалить аккаунт" {
            showDeleteAccountConfirmation()
            return
        }
        print("Selected: \(item.title)")
        // Handle menu item selection
    }

    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Удалить аккаунт",
            message: "Это действие необратимо. Все данные будут удалены. Введите ваш пароль для подтверждения.",
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
        let loadingAlert = UIAlertController(title: "Удаление...", message: nil, preferredStyle: .alert)
        present(loadingAlert, animated: true)

        Task { @MainActor in
            do {
                try await authService.deleteAccount(password: password)
                loadingAlert.dismiss(animated: true)
                // После удаления isAuthenticated = false, ContentView вернёт на экран входа
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
}

// MARK: - MenuTableViewCell

class MenuTableViewCell: UITableViewCell {
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1.0)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.white.withAlphaComponent(0.7)
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 40),
            iconContainerView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            subtitleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            subtitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 8),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    func configure(with item: ProfileViewController.MenuItem) {
        if let image = UIImage(systemName: item.icon) {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            iconImageView.image = image.withConfiguration(config)
            iconImageView.tintColor = item.isDestructive ? .systemRed : .white
        }
        titleLabel.text = item.title
        titleLabel.textColor = item.isDestructive ? .systemRed : .white
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil
    }
}

