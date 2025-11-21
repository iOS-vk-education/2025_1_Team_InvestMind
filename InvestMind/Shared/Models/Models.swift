
import Foundation
import SwiftUI

struct Asset: Identifiable, Hashable {
    enum Trend: Equatable, Hashable {
        case up(Double)
        case down(Double)

        var value: Double {
            switch self {
            case .up(let value), .down(let value):
                return value
            }
        }

        var isPositive: Bool {
            if case .up = self { return true }
            return false
        }
    }

    let id = UUID()
    let ticker: String
    let name: String
    let price: Double
    let change: Trend
    let icon: String
}

struct PortfolioAsset: Identifiable, Hashable {
    let id = UUID()
    let asset: Asset
    let amount: Double
    let invested: Double

    var profit: Double {
        amount * asset.price - invested
    }
}

struct PortfolioSummary : Hashable {
    let totalValue: Double
    let invested: Double
    let dailyChange: Double
}

struct UserPortfolio: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let summary: PortfolioSummary
    let assets: [PortfolioAsset]
}

struct GuideStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let showsAuthActions: Bool
}

enum AppRoute: Hashable {
    case stockDetail(Asset)
    case portfolioDetail(UserPortfolio)
}

enum FlowStep {
    case splash
    case onboarding
    case survey
    case auth
    case register
    case postAuthGuide
    case main
}

enum MockData {
    static let assets: [Asset] = [
        Asset(ticker: "AAPL", name: "Apple", price: 189.54, change: .up(2.31), icon: "applelogo"),
        Asset(ticker: "MSFT", name: "Microsoft", price: 378.85, change: .up(1.12), icon: "desktopcomputer"),
        Asset(ticker: "GOOGL", name: "Alphabet Class A", price: 132.67, change: .down(0.84), icon: "globe"),
        Asset(ticker: "NVDA", name: "NVIDIA", price: 492.65, change: .up(4.54), icon: "cpu.fill"),
        Asset(ticker: "AMD", name: "Advanced Micro Devices", price: 117.42, change: .down(1.77), icon: "memorychip"),

        Asset(ticker: "TSLA", name: "Tesla", price: 247.12, change: .down(1.14), icon: "bolt.fill"),
        Asset(ticker: "F", name: "Ford Motor Company", price: 10.92, change: .up(0.41), icon: "car.fill"),
        Asset(ticker: "TM", name: "Toyota Motor Corp", price: 188.73, change: .up(0.92), icon: "car.2.fill"),

        Asset(ticker: "AMZN", name: "Amazon", price: 136.44, change: .up(1.92), icon: "cart.fill"),
        Asset(ticker: "WMT", name: "Walmart", price: 158.17, change: .down(0.22), icon: "cart.circle.fill"),

        Asset(ticker: "NFLX", name: "Netflix", price: 455.18, change: .up(0.78), icon: "film.fill"),
        Asset(ticker: "DIS", name: "Walt Disney Company", price: 91.53, change: .down(0.41), icon: "sparkles"),

        Asset(ticker: "JPM", name: "JPMorgan Chase", price: 147.66, change: .up(0.57), icon: "banknote.fill"),
        Asset(ticker: "V", name: "Visa Inc", price: 248.91, change: .up(0.89), icon: "creditcard.fill"),

        Asset(ticker: "XOM", name: "Exxon Mobil", price: 102.24, change: .down(1.12), icon: "flame.fill")
    ]

    static let portfolioAssets: [PortfolioAsset] = [
        PortfolioAsset(asset: assets[0], amount: 20, invested: 3000),
        PortfolioAsset(asset: assets[1], amount: 8, invested: 1500),
        PortfolioAsset(asset: assets[2], amount: 5, invested: 2000)
    ]

    static let portfolioSummary = PortfolioSummary(
        totalValue: 12450,
        invested: 9800,
        dailyChange: 2.4
    )
    
    static let userPortfolios: [UserPortfolio] = [
            UserPortfolio(
                name: "Основной портфель",
                summary: portfolioSummary,
                assets: portfolioAssets
            ),
            UserPortfolio(
                name: "Технологии",
                summary: PortfolioSummary(
                    totalValue: 5500,
                    invested: 4200,
                    dailyChange: 1.1
                ),
                assets: [
                    PortfolioAsset(asset: assets[0], amount: 10, invested: 1500),
                    PortfolioAsset(asset: assets[4], amount: 3, invested: 2500)
                ]
            )
        ]

    static let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Увеличьте свою\nприбыль",
            subtitle: "Раскройте потенциал прибыли для финансового роста",
            showsAuthActions: false
        ),
        OnboardingPage(
            title: "Начните торговлю\nакциями",
            subtitle: "Оптимизируйте инвестиционные решения с помощью квалифицированных рекомендаций",
            showsAuthActions: true
        )
    ]

    static let postAuthGuide: [GuideStep] = [
        GuideStep(title: "Главная", description: "Сводка рынка и персональные рекомендации.", iconName: "house.fill"),
        GuideStep(title: "Портфель", description: "Детальные данные по активам и прибыли.", iconName: "briefcase.fill"),
        GuideStep(title: "Профиль", description: "Настройки, подписки и поддержка.", iconName: "person.crop.circle.fill")
    ]
}

extension Array where Element == UserPortfolio {
    var combinedSummary: PortfolioSummary {
        let totalValue = self.map { $0.summary.totalValue }.reduce(0, +)
        let invested = self.map { $0.summary.invested }.reduce(0, +)
        let dailyChange = self.map { $0.summary.dailyChange }.reduce(0, +)
        return PortfolioSummary(totalValue: totalValue,
                                invested: invested,
                                dailyChange: dailyChange)
    }
}

