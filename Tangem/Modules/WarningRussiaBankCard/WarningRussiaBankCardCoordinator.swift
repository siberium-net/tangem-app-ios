//
//  WarningRussiaBankCardCoordinator.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol WarningRussiaBankCardCoordinatorRoutable: AnyObject {
    func didTapConfirm()
}

class WarningRussiaBankCardCoordinator: CoordinatorObject {
    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Root view model

    @Published private(set) var rootViewModel: WarningRussiaBankCardViewModel?

    // MARK: - Child view models

    @Published var modalWebViewModel: WebViewContainerViewModel? = nil

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {}

    func openP2PTutorial() {
        modalWebViewModel = WebViewContainerViewModel(
            url: URL(string: "https://tangem.com/howtobuy.html")!,
            title: "",
            addLoadingIndicator: true,
            withCloseButton: false,
            urlActions: [:]
        )
    }
}

// MARK: - Options

extension WarningRussiaBankCardCoordinator {
    enum Options {
        case `default`
    }
}

// MARK: - WarningRussiaBankCardRoutable

extension WarningRussiaBankCardCoordinator: WarningRussiaBankCardRoutable {
    func didTapConfirm() {}

    func didTapDecline() {}
}
