//
//  CryptoShopCoordinatorView.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct CryptoShopCoordinatorView<RootView: View>: CoordinatorView {
    private let rootView: RootView
    @ObservedObject var coordinator: CryptoShopCoordinator

    init(rootView: RootView, coordinator: CryptoShopCoordinator) {
        self.rootView = rootView
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            rootView
                .navigationLinks(links)

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        EmptyView()
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .bottomSheet(
                item: $coordinator.warningRussiaBankCardViewModel,
                viewModelSettings: .warning
            ) {
                WarningRussiaBankCardView(viewModel: $0)
            }
    }
}
