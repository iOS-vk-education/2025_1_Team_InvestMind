import Foundation

enum AppGuideStage {
    case market
    case portfolios
    case profile
    case completed
}

@MainActor
final class AppGuideSession: ObservableObject {
    @Published var currentStage: AppGuideStage = .market

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
    }
}
