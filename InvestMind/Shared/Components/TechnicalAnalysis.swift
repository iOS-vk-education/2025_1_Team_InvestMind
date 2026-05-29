//
//  TechnicalAnalysis.swift
//  InvestMind
//
//  Технический анализ котировок: SMA/EMA, RSI, momentum, max drawdown.
//  Все расчёты выполняются локально по массиву дневных цен.
//

import Foundation

// MARK: - Результат анализа

struct TechnicalAnalysisResult {
    let recommendation: Recommendation
    let growthPotential: Double          // ожидаемый потенциал в %, ограничен диапазоном
    let score: Int                       // суммарный балл сигналов (для отладки)

    // Сырые индикаторы — пригодятся для подписей/отладки
    let rsi: Double?
    let smaShort: Double?
    let smaLong: Double?
    let momentum: Double?
    let maxDrawdown: Double?
}

// MARK: - Движок

enum TechnicalAnalysis {

    /// Главная точка входа. Принимает массив дневных цен (от старых к новым).
    /// Возвращает nil, если данных недостаточно для осмысленного анализа.
    static func analyze(prices: [Double]) -> TechnicalAnalysisResult? {
        // Нужен минимум для самой длинной средней + запас на RSI.
        guard prices.count >= 30 else { return nil }

        let shortPeriod = 20
        let longPeriod  = min(50, prices.count - 1)
        let rsiPeriod   = 14
        let momentumLookback = min(20, prices.count - 1)

        let smaShort = sma(prices, period: shortPeriod)
        let smaLong  = sma(prices, period: longPeriod)
        let rsiValue = rsi(prices, period: rsiPeriod)
        let mom      = momentum(prices, lookback: momentumLookback)
        let drawdown = maxDrawdown(prices)

        var score = 0

        // 1. Тренд по кроссоверу средних: короткая выше длинной — бычий сигнал.
        if let s = smaShort, let l = smaLong {
            let gap = (s - l) / l * 100        // насколько % короткая выше длинной
            if gap > 2 { score += 2 }
            else if gap > 0 { score += 1 }
            else if gap < -2 { score -= 2 }
            else if gap < 0 { score -= 1 }
        }

        // 2. RSI: перекупленность/перепроданность.
        if let r = rsiValue {
            if r > 70 { score -= 2 }           // перекуплено — риск отката
            else if r > 55 { score += 1 }      // здоровая сила
            else if r < 30 { score += 2 }      // перепродано — возможен отскок
            else if r < 45 { score -= 1 }
        }

        // 3. Momentum: направление и сила движения.
        if let m = mom {
            if m > 15 { score += 2 }
            else if m > 5 { score += 1 }
            else if m < -15 { score -= 2 }
            else if m < -5 { score -= 1 }
        }

        // 4. Просадка: большой откат от пика повышает риск.
        if let dd = drawdown {
            if dd > 30 { score -= 2 }
            else if dd > 15 { score -= 1 }
        }

        // Маппинг балла на рекомендацию.
        let recommendation: Recommendation
        switch score {
        case ...(-4): recommendation = .strongSell
        case -3...(-2): recommendation = .sell
        case -1...1: recommendation = .hold
        case 2...3: recommendation = .buy
        default: recommendation = .strongBuy
        }

        // Потенциал роста: momentum как база + поправка на тренд, ограничение диапазоном.
        var potential = (mom ?? 0) * 0.4
        if let s = smaShort, let l = smaLong {
            potential += (s - l) / l * 100 * 0.5
        }
        if let dd = drawdown { potential -= dd * 0.1 }   // риск тянет вниз
        potential = max(-30, min(50, potential))

        return TechnicalAnalysisResult(
            recommendation: recommendation,
            growthPotential: potential,
            score: score,
            rsi: rsiValue,
            smaShort: smaShort,
            smaLong: smaLong,
            momentum: mom,
            maxDrawdown: drawdown
        )
    }

    // MARK: - Индикаторы

    /// Простая скользящая средняя последних `period` значений.
    static func sma(_ prices: [Double], period: Int) -> Double? {
        guard prices.count >= period, period > 0 else { return nil }
        let slice = prices.suffix(period)
        return slice.reduce(0, +) / Double(period)
    }

    /// Экспоненциальная скользящая средняя (последнее значение ряда EMA).
    static func ema(_ prices: [Double], period: Int) -> Double? {
        guard prices.count >= period, period > 0 else { return nil }
        let k = 2.0 / (Double(period) + 1.0)
        // Стартуем с SMA первых `period` значений.
        var emaValue = prices.prefix(period).reduce(0, +) / Double(period)
        for price in prices.dropFirst(period) {
            emaValue = price * k + emaValue * (1 - k)
        }
        return emaValue
    }

    /// RSI по методу Уайлдера за `period` дней. Диапазон 0...100.
    static func rsi(_ prices: [Double], period: Int) -> Double? {
        guard prices.count > period, period > 0 else { return nil }

        var gains = 0.0
        var losses = 0.0

        // Первое усреднение по первым `period` изменениям.
        for i in 1...period {
            let change = prices[i] - prices[i - 1]
            if change >= 0 { gains += change } else { losses -= change }
        }
        var avgGain = gains / Double(period)
        var avgLoss = losses / Double(period)

        // Сглаживание Уайлдера по остальным точкам.
        if prices.count > period + 1 {
            for i in (period + 1)..<prices.count {
                let change = prices[i] - prices[i - 1]
                let gain = max(change, 0)
                let loss = max(-change, 0)
                avgGain = (avgGain * Double(period - 1) + gain) / Double(period)
                avgLoss = (avgLoss * Double(period - 1) + loss) / Double(period)
            }
        }

        guard avgLoss != 0 else { return 100 }   // нет потерь — максимум
        let rs = avgGain / avgLoss
        return 100 - (100 / (1 + rs))
    }

    /// Momentum: процентное изменение текущей цены относительно цены `lookback` дней назад.
    static func momentum(_ prices: [Double], lookback: Int) -> Double? {
        guard prices.count > lookback, lookback > 0 else { return nil }
        let current = prices[prices.count - 1]
        let past = prices[prices.count - 1 - lookback]
        guard past != 0 else { return nil }
        return (current - past) / past * 100
    }

    /// Максимальная просадка (%) — наибольшее падение от достигнутого пика.
    static func maxDrawdown(_ prices: [Double]) -> Double? {
        guard let first = prices.first else { return nil }
        var peak = first
        var maxDD = 0.0
        for price in prices {
            if price > peak { peak = price }
            let dd = (peak - price) / peak * 100
            if dd > maxDD { maxDD = dd }
        }
        return maxDD
    }
}
