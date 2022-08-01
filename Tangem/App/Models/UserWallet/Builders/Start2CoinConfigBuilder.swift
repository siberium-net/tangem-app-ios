//
//  Start2CoinConfigBuilder.swift
//  Tangem
//
//  Created by Alexander Osokin on 01.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk

class Start2CoinConfigBuilder: UserWalletConfigBuilder {
    private let card: Card
    private let walletData: WalletData
    
    private var onboardingSteps: [SingleCardOnboardingStep] {
        if card.wallets.isEmpty {
            return [.createWallet, .success]
        }
        
        return []
    }
    
    init(card: Card, walletData: WalletData) {
        self.card = card
        self.walletData = walletData
    }

    func buildConfig() -> UserWalletConfig {
        var features = baseFeatures(for: card)
        features.insert(.signingSupported)
        features.insert(.signedHashesCounterAvailable)
        
        let defaultBlockchain = Blockchain.from(blockchainName: walletData.blockchain, curve: card.supportedCurves[0])
        
        let config = UserWalletConfig(cardIdFormatted: AppCardIdFormatter(cid: card.cardId).formatted(),
                                      emailConfig: .init(recipient: "cardsupport@start2coin.com",
                                                         subject: "feedback_subject_support".localized),
                                      touURL: makeTouURL(),
                                      cardSetLabel: nil,
                                      cardIdDisplayFormat: .full,
                                      features: features,
                                      defaultBlockchain: defaultBlockchain,
                                      defaultToken: nil,
                                      onboardingSteps: .singleWallet(onboardingSteps),
                                      backupSteps: nil)
        return config
    }

    private func makeTouURL() -> URL? {
        let baseurl = "https://app.tangem.com/tou/"
        let regionCode = self.regionCode(for: card.cardId) ?? "fr"
        let languageCode = Locale.current.languageCode ?? "fr"
        let filename = self.filename(languageCode: languageCode, regionCode: regionCode)
        let url = URL(string: baseurl + filename)
        return url
    }

    private func filename(languageCode: String, regionCode: String) -> String {
        switch (languageCode, regionCode) {
        case ("fr", "ch"):
            return "Start2Coin-fr-ch-tangem.pdf"
        case ("de", "ch"):
            return "Start2Coin-de-ch-tangem.pdf"
        case ("en", "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case ("it", "ch"):
            return "Start2Coin-it-ch-tangem.pdf"
        case ("fr", "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case ("de", "at"):
            return "Start2Coin-de-at-tangem.pdf"
        case (_, "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case (_, "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case (_, "at"):
            return "Start2Coin-de-at-tangem.pdf"
        default:
            return "Start2Coin-fr-fr-atangem.pdf"
        }
    }

    private func regionCode(for cid: String) -> String? {
        let cidPrefix = cid[cid.index(cid.startIndex, offsetBy: 1)]
        switch cidPrefix {
        case "0":
            return "fr"
        case "1":
            return "ch"
        case "2":
            return "at"
        default:
            return nil
        }
    }
}
