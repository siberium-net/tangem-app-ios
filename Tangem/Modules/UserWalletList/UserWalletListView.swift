//
//  UserWalletListView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct UserWalletListView: View {
    @ObservedObject private var viewModel: UserWalletListViewModel

    static var sheetBackground: Color {
        if #available(iOS 14, *) {
            return Colors.Background.secondary
        } else {
            // iOS 13 can't convert named SwiftUI colors to UIColor
            return Color(hex: "F2F2F7")!
        }
    }

    init(viewModel: UserWalletListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            #warning("l10n")
            Text("My Wallets")
                .style(Fonts.Bold.body, color: Colors.Text.primary1)

            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    #warning("l10n")
                    section("Multi-currency", for: viewModel.multiCurrencyModels)

                    #warning("l10n")
                    section("Single-currency", for: viewModel.singleCurrencyModels)

                    // TODO: remove this hack
//                    Spacer()
//                        .frame(height: 80)
                }
            }
            .background(Colors.Background.primary)
            .cornerRadius(14)

            #warning("l10n")
            TangemButton(title: "Add new card", systemImage: "plus") {
                viewModel.addCard()
            }
            .buttonStyle(TangemButtonStyle(colorStyle: .grayAlt3, layout: .flexibleWidth))
        }
        .padding(16)
    }

    @ViewBuilder
    private func section(_ header: String, for models: [CardViewModel]) -> some View {
        if !models.isEmpty {
            UserWalletListHeaderView(name: header)

            ForEach(0 ..< models.count, id: \.self) { i in
                UserWalletListCellView(model: models[i], isSelected: viewModel.selectedUserWalletId == models[i].userWallet.userWalletId) { userWallet in
                    viewModel.onUserWalletTapped(userWallet)
                }
                .contextMenu {
                    Button {
                        viewModel.editWallet(models[i].userWallet)
                    } label: {
                        HStack {
                            Text("Rename")
                            Image(systemName: "pencil")
                        }
                    }

                    if #available(iOS 15.0, *) {
                        Button(role: .destructive) {
                            viewModel.deleteUserWallet(models[i].userWallet)
                        } label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    } else {
                        Button {
                            viewModel.deleteUserWallet(models[i].userWallet)
                        } label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }

                if i != (models.count - 1) {
                    Separator(height: 0.5, padding: 0, color: Colors.Stroke.primary)
                        .padding(.leading, 78)
                }
            }
        }
    }
}

struct UserWalletListView_Previews: PreviewProvider {
    static var previews: some View {
        UserWalletListView(viewModel: .init(coordinator: UserWalletListCoordinator()))
    }
}
