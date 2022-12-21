//
//  ResetToFactoryView.swift
//  Tangem
//
//  Created by Sergey Balashov on 28.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ResetToFactoryView: View {
    @ObservedObject private var viewModel: ResetToFactoryViewModel

    init(viewModel: ResetToFactoryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    Assets.attentionBg
                        .resizable()
                        .fixedSize(horizontal: false, vertical: true)

                    Assets.attentionRed
                        .offset(y: 30)
                }
                .frame(
                    minWidth: geometry.size.width,
                    maxHeight: geometry.size.height * 0.5,
                    alignment: .bottom
                )

                informationViews
            }
        }
        .edgesIgnoringSafeArea(.top)
        .padding(.bottom, 16)
        .navigationBarTitle(Text("Reset to factory settings"), displayMode: .inline)
        .actionSheet(item: $viewModel.actionSheet) { $0.sheet }
        .alert(item: $viewModel.alert) { $0.alert }
    }

    private var informationViews: some View {
        VStack {
            Spacer()

            mainInformationView
                .layoutPriority(1)

            Spacer()

            actionButton
                .layoutPriority(1)
        }
    }

    private var mainInformationView: some View {
        VStack(alignment: .center, spacing: 14) {
            Text(L10n.commonAttention)
                .style(Fonts.Bold.title1, color: Colors.Text.primary1)

            Text(viewModel.message)
                .style(Fonts.Regular.callout, color: Colors.Text.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
    }

    private var actionButton: some View {
        MainButton(
            title: L10n.resetCardToFactoryButtonTitle,
            icon: .trailing(Assets.tangemIcon),
            style: .secondary,
            action: viewModel.mainButtonDidTap
        )
        .padding(.horizontal, 16)
    }
}

struct ResetToFactoryAttentionView_Previews: PreviewProvider {
    static let viewModel = ResetToFactoryViewModel(
        cardModel: CardViewModel(cardInfo: CardInfo(card: .init(card: .card), walletData: .none, name: "", artwork: .noArtwork, primaryCard: nil), config: GenericConfig(card: .init(card: .card)), userWallet: nil),
        coordinator: CardSettingsCoordinator()
    )

    static var previews: some View {
        NavigationView {
            ResetToFactoryView(viewModel: viewModel)
        }
        .previewGroup(withZoomed: false)
    }
}