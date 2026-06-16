import SwiftUI
import UIKit
import Foundation

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppColors {

    static let backgroundPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
            : UIColor.systemBackground
    })

    static let backgroundSecondary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1)
            : UIColor.secondarySystemBackground
    })
    
    static let authOverlay = Color(red: 0.04, green: 0.05, blue: 0.09).opacity(0.75)

    static let accentPrimary = Color(red: 0.36, green: 0.69, blue: 0.98)
    static let accentSecondary = Color(red: 0.45, green: 0.86, blue: 0.70)

    static let buttonPrimary = Color("ButtonPrimaryColor")
    static let buttonSecondary = Color("ButtonSecondaryColor")

    static let warning = Color(red: 1.00, green: 0.66, blue: 0.23)
    static let danger = Color(red: 1.00, green: 0.36, blue: 0.36)
    
    static let authTextSecondary = Color.white.opacity(0.7)

    static let textPrimary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? .white
            : UIColor.label
    })

    static let textSecondary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.7)
            : UIColor.secondaryLabel
    })

    static let textTertiary = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.5)
            : UIColor.tertiaryLabel
    })

    static let border = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.1)
            : UIColor.separator
    })

    static let cardShadow = Color.black.opacity(0.15)
}

enum AppGradients {
    static let brand = LinearGradient(
        colors: [
            Color(red: 0.42, green: 0.27, blue: 0.98),
            Color(red: 0.24, green: 0.80, blue: 0.94)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AppTypography {
    static func logo(size: CGFloat = 28) -> Font {
            return Font.custom("Philosopher-Bold", size: size)
        }
    
    // SF Pro для остального текста
    static func largeTitle(weight: Font.Weight = .bold) -> Font {
        Font.system(size: 34, weight: weight, design: .default)
    }

    static func title(weight: Font.Weight = .semibold) -> Font {
        Font.system(size: 28, weight: weight, design: .default)
    }

    static func headline(weight: Font.Weight = .semibold) -> Font {
        Font.system(size: 20, weight: weight, design: .default)
    }

    static func body(weight: Font.Weight = .regular) -> Font {
        Font.system(size: 16, weight: weight, design: .default)
    }

    static func caption(weight: Font.Weight = .medium) -> Font {
        Font.system(size: 13, weight: weight, design: .default)
    }
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

