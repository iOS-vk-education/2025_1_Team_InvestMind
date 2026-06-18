import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore
    @EnvironmentObject private var guideSession: AppGuideSession

    @State private var selectedTab = 0
    @State private var dashboardPath = NavigationPath()
    @State private var portfolioPath = NavigationPath()
    @StateObject private var dashboardVM = DashboardViewModel()

    @State private var isAddPortfolioPresented = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $dashboardPath) {
                DashboardView { asset in
                    dashboardPath.append(AppRoute.stockDetail(asset))
                }
                .onAppear {
                    dashboardVM.loadMarket()
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .stockDetail(let asset):
                        StockDetailView(asset: asset)
                    default:
                        EmptyView()
                    }
                }
            }
            .appMainGuide(
                isEnabled: guideSession.currentStage == .market,
                doneButtonText: "К портфелям",
                onFinished: {
                    guard guideSession.currentStage == .market else { return }
                    guideSession.advance()
                    selectedTab = 1
                }
            )
            .tabItem {
                Label("Рынок", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack(path: $portfolioPath) {
                PortfolioListView(
                    portfolios: portfolioStore.portfolios,
                    onOpenPortfolio: { selectedPortfolio in
                        portfolioPath.append(AppRoute.portfolioDetail(selectedPortfolio.id))
                    },
                    onAddPortfolio: {
                        isAddPortfolioPresented = true
                    },
                    onRefresh: {
                        await withCheckedContinuation { continuation in
                            portfolioStore.refreshMarketData { _ in
                                continuation.resume()
                            }
                        }
                    },
                    isRefreshing: portfolioStore.isRefreshing
                )
                .onAppear {
                    portfolioStore.refreshMarketData()
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .portfolioDetail(let portfolioId):
                        PortfolioView(portfolioId: portfolioId) { asset in
                            portfolioPath.append(AppRoute.stockDetail(asset))
                        }

                    case .stockDetail(let asset):
                        StockDetailView(asset: asset)

                    }
                }
            }
            .sheet(isPresented: $isAddPortfolioPresented) {
                AddPortfolioView()
            }
            .appMainGuide(
                isEnabled: guideSession.currentStage == .portfolios,
                doneButtonText: "К профилю",
                onFinished: {
                    guard guideSession.currentStage == .portfolios else { return }
                    guideSession.advance()
                    selectedTab = 2
                }
            )
            .tabItem {
                Label("Портфели", systemImage: "briefcase.fill")
            }
            .tag(1)


            NavigationStack {
                ProfileView()
            }
            .appMainGuide(
                isEnabled: guideSession.currentStage == .profile,
                doneButtonText: "Готово",
                onFinished: {
                    guideSession.complete()
                }
            )
            .tabItem {
                Label("Профиль", systemImage: "person.fill")
            }
            .tag(2)
        }
        .tint(AppColors.accentPrimary)
        .background(AppColors.backgroundPrimary)
        .onAppear {
            syncSelectedTabWithGuide()
        }
        .onChange(of: guideSession.currentStage) { _, _ in
            syncSelectedTabWithGuide()
        }
    }

    private func syncSelectedTabWithGuide() {
        switch guideSession.currentStage {
        case .market:
            selectedTab = 0
        case .portfolios:
            selectedTab = 1
        case .profile:
            selectedTab = 2
        case .completed:
            break
        }
    }
}
