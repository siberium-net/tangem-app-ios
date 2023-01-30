//
//  WarningRussiaBankCardCoordinatorView.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct WarningRussiaBankCardCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: WarningRussiaBankCardCoordinator

    init(coordinator: WarningRussiaBankCardCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let rootViewModel = coordinator.rootViewModel {
                WarningRussiaBankCardView(viewModel: rootViewModel)
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
    }
}
