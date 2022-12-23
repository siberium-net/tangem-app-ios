//
//  DetailsCoordinator.swift
//  Tangem
//
//  Created by Alexander Osokin on 21.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import UIKit

class DetailsCoordinator: CoordinatorObject {
    var dismissAction: Action
    var popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Main view model

    @Published private(set) var detailsViewModel: DetailsViewModel? = nil

    // MARK: - Child coordinators

    @Published var modalOnboardingCoordinator: OnboardingCoordinator? = nil
    @Published var walletConnectCoordinator: WalletConnectCoordinator? = nil
    @Published var cardSettingsCoordinator: CardSettingsCoordinator? = nil
    @Published var referralCoordinator: ReferralCoordinator? = nil

    // MARK: - Child view models

    @Published var currencySelectViewModel: CurrencySelectViewModel? = nil
    @Published var mailViewModel: MailViewModel? = nil
    @Published var disclaimerViewModel: DisclaimerViewModel? = nil
    @Published var supportChatViewModel: SupportChatViewModel? = nil
    @Published var scanCardSettingsViewModel: ScanCardSettingsViewModel? = nil
    @Published var appSettingsViewModel: AppSettingsViewModel? = nil
    @Published var setupEnvironmentViewModel: EnvironmentSetupViewModel? = nil

    // MARK: - Helpers

    @Published var modalOnboardingCoordinatorKeeper: Bool = false

    required init(dismissAction: @escaping Action, popToRootAction: @escaping ParamsAction<PopToRootOptions>) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: DetailsCoordinator.Options) {
        detailsViewModel = DetailsViewModel(cardModel: options.cardModel, coordinator: self)
    }
}

extension DetailsCoordinator {
    struct Options {
        let cardModel: CardViewModel
    }
}

// MARK: - DetailsRoutable

extension DetailsCoordinator: DetailsRoutable {
    func openCurrencySelection() {
        currencySelectViewModel = CurrencySelectViewModel()
        currencySelectViewModel?.dismissAfterSelection = false
    }

    func openOnboardingModal(with input: OnboardingInput) {
        let dismissAction: Action = { [weak self] in
            self?.modalOnboardingCoordinator = nil
            self?.detailsViewModel?.didFinishOnboarding()
        }

        let coordinator = OnboardingCoordinator(dismissAction: dismissAction)
        let options = OnboardingCoordinator.Options(input: input, destination: .dismiss)
        coordinator.start(with: options)
        modalOnboardingCoordinator = coordinator
    }

    func openMail(with dataCollector: EmailDataCollector, recipient: String, emailType: EmailType) {
        mailViewModel = MailViewModel(dataCollector: dataCollector, recipient: recipient, emailType: emailType)
    }

    func openWalletConnect(with cardModel: CardViewModel) {
        Analytics.log(.myWalletsScreenOpened)
        let coordinator = WalletConnectCoordinator()
        let options = WalletConnectCoordinator.Options(cardModel: cardModel)
        coordinator.start(with: options)
        walletConnectCoordinator = coordinator
    }

    func openDisclaimer(at url: URL) {
        disclaimerViewModel = .init(url: url, style: .navbar, coordinator: nil)
    }

    func openScanCardSettings(with userWalletId: Data) {
        scanCardSettingsViewModel = ScanCardSettingsViewModel(expectedUserWalletId: userWalletId, coordinator: self)
    }

    func openAppSettings(userWallet: UserWallet) {
        appSettingsViewModel = AppSettingsViewModel(userWallet: userWallet, coordinator: self)
    }

    func openSupportChat(cardId: String, dataCollector: EmailDataCollector) {
        Analytics.log(.chatScreenOpened)
        supportChatViewModel = SupportChatViewModel(cardId: cardId, dataCollector: dataCollector)
    }

    func openInSafari(url: URL) {
        UIApplication.shared.open(url)
    }

    func openEnvironmentSetup() {
        setupEnvironmentViewModel = EnvironmentSetupViewModel()
    }

    func openReferral(with cardModel: CardViewModel, userWalletId: Data) {
        let dismissAction: Action = { [weak self] in
            self?.referralCoordinator = nil
        }

        let coordinator = ReferralCoordinator(dismissAction: dismissAction)
        coordinator.start(with: .init(cardModel: cardModel, userWalletId: userWalletId))
        referralCoordinator = coordinator
    }
}

// MARK: - ScanCardSettingsRoutable

extension DetailsCoordinator: ScanCardSettingsRoutable {
    func openCardSettings(cardModel: CardViewModel) {
        scanCardSettingsViewModel = nil

        let coordinator = CardSettingsCoordinator(dismissAction: dismissAction, popToRootAction: popToRootAction)
        coordinator.start(with: .init(cardModel: cardModel))
        cardSettingsCoordinator = coordinator
    }
}

// MARK: - AppSettingsRoutable

extension DetailsCoordinator: AppSettingsRoutable {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
    }
}
