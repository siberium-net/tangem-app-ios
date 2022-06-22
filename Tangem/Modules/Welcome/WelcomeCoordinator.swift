//
//  WelcomeCoordinator.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class WelcomeCoordinator: CoordinatorObject {
    var dismissAction: Action
    var popToRootAction: ParamsAction<PopToRootOptions>
    
    //MARK: - Main view model
    @Published private(set) var welcomeViewModel: WelcomeViewModel? = nil
    
    //MARK: - Child coordinators
    @Published var mainCoordinator: MainCoordinator? = nil
    @Published var pushedOnboardingCoordinator: OnboardingCoordinator? = nil
    @Published var modalOnboardingCoordinator: OnboardingCoordinator? = nil
    @Published var shopCoordinator: ShopCoordinator? = nil
    @Published var tokenListCoordinator: TokenListCoordinator? = nil
    
    //MARK: - Child view models
    @Published var mailViewModel: MailViewModel? = nil
    @Published var disclaimerViewModel: DisclaimerViewModel? = nil
    
    //MARK: - Helpers
    @Published var modalOnboardingCoordinatorKeeper: Bool = false
    
    //MARK: - Private
    private var welcomeLifecycleSubscription: AnyCancellable? = nil
    
    required init(dismissAction: @escaping Action, popToRootAction: @escaping ParamsAction<PopToRootOptions>) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }
    
    func start(with options: WelcomeCoordinator.Options) {
        welcomeViewModel = .init(coordinator: self)
        subscribeToWelcomeLifecycle()
        
        if options.shouldScan {
            welcomeViewModel?.scanCard()
        }
    }
    
    private func subscribeToWelcomeLifecycle() {
        let p1 = $mailViewModel.dropFirst().map { $0 == nil }
        let p2 = $disclaimerViewModel.dropFirst().map { $0 == nil }
        let p3 = $shopCoordinator.dropFirst().map { $0 == nil}
        let p4 = $modalOnboardingCoordinator.dropFirst().map { $0 == nil }
        let p5 = $tokenListCoordinator.dropFirst().map { $0 == nil }
        let p6 = $mailViewModel.dropFirst().map { $0 == nil }
        let p7 = $disclaimerViewModel.dropFirst().map { $0 == nil }
        
        welcomeLifecycleSubscription = p1.merge(with: p2, p3, p4, p5, p6, p7)
            .sink {[unowned self] viewDismissed in
                print("!!! viewDismissed: \(viewDismissed)")
                if viewDismissed {
                    self.welcomeViewModel?.becomeActive()
                } else {
                    self.welcomeViewModel?.resignActve()
                }
            }
    }
}

extension WelcomeCoordinator {
    struct Options {
        let shouldScan: Bool
    }
}

extension WelcomeCoordinator: WelcomeRoutable {
    func openOnboardingModal(with input: OnboardingInput) {
        let dismissAction: Action = {[weak self] in
            self?.modalOnboardingCoordinator = nil
        }
        
        let coordinator = OnboardingCoordinator(dismissAction: dismissAction)
        let options = OnboardingCoordinator.Options(input: input)
        coordinator.start(with: options)
        modalOnboardingCoordinator = coordinator
    }
    
    func openOnboarding(with input: OnboardingInput) {
        let dismissAction: Action = {[weak self] in
            if let card = input.cardInput.cardModel {
                self?.openMain(with: card)
            }
        }
        
        let coordinator = OnboardingCoordinator(dismissAction: dismissAction)
        let options = OnboardingCoordinator.Options(input: input)
        coordinator.start(with: options)
        pushedOnboardingCoordinator = coordinator
    }
    
    func openMain(with cardModel: CardViewModel) {
        let popToRootAction: ParamsAction<PopToRootOptions> = {[weak self] options in
            self?.mainCoordinator = nil
            
            if options.newScan {
                self?.welcomeViewModel?.scanCard()
            }
        }
        
        let coordinator = MainCoordinator(popToRootAction: popToRootAction)
        let options = MainCoordinator.Options(cardModel: cardModel)
        coordinator.start(with: options)
        mainCoordinator = coordinator
    }
    
    func openMail(with dataCollector: EmailDataCollector) {
        mailViewModel = MailViewModel(dataCollector: dataCollector, support: .tangem, emailType: .failedToScanCard)
    }
    
    func openDisclaimer(acceptCallback: @escaping () -> Void, dismissCallback: @escaping  () -> Void) {
        disclaimerViewModel = DisclaimerViewModel(style: .sheet(acceptCallback: acceptCallback), showAccept: true, dismissCallback: dismissCallback)
    }
    
    func openTokensList() {
        let dismissAction: Action = { [weak self] in
            self?.tokenListCoordinator = nil
        }
        let coordinator = TokenListCoordinator(dismissAction: dismissAction)
        coordinator.start(with: .show)
        self.tokenListCoordinator = coordinator
    }
    
    func openShop() {
        let coordinator = ShopCoordinator()
        coordinator.start()
        self.shopCoordinator = coordinator
    }
}
