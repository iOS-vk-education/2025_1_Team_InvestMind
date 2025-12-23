
import SwiftUI

struct MainTabView: View {
    var portfolios: [UserPortfolio]

    @State private var selectedTab = 0
    @State private var dashboardPath = NavigationPath()
    @State private var portfolioPath = NavigationPath()
    @StateObject private var dashboardVM = DashboardViewModel()

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
            .tabItem {
                Label("Рынок", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack(path: $portfolioPath) {
                PortfolioListView(portfolios: portfolios) { selectedPortfolio in
                    portfolioPath.append(AppRoute.portfolioDetail(selectedPortfolio))
                }
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .portfolioDetail(let portfolio):
                        PortfolioView(portfolio: portfolio) { asset in
                            portfolioPath.append(AppRoute.stockDetail(asset))
                        }

                    case .stockDetail(let asset):
                        StockDetailView(asset: asset)

                    }
                }
            }
            .tabItem {
                Label("Портфели", systemImage: "briefcase.fill")
            }
            .tag(1)


            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Профиль", systemImage: "person.fill")
            }
            .tag(2)
        }
        .tint(AppColors.accentPrimary)
        .background(AppColors.backgroundPrimary)
    }
}

