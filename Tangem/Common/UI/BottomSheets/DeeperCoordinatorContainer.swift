//
//  DeeperCoordinatorContainer.swift
//  Tangem
//
//  Created by Sergey Balashov on 12.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

class BuyingCoordinator: CoordinatorObject, ObservableObject {
    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Child view models

    @Published var warningBankCardViewModel: WarningBankCardViewModel?

    @Published var pushedWebViewContainerViewModel: WebViewContainerViewModel?
    @Published var modalWebViewContainerViewModel: WebViewContainerViewModel?

    // MARK: - Private

    private var presentMode: Options.PresentMode?

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        presentMode = options.presentMode

        switch options.languageCode {
        case LanguageCode.by, LanguageCode.ru:
            openWarningBankCardViewModel(options: options)
        case LanguageCode.en:
            openBuyCrypto(at: options.url, closeUrl: options.closeUrl, action: options.action)
        default:
            assertionFailure("Not implement languageCode")
            openBuyCrypto(at: options.url, closeUrl: options.closeUrl, action: options.action)
        }
    }
}

extension BuyingCoordinator {
    struct Options {
        let url: URL
        let closeUrl: String
        let action: (String) -> Void
        let languageCode: String
        let presentMode: PresentMode

        enum PresentMode {
            case modal
            case push
        }
    }
}

// MARK: - Private

private extension BuyingCoordinator {
    func openWarningBankCardViewModel(options: Options) {
        let delay = 0.6
        warningBankCardViewModel = .init(confirmCallback: { [weak self] in
            self?.warningBankCardViewModel = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self?.openBuyCrypto(at: options.url, closeUrl: options.closeUrl, action: options.action)
            }
        }, declineCallback: { [weak self] in
            self?.warningBankCardViewModel = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self?.openP2PTutorial()
            }
        })
    }

    func openP2PTutorial() {
        modalWebViewContainerViewModel = WebViewContainerViewModel(
            url: URL(string: "https://tangem.com/howtobuy.html")!,
            title: "",
            addLoadingIndicator: true,
            withCloseButton: false,
            urlActions: [:]
        )
    }

    func openBuyCrypto(at url: URL, closeUrl: String, action: @escaping (String) -> Void) {
        Analytics.log(.topUpScreenOpened) // TODO: Check it
        switch presentMode {
        case .push:
            pushedWebViewContainerViewModel = makeBuyingWebViewViewModel(
                url: url,
                actions: [
                    closeUrl: { [weak self] response in
                        self?.pushedWebViewContainerViewModel = nil
                        action(response)
                    },
                ]
            )
        case .modal:
            modalWebViewContainerViewModel = makeBuyingWebViewViewModel(
                url: url,
                actions: [
                    closeUrl: { [weak self] response in
                        self?.modalWebViewContainerViewModel = nil
                        action(response)
                    },
                ]
            )
        case .none:
            assertionFailure("PresentMode isn't found")
            AppLog.shared.debug("PresentMode isn't found in BuyingCoordinator")
        }
    }

    func makeBuyingWebViewViewModel(url: URL, actions: [String: (String) -> Void]) -> WebViewContainerViewModel {
        WebViewContainerViewModel(
            url: url,
            title: Localization.walletButtonBuy,
            addLoadingIndicator: true,
            urlActions: actions
        )
    }
}

struct BuyingCoordinatorView<RootView: View>: CoordinatorView {
    @ObservedObject var coordinator: BuyingCoordinator
    let rootView: () -> RootView

    var body: some View {
        rootView()
            .navigationLinks(links)
            .overlay(sheets)
    }

    @ViewBuilder
    private var links: some View {
        NavHolder()
            .navigation(item: $coordinator.pushedWebViewContainerViewModel) {
                WebViewContainer(viewModel: $0)
            }
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .sheet(item: $coordinator.modalWebViewContainerViewModel) {
                WebViewContainer(viewModel: $0)
            }

        if #available(iOS 15, *) {
            NavHolder()
                .bottomSheet(item: $coordinator.warningBankCardViewModel) {
                    WarningBankCardView(viewModel: $0)
                }
        } else {
            NavHolder()
                .bottomSheet(
                    item: $coordinator.warningBankCardViewModel,
                    viewModelSettings: .warning
                ) {
                    WarningBankCardView(viewModel: $0)
                }
        }
    }
}
