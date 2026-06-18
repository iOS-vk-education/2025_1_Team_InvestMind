import Foundation

enum AppGuideStage {
    case market
    case portfolios
    case profile
    case completed
}

@MainActor
final class AppGuideSession: ObservableObject {
    private let defaults: UserDefaults
    private let hasCompletedMainGuideKey = "hasCompletedMainGuide"

    @Published var currentStage: AppGuideStage

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentStage = defaults.bool(forKey: hasCompletedMainGuideKey) ? .completed : .market
    }

    var hasPresentedMainGuide: Bool {
        currentStage == .completed
    }

    func advance() {
        switch currentStage {
        case .market:
            currentStage = .portfolios
        case .portfolios:
            currentStage = .profile
        case .profile:
            currentStage = .completed
        case .completed:
            break
        }
    }

    func complete() {
        currentStage = .completed
        defaults.set(true, forKey: hasCompletedMainGuideKey)
    }
}
