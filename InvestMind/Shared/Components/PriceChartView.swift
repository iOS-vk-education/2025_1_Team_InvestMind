import SwiftUI
import Charts

enum ChartPeriodType {
    case oneMonth, threeMonths, sixMonths, oneYear

    static func detect(by count: Int) -> ChartPeriodType {
        let variants: [(Int, ChartPeriodType)] = [
            (30,  .oneMonth),
            (90,  .threeMonths),
            (180, .sixMonths),
            (360, .oneYear)
        ]
        return variants.min { abs($0.0 - count) < abs($1.0 - count) }!.1
    }
}

private struct ChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}

struct PriceChartView: View {

    let prices: [Double]

    var chartHeight: CGFloat = 220
    var backgroundColor: Color = AppColors.backgroundSecondary
    var cornerRadius: CGFloat = 24
    var chartPadding = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    var axisGridColor: Color = AppColors.border
    var axisLabelColor: Color = AppColors.textSecondary
    var defaultLineColor: Color = AppColors.accentPrimary
    var interpolationMethod: InterpolationMethod = .catmullRom

    private var period: ChartPeriodType {
        ChartPeriodType.detect(by: prices.count)
    }

    private var points: [ChartPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return prices.enumerated().map { index, price in
            let daysAgo = prices.count - 1 - index
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return ChartPoint(date: date, price: price)
        }
    }

    // Зелёный при росте, красный при падении
    private var lineColor: Color {
        guard let first = prices.first, let last = prices.last else {
            return defaultLineColor
        }
        if last > first { return AppColors.incrValue }
        if last < first { return AppColors.decrValue }
        return defaultLineColor
    }

    // Метки оси X — справа налево
    private var xAxisDates: [Date] {
        guard let firstDate = points.first?.date else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var dates: [Date] = []
        var current = today

        while current > firstDate {
            dates.append(current)

            switch period {
            case .oneMonth:
                current = calendar.date(byAdding: .weekOfYear, value: -1, to: current)!
            case .threeMonths, .sixMonths:
                current = calendar.date(byAdding: .month, value: -1, to: current)!
            case .oneYear:
                current = calendar.date(byAdding: .month, value: -4, to: current)!
            }
        }

        dates.append(firstDate)
        return dates
    }

    private func label(for date: Date) -> String {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let month = monthFormatter.string(from: date)

        switch period {
        case .oneMonth:             return "\(day)"
        case .threeMonths, .sixMonths, .oneYear: return month
        }
    }

    var body: some View {
        Group {
            if prices.isEmpty {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(0.5))
                    .frame(height: chartHeight)
                    .padding(chartPadding)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.price)
                    )
                    .interpolationMethod(interpolationMethod)
                    .foregroundStyle(lineColor)
                }
                .chartXAxis {
                    AxisMarks(values: xAxisDates) { value in
                        AxisGridLine().foregroundStyle(axisGridColor)
                        AxisTick()
                        if let date = value.as(Date.self),
                           date != Calendar.current.startOfDay(for: Date()) {
                            AxisValueLabel {
                                Text(label(for: date))
                                    .foregroundStyle(axisLabelColor)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(axisGridColor)
                        AxisValueLabel().foregroundStyle(axisLabelColor)
                    }
                }
                .chartXScale(range: .plotDimension(padding: 0))
                .chartPlotStyle { plotArea in
                    plotArea.padding(.horizontal, 0)
                }
                .frame(height: chartHeight)
                .padding(chartPadding)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        }
    }
}
