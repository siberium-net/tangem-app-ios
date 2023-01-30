//
//  CryptoShopCoordinator.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class CryptoShopCoordinator: CoordinatorObject {
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService

    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Child view models

    @Published var warningRussiaBankCardViewModel: WarningRussiaBankCardViewModel?
    @Published var pushedWebViewModel: WebViewContainerViewModel? = nil
    @Published var modalWebViewModel: WebViewContainerViewModel? = nil

    // MARK: - Private

    private unowned let router: CryptoShopRoutable
    private var startOption: Options?

    required init(
        router: CryptoShopRoutable,
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.router = router
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        startOption = options

        switch tangemApiService.geoIpRegionCode {
        case LanguageCode.ru:
            openBankWarning()
        default:
            openBuyCrypto(at: options.url, closeUrl: options.closeUrl, action: options.action)
        }
    }
}

// MARK: - Options

extension CryptoShopCoordinator {
    struct Options {
        let url: URL
        let closeUrl: String
        let action: (String) -> Void
        let presentationMode: PresentationMode
    }

    enum PresentationMode {
        case modal
        case push
    }
}

// MARK: - Private

private extension CryptoShopCoordinator {
    func openBankWarning() {
        modalWebViewModel = WebViewContainerViewModel(
            url: URL(string: "https://tangem.com/howtobuy.html")!,
            title: "",
            addLoadingIndicator: true,
            withCloseButton: false,
            urlActions: [:]
        )
    }

    func openBuyCrypto(at url: URL, closeUrl: String, action: @escaping (String) -> Void) {
        Analytics.log(.topUpScreenOpened)
        pushedWebViewModel = WebViewContainerViewModel(
            url: url,
            title: Localization.walletButtonBuy,
            addLoadingIndicator: true,
            urlActions: [
                closeUrl: { [weak self] response in
                    self?.pushedWebViewModel = nil
                    action(response)
                },
            ]
        )
    }
}
