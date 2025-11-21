import SwiftUI
import UIKit
import Foundation

enum AppColors {
    static let backgroundPrimary = Color(red: 0.04, green: 0.05, blue: 0.09)
    static let backgroundSecondary = Color(red: 0.09, green: 0.11, blue: 0.17)
    static let accentPrimary = Color(red: 0.36, green: 0.69, blue: 0.98)
    static let accentSecondary = Color(red: 0.45, green: 0.86, blue: 0.70)
    static let buttonPrimary = Color("ButtonPrimaryColor")
    static let buttonSecondary = Color("ButtonSecondaryColor")
    static let warning = Color(red: 1.00, green: 0.66, blue: 0.23)
    static let danger = Color(red: 1.00, green: 0.36, blue: 0.36)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.45)
    static let border = Color.white.opacity(0.1)
    static let cardShadow = Color.black.opacity(0.35)
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

