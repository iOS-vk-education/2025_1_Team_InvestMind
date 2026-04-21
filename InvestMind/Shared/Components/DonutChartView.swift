import SwiftUI
import Charts

struct DonutChartView: View {
    let data: [PortfolioAssetChartData]

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                SectorMark(
                    angle: .value("Value", item.totalValue),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(PortfolioChartColors.color(at: index))
                .annotation(position: .overlay) {
                    Text(item.name)
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
            }
        }
        .chartLegend(.visible)
        .chartPlotStyle { plot in plot.padding(16) }
        .frame(height: 260)
    }
}
