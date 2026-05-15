import SwiftUI
import Charts

// MARK: - Donut Chart View

struct DonutChartView: View {
    
    let data: [PortfolioAssetChartData]
    
    private var chartData: [DonutItem] {
        data.groupedForDonutChart(thresholdPercent: 5)
    }

    var body: some View {
        Chart {
            ForEach(chartData) { item in
                
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(0.5),
                    angularInset: 1
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    Text(item.name)
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
            }
        }
        .chartLegend(.visible)
        .chartPlotStyle { plot in
            plot.padding(12)
        }
        .frame(height: 260)
    }
}

// MARK: - Model

struct DonutItem: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
    let rank: Int
}

// MARK: - Data processing

extension Array where Element == PortfolioAssetChartData {
    
    func groupedForDonutChart(thresholdPercent: Double = 5) -> [DonutItem] {
        let total = reduce(0) { $0 + $1.totalValue }
        guard total > 0 else { return [] }
        
        var mainItems: [(name: String, value: Double)] = []
        var otherValue: Double = 0
        
        for item in self {
            let percent = (item.totalValue / total) * 100
            
            if percent < thresholdPercent {
                otherValue += item.totalValue
            } else {
                mainItems.append((item.name, item.totalValue))
            }
        }
        
        // добавляем Other
        if otherValue > 0 {
            mainItems.append(("Other", otherValue))
        }
        
        // сортировка по убыванию
        let sorted = mainItems.sorted { $0.value > $1.value }
        
        return sorted.enumerated().map { index, item in
            
            let color: Color = (item.name == "Other")
                ? PortfolioChartColors.otherColor
                : PortfolioChartColors.colorByRank(index)
            
            return DonutItem(
                name: item.name,
                value: item.value,
                color: color,
                rank: index
            )
        }
    }
}
