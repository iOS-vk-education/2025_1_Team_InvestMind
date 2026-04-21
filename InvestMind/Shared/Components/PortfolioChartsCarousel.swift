import SwiftUI

struct PortfolioChartsCarousel: View {
    let assets: [PortfolioAssetChartData]

    var body: some View {
        DonutChartView(data: assets)
            .padding()
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
