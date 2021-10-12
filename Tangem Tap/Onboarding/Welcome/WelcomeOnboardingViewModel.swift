//
//  WelcomeOnboardingViewModel.swift
//  Tangem Tap
//
//  Created by Andrew Son on 30.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI
import TangemSdk

class WelcomeOnboardingViewModel: ViewModel, ObservableObject {
    
    weak var assembly: Assembly!
    weak var navigation: NavigationCoordinator!
    weak var cardsRepository: CardsRepository!
    weak var stepsSetupService: OnboardingStepsSetupService!
    weak var imageLoaderService: CardImageLoaderService!
    weak var userPrefsService: UserPrefsService!
    
    weak var failedCardScanTracker: FailedCardScanTracker!
    
    @Published var isScanningCard: Bool = false
    @Published var error: AlertBinder?
    @Published var darkCardSettings: AnimatedViewSettings = .zero
    @Published var lightCardSettings: AnimatedViewSettings = .zero
    
    var shopURL: URL { Constants.shopURL }
    
    var currentStep: WelcomeStep {
        .welcome
    }
    
    private var bag: Set<AnyCancellable> = []
    private var cardImage: UIImage?
    
    private var container: CGSize = .zero
    
    var successCallback: (OnboardingInput) -> Void
    
    init(successCallback: @escaping (OnboardingInput) -> Void) {
        self.successCallback = successCallback
    }
    
    func setupContainer(_ size: CGSize) {
        let isInitialSetup = container == .zero
        container = size
        setupCards(animated: !isInitialSetup)
    }
    
    func scanCard() {
        guard userPrefsService.isTermsOfServiceAccepted else {
            showDisclaimer()
            return
        }
            
        isScanningCard = true
        
        
        var subscription: AnyCancellable? = nil
        
        subscription = cardsRepository.scanPublisher()
            .receive(on: DispatchQueue.main)
            .combineLatest(NotificationCenter.didBecomeActivePublisher)
            .first()
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("Failed to scan card: \(error)")
                    self?.isScanningCard = false
                    self?.failedCardScanTracker.recordFailure()
                    
                    if self?.failedCardScanTracker.shouldDisplayAlert ?? false {
                        self?.navigation.readToTroubleshootingScan = true
                    } else {
                        switch error.toTangemSdkError() {
                        case .unknownError, .cardVerificationFailed:
                            self?.error = error.alertBinder
                        default:
                            break
                        }
                    }
                }
                subscription.map { _ = self?.bag.remove($0) }
            } receiveValue: { [weak self] (result, _) in
                guard let cardModel = result.cardModel else {
                    return
                }
                
                self?.processScannedCard(cardModel, isWithAnimation: true)
            }
        
        subscription?.store(in: &bag)
    }
    
    func acceptDisclaimer() {
        userPrefsService.isTermsOfServiceAccepted = true
        navigation.onboardingToDisclaimer = false
    }
    
    func disclaimerDismissed() {
        scanCard()
    }
    
    private func showDisclaimer() {
        navigation.onboardingToDisclaimer = true
    }
    
    private func processScannedCard(_ cardModel: CardViewModel, isWithAnimation: Bool) {
        stepsSetupService.stepsWithCardImage(for: cardModel)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error.alertBinder
                }
                self?.isScanningCard = false
            } receiveValue: { [unowned self] (steps, image) in
                let input = OnboardingInput(steps: steps,
                                                cardModel: cardModel,
                                                cardImage: image,
                                                cardsPosition: (darkCardSettings, lightCardSettings),
                                                welcomeStep: .welcome,
                                                currentStepIndex: 0,
                                                successCallback: nil)
                
                self.isScanningCard = false
                self.successCallback(input)
                self.bag.removeAll()
            }
            .store(in: &bag)
    }
    
    private func setupCards(animated: Bool) {
        darkCardSettings = WelcomeCardLayout.main.cardSettings(at: currentStep, in: container, animated: animated)
        lightCardSettings = WelcomeCardLayout.supplementary.cardSettings(at: currentStep, in: container, animated: animated)
    }
    
}