//
//  WarningRussiaBankCardView.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct WarningRussiaBankCardView: View {
    @ObservedObject private var viewModel: WarningRussiaBankCardViewModel

    init(viewModel: WarningRussiaBankCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            Assets.russiaFlag.image
                .padding(.top, 80)
                .padding(.leading, 10)

            Text(Localization.russianBankCardWarningTitle)
                .font(.system(size: 20, weight: .regular))
                .padding(30)

            Text(Localization.russianBankCardWarningSubtitle)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 15, weight: .regular))
                .padding(.top, 50)
                .padding([.horizontal, .bottom], 30)

            HStack(spacing: 11) {
                MainButton(
                    title: Localization.commonYes,
                    action: viewModel.didTapConfirm
                )

                MainButton(
                    title: Localization.commonNo,
                    style: .secondary,
                    action: viewModel.didTapDecline
                )
            }
            .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
        .onAppear(perform: viewModel.onAppear)
    }
}

struct WarningRussiaBankCardView_Preview: PreviewProvider {
    static let viewModel = WarningRussiaBankCardViewModel(coordinator: WarningRussiaBankCardCoordinator())

    static var previews: some View {
        WarningRussiaBankCardView(viewModel: viewModel)
    }
}
