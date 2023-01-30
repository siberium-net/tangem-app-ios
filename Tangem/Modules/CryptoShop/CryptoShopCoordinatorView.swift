//
//  CryptoShopCoordinatorView.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct CryptoShopCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: CryptoShopCoordinator

    init(coordinator: CryptoShopCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let warningRussiaBankCardViewModel = coordinator.warningRussiaBankCardViewModel {
                WarningRussiaBankCardView(viewModel: warningRussiaBankCardViewModel)
                    .navigationLinks(links)
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        EmptyView()
    }

    @ViewBuilder
    private var sheets: some View {
        EmptyView()
//        NavHolder()
//            .bottomSheet(
//                item: $coordinator.warningRussiaBankCardViewModel,
//                viewModelSettings: .warning
//            ) {
//                WarningRussiaBankCardView(viewModel: $0)
//            }
    }
}
