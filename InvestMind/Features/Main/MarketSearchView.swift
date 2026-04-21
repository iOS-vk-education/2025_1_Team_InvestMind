//
//  MarketSearchView.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 28.03.2026.
//

import Foundation
import SwiftUI

struct MarketSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var isLoading = false
    @State private var foundAsset: Asset?
    @State private var errorMessage: String?

    var onSelect: (Asset) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.textSecondary)

                        TextField("Введите тикер", text: $query)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .submitLabel(.search)
                            .onSubmit {
                                search()
                            }
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .padding()
                    .background(AppColors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Text("Введите тикер, например AAPL")
                        .font(AppTypography.caption())
                        .foregroundStyle(AppColors.textSecondary)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(AppColors.danger)
                            .font(AppTypography.caption())
                    }

                    if let foundAsset {
                        MarketAssetRow(asset: foundAsset)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                dismiss()
                                onSelect(foundAsset)
                            }
                    } else if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && errorMessage == nil {
                        Text("Нажмите поиск на клавиатуре")
                            .font(AppTypography.caption())
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            }
            .navigationTitle("Поиск")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(AppColors.textPrimary)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func search() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        foundAsset = nil

        ChartAPI.shared.searchAsset(symbol: trimmed) { result in
            isLoading = false

            switch result {
            case .success(let asset):
                foundAsset = asset
            case .failure:
                errorMessage = "Актив с таким тикером не найден"
            }
        }
    }
}
