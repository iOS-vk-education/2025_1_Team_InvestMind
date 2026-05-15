import SwiftUI

struct PortfolioChartColors {

    // MARK: - ranked colors (top assets)

    private static let rankedPalette: [Color] = [
        Color(red: 0.20, green: 0.90, blue: 0.55), // green primary
        Color(red: 0.25, green: 0.70, blue: 1.00), // blue
        Color(red: 0.65, green: 0.45, blue: 1.00), // purple
        Color(red: 1.00, green: 0.60, blue: 0.20), // orange
        Color(red: 1.00, green: 0.35, blue: 0.35), // red
        Color(red: 0.20, green: 0.85, blue: 0.85), // cyan
        Color(red: 0.95, green: 0.85, blue: 0.25), // yellow
        Color(red: 0.85, green: 0.45, blue: 0.85), // pink
        Color(red: 0.35, green: 0.55, blue: 1.00)  // deep blue
    ]

    // MARK: - fixed color for "Other"

    static let otherColor: Color = Color(red: 0.55, green: 0.55, blue: 0.60)

    // MARK: - API

    static func colorByRank(_ rank: Int) -> Color {
        rankedPalette[min(rank, rankedPalette.count - 1)]
    }
}


struct PortfolioChartColors1 {

    private static let palette: [Color] = [
        Color(red: 0.45, green: 0.86, blue: 0.70),
        Color(red: 0.36, green: 0.69, blue: 0.98),
        Color(red: 1.00, green: 0.66, blue: 0.23),
        Color(red: 0.72, green: 0.45, blue: 0.98),
        Color(red: 1.00, green: 0.36, blue: 0.36),
        Color(red: 0.24, green: 0.80, blue: 0.94),
        Color(red: 0.98, green: 0.82, blue: 0.36),
        Color(red: 0.36, green: 0.98, blue: 0.82)
    ]

    // Фиксированные цвета для известных тикеров
    private static let fixed: [String: Color] = [
        "AAPL":  Color(red: 0.45, green: 0.86, blue: 0.70),
        "MSFT":  Color(red: 0.36, green: 0.69, blue: 0.98),
        "NVDA":  Color(red: 0.45, green: 0.86, blue: 0.70),
        "TSLA":  Color(red: 1.00, green: 0.36, blue: 0.36),
        "GOOGL": Color(red: 0.36, green: 0.69, blue: 0.98),
        "META":  Color(red: 0.36, green: 0.69, blue: 0.98),
        "AMZN":  Color(red: 1.00, green: 0.66, blue: 0.23),
        "NFLX":  Color(red: 1.00, green: 0.36, blue: 0.36),
        "INTC":  Color(red: 0.24, green: 0.80, blue: 0.94),
        "AMD":   Color(red: 0.72, green: 0.45, blue: 0.98),
        "BTC-USD": Color(red: 1.00, green: 0.60, blue: 0.20),
        "ETH-USD": Color(red: 0.55, green: 0.40, blue: 0.90)
    ]

    // Цвет по порядковому номеру актива в портфеле — гарантирует уникальность.
    static func color(at index: Int) -> Color {
        palette[index % palette.count]
    }

    static func color(for name: String) -> Color {
        fixed[name] ?? palette[abs(name.hashValue) % palette.count]
    }
}
