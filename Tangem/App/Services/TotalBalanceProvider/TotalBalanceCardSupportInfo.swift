//
//  TotalBalanceCardSupportInfo.swift
//  Tangem
//
//  Created by Andrey Chukavin on 25.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct TotalBalanceCardSupportInfo {
    let cardBatchId: String
    let cardIdentifier: String
    let embeddedBlockchainCurrencySymbol: String?

    init(cardBatchId: String, userWalletId: Data, embeddedBlockchainCurrencySymbol: String?) {
        self.cardBatchId = cardBatchId
        self.cardIdentifier = userWalletId.sha256().hexString
        self.embeddedBlockchainCurrencySymbol = embeddedBlockchainCurrencySymbol
    }
}

struct TotalBalanceCardSupportInfoFactory {
    private let cardModel: CardViewModel

    init(cardModel: CardViewModel) {
        self.cardModel = cardModel
    }

    func createInfo() -> TotalBalanceCardSupportInfo? {
        guard let userWalletId = cardModel.userWalletId else { return nil }

        return TotalBalanceCardSupportInfo(
            cardBatchId: cardModel.batchId,
            userWalletId: userWalletId,
            embeddedBlockchainCurrencySymbol: cardModel.embeddedBlockchain?.currencySymbol
        )
    }
}