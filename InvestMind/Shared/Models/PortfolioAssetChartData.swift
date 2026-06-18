import SwiftUI

enum AssetKind {
    case stock
    case metal
    case currency
}

struct PortfolioAssetChartData: Identifiable {
    let id = UUID()
    let name: String
    let kind: AssetKind
    let quantity: Double
    let price: Double

    var totalValue: Double { quantity * price }
}
