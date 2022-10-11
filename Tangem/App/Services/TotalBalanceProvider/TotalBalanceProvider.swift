//
//  TotalBalanceProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 16.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import Foundation
import BlockchainSdk

class TotalBalanceProvider {
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService
    private let userWalletModel: UserWalletModel
    private let totalBalanceAnalyticsService: TotalBalanceAnalyticsService
    private let totalBalanceSubject = CurrentValueSubject<LoadingValue<TotalBalance>, Never>(.loading)
    private var refreshSubscription: AnyCancellable?
    private let userWalletAmountType: Amount.AmountType?
    private var isFirstLoadForCardInSession: Bool = true

    init(userWalletModel: UserWalletModel, userWalletAmountType: Amount.AmountType?, totalBalanceSupportData: TotalBalanceCardSupportInfo) {
        self.userWalletModel = userWalletModel
        self.userWalletAmountType = userWalletAmountType
        totalBalanceAnalyticsService = TotalBalanceAnalyticsService(totalBalanceCardSupportInfo: totalBalanceSupportData)
    }
}

// MARK: - TotalBalanceProviding

extension TotalBalanceProvider: TotalBalanceProviding {
    func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalance>, Never> {
        totalBalanceSubject.eraseToAnyPublisher()
    }

    func updateTotalBalance() {
        totalBalanceSubject.send(.loading)
        loadCurrenciesAndUpdateBalance()
    }
}

private extension TotalBalanceProvider {
    func loadCurrenciesAndUpdateBalance() {
        let tokenItemViewModels = userWalletModel.getWalletModels()
            .flatMap { $0.allTokenItemViewModels() }
            .filter { model in
                guard let amountType = userWalletAmountType else { return true }

                return model.amountType == amountType
            }


        refreshSubscription = tangemApiService.loadCurrencies()
            .tryMap { [unowned self] currencies -> TotalBalance in
                guard let currency = currencies.first(where: { $0.code == AppSettings.shared.selectedCurrencyCode }) else {
                    throw CommonError.noData
                }

                var hasError: Bool = false
                var balance: Decimal = 0.0

                for token in tokenItemViewModels {
                    if token.state.isSuccesfullyLoaded {
                        balance += token.fiatValue
                    }

                    if token.rate.isEmpty || !token.state.isSuccesfullyLoaded {
                        hasError = true
                    }
                }

                self.totalBalanceAnalyticsService.toppedUpCheck(tokenItemViewModels: tokenItemViewModels, balance: balance)

                if self.isFirstLoadForCardInSession {
                    self.totalBalanceAnalyticsService.firstLoadBalanceForCard(tokenItemViewModels: tokenItemViewModels, balance: balance)
                    self.isFirstLoadForCardInSession = false
                }

                return TotalBalance(balance: balance, currency: currency, hasError: hasError)
            }
            .receiveValue { [unowned self] balance in
                self.totalBalanceSubject.send(.loaded(balance))
            }
    }
}

extension TotalBalanceProvider {
    struct TotalBalance {
        let balance: Decimal
        let currency: CurrenciesResponse.Currency
        let hasError: Bool
    }
}
