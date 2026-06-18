import SwiftUI
import Charts

// MARK: - Period detection

enum ChartPeriodType {
    case oneMonth, threeMonths, sixMonths, oneYear

    static func detect(by count: Int) -> ChartPeriodType {
        let variants: [(Int, ChartPeriodType)] = [
            (30, .oneMonth), (90, .threeMonths), (180, .sixMonths), (360, .oneYear)
        ]
        return variants.min { abs($0.0 - count) < abs($1.0 - count) }!.1
    }
}

// MARK: - Y scaling mode

enum ChartYScaling: Equatable {
    case minMax
    case zero
    case padded(fraction: Double)
    static var paddedDefault: ChartYScaling { .padded(fraction: 0.15) }
}

// MARK: - Data point

private struct ChartPoint: Identifiable, Equatable {
    let id = UUID()
    let index: Int
    let date: Date
    let price: Double
}

// MARK: - Chart View

struct PriceChartView: View {

    // Input
    let prices: [Double]

    // Configuration
    var scaling: ChartYScaling = .paddedDefault
    var showAreaGradient: Bool = true

    // Appearance
    var chartHeight: CGFloat = 220
    var backgroundColor: Color = AppColors.backgroundSecondary
    var cornerRadius: CGFloat = 24
    var chartPadding = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    var axisGridColor: Color = AppColors.border
    var axisLabelColor: Color = AppColors.textSecondary
    var defaultLineColor: Color = AppColors.accentPrimary
    var interpolationMethod: InterpolationMethod = .catmullRom

    // State: дата выбранной точки (nil — ничего не выбрано)
    @State private var selectedDate: Date?

    // MARK: Derived data

    private var period: ChartPeriodType { ChartPeriodType.detect(by: prices.count) }

    private var points: [ChartPoint] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return prices.enumerated().map { i, price in
            let daysAgo = prices.count - 1 - i
            let date = cal.date(byAdding: .day, value: -daysAgo, to: today)!
            return ChartPoint(index: i, date: date, price: price)
        }
    }

    private var lineColor: Color {
        guard let f = prices.first, let l = prices.last else { return defaultLineColor }
        if l > f { return AppColors.incrValue }
        if l < f { return AppColors.decrValue }
        return defaultLineColor
    }

    private var yDomain: ClosedRange<Double> {
        guard let lo = prices.min(), let hi = prices.max() else { return 0...1 }
        switch scaling {
        case .minMax:
            return lo == hi ? (lo - 1)...(hi + 1) : lo...hi
        case .zero:
            return 0...(hi * 1.05)
        case .padded(let fraction):
            let span = max(hi - lo, hi * 0.01)
            let pad = span * fraction
            return (lo - pad)...(hi + pad)
        }
    }

    private var selectedPoint: ChartPoint? {
        guard let selectedDate else { return nil }
        return points.min {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        }
    }

    // MARK: Body

    var body: some View {
        Group {
            if prices.isEmpty {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(0.5))
                    .frame(height: chartHeight)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    header
                    chart
                }
                .padding(chartPadding)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
        }
    }

    // MARK: Header (цена в выбранной точке)

    @ViewBuilder
    private var header: some View {
        if let p = selectedPoint {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(String(format: "$%.2f", p.price))
                    .font(AppTypography.headline(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(dateLabel(p.date))
                    .font(AppTypography.caption())
                    .foregroundStyle(axisLabelColor)
            }
        } else {
            Text(" ")   // резерв высоты, чтобы шапка не прыгала
                .font(AppTypography.headline(weight: .bold))
        }
    }

    // MARK: Chart

    private var chart: some View {
        Chart {
            ForEach(points) { point in
                LineMark(x: .value("Date", point.date), y: .value("Price", point.price))
                    .interpolationMethod(interpolationMethod)
                    .foregroundStyle(lineColor)

                if showAreaGradient {
                    AreaMark(
                        x: .value("Date", point.date),
                        yStart: .value("Min", yDomain.lowerBound),
                        yEnd: .value("Price", point.price)
                    )
                    .interpolationMethod(interpolationMethod)
                    .foregroundStyle(LinearGradient(
                        colors: [lineColor.opacity(0.25), lineColor.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom))
                }
            }

            // Выбранная точка: вертикальная линия + крупная точка
            if let p = selectedPoint {
                RuleMark(x: .value("Date", p.date))
                    .foregroundStyle(axisLabelColor.opacity(0.4))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                PointMark(x: .value("Date", p.date), y: .value("Price", p.price))
                    .foregroundStyle(lineColor)
                    .symbolSize(180)                       // крупная точка
                    .annotation(position: .top, spacing: 6,
                                overflowResolution: .init(x: .fit, y: .disabled)) {
                        Text(String(format: "$%.2f", p.price))
                            .font(AppTypography.caption(weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.backgroundPrimary, in: Capsule())
                            .foregroundStyle(AppColors.textPrimary)
                    }
            }
        }
        .chartYScale(domain: yDomain)
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(axisGridColor)
                AxisValueLabel().foregroundStyle(axisLabelColor)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine().foregroundStyle(axisGridColor)
                AxisTick()
                if let date = value.as(Date.self) {
                    AxisValueLabel { Text(label(for: date)).foregroundStyle(axisLabelColor) }
                }
            }
        }
        // Тап/драг одним пальцем -> дата. Через chartGesture, чтобы система
        // НЕ затемняла невыбранную часть графика (рисуем выделение только сами).
        .chartGesture { proxy in
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let date: Date = proxy.value(atX: value.location.x) {
                        selectedDate = date
                    }
                }
                .onEnded { _ in
                    selectedDate = nil   // отпустил -> график чистый
                }
        }
        .frame(height: chartHeight)
        .animation(.easeInOut(duration: 0.12), value: selectedDate)
    }

    // MARK: Labels

    private func label(for date: Date) -> String {
        let cal = Calendar.current
        let day = cal.component(.day, from: date)
        let f = DateFormatter(); f.dateFormat = "MMM"
        switch period {
        case .oneMonth: return "\(day)"
        default: return f.string(from: date)
        }
    }

    private func dateLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return f.string(from: date)
    }
}
