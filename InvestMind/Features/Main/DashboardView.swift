import SwiftUI
import SSCoachMarks

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var isSearchPresented = false
    var onOpenAsset: (Asset) -> Void

    private var sectionTitle: String {
        switch viewModel.selectedSegment {
        case .stocks: return "Акции для покупки"
        case .funds:  return "Фонды для покупки"
        case .crypto: return "Криптовалюты для покупки"
        }
    }

    init(onOpenAsset: @escaping (Asset) -> Void) {
        self.onOpenAsset = onOpenAsset

        let segmentedBackground = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.17, alpha: 1)
                : UIColor.secondarySystemBackground
        }
        let selectedSegmentTint = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor.systemBackground
        }
        let normalTextColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor.label
        }
        let selectedTextColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
                : UIColor.label
        }

        UISegmentedControl.appearance().backgroundColor = segmentedBackground
        UISegmentedControl.appearance().selectedSegmentTintColor = selectedSegmentTint
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: normalTextColor,   .font: UIFont.systemFont(ofSize: 14, weight: .medium)],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: selectedTextColor, .font: UIFont.systemFont(ofSize: 14, weight: .semibold)],
            for: .selected
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                Text("Рынок")
                    .font(AppTypography.largeTitle(weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .showCoachMark(
                        order: 0,
                        title: "Рынок акций",
                        description: "На этой вкладке ты смотришь рынок, выбираешь интересные акции и открываешь  карточки инструментов.",
                        highlightViewCornerRadius: 18,
                        coachMarkBackGroundColor: AppColors.backgroundSecondary
                    )

                Picker("Тип актива", selection: Binding(
                    get: { viewModel.selectedSegment },
                    set: { viewModel.selectSegment($0) }
                )) {
                    ForEach(MarketSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .showCoachMark(
                    order: 1,
                    title: "Что показывать на рынке",
                    description: "Здесь можно переключаться между акциями, фондами и криптовалютой и быстро менять список на экране.",
                    highlightViewCornerRadius: 20,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )

                Text(sectionTitle)
                    .font(AppTypography.caption())
                    .foregroundStyle(AppColors.textSecondary)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(AppColors.danger)
                        .font(AppTypography.caption())
                        .padding(.top, 8)
                }

                LazyVStack(spacing: 0) {
                    ForEach(viewModel.assets) { asset in
                        MarketAssetRow(asset: asset)
                            .contentShape(Rectangle())
                            .onTapGesture { onOpenAsset(asset) }

                        Divider()
                            .background(AppColors.backgroundSecondary)
                    }
                }
                .padding(.top, 8)
                .showCoachMark(
                    order: 2,
                    title: "Список акций и инструментов",
                    description: "Нажми на строку, чтобы открыть карточку инструмента, посмотреть график и перейти к покупке.",
                    highlightViewCornerRadius: 24,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )
            }
            .padding()
        }
        .refreshable {
            viewModel.loadMarket()
        }
        .background(AppColors.backgroundPrimary.ignoresSafeArea())
        .onAppear {
            if viewModel.stockAssets.isEmpty {
                viewModel.loadMarket()
            }
        }
        .toolbar {
            
 //           ToolbarItem(placement: .principal) {
//                Text("Рынок")
  //                  .font(AppTypography.largeTitle(weight: .bold))
    //                .foregroundStyle(AppColors.textPrimary)
      //              .frame(maxWidth: .infinity, alignment: .leading)
        //            .showCoachMark(
          //              order: 0,
            //            title: "Рынок акций",
              //          description: "На этой вкладке ты смотришь рынок, выбираешь интересные акции и открываешь  карточки инструментов.",
                //        highlightViewCornerRadius: 18,
                 //       coachMarkBackGroundColor: AppColors.backgroundSecondary
                   // )
           // }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSearchPresented = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.textPrimary)
                }
                .showCoachMark(
                    order: 3,
                    title: "Поиск акций",
                    description: "Через поиск удобно находить акции по тикеру или названию и сразу переходить в карточку бумаги.",
                    highlightViewCornerRadius: 14,
                    coachMarkBackGroundColor: AppColors.backgroundSecondary
                )
            }
        }
        .sheet(isPresented: $isSearchPresented) {
            MarketSearchView { asset in
                isSearchPresented = false
                onOpenAsset(asset)
            }
        }
    }
}
