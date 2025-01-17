//
//  WalletConnectV2HandlersFactory.swift
//  Tangem
//
//  Created by Andrew Son on 30/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import BlockchainSdk
import struct WalletConnectSwiftV2.AnyCodable

protocol WalletConnectHandlersCreator: AnyObject {
    func createHandler(
        for action: WalletConnectAction,
        with params: AnyCodable,
        blockchain: Blockchain
    ) throws -> WalletConnectMessageHandler
}

final class WalletConnectHandlersFactory: WalletConnectHandlersCreator {
    private let signer: TangemSigner
    private let messageComposer: WalletConnectV2MessageComposable
    private let uiDelegate: WalletConnectUIDelegate
    private let ethTransactionBuilder: WalletConnectEthTransactionBuilder

    weak var walletModelProvider: WalletConnectV2WalletModelProvider?

    init(
        signer: TangemSigner,
        messageComposer: WalletConnectV2MessageComposable,
        uiDelegate: WalletConnectUIDelegate,
        ethTransactionBuilder: WalletConnectEthTransactionBuilder
    ) {
        self.signer = signer
        self.messageComposer = messageComposer
        self.uiDelegate = uiDelegate
        self.ethTransactionBuilder = ethTransactionBuilder
    }

    func createHandler(
        for action: WalletConnectAction,
        with params: AnyCodable,
        blockchain: Blockchain
    ) throws -> WalletConnectMessageHandler {
        guard let walletModelProvider = self.walletModelProvider else {
            throw WalletConnectV2Error.missingWalletModelProviderInHandlersFactory
        }

        switch action {
        case .personalSign:
            return try WalletConnectV2PersonalSignHandler(
                request: params,
                blockchain: blockchain,
                signer: CommonWalletConnectSigner(signer: signer),
                walletModelProvider: walletModelProvider
            )
        case .signTypedData, .signTypedDataV4:
            return try WalletConnectV2SignTypedDataHandler(
                requestParams: params,
                blockchain: blockchain,
                signer: CommonWalletConnectSigner(signer: signer),
                walletModelProvider: walletModelProvider
            )
        case .signTransaction:
            return try WalletConnectV2SignTransactionHandler(
                requestParams: params,
                blockchain: blockchain,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer,
                walletModelProvider: walletModelProvider
            )
        case .sendTransaction:
            return try WalletConnectV2SendTransactionHandler(
                requestParams: params,
                blockchain: blockchain,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer,
                uiDelegate: uiDelegate,
                walletModelProvider: walletModelProvider
            )
        case .bnbSign, .bnbTxConfirmation:
            // TODO: https://tangem.atlassian.net/browse/IOS-2896
            // Initially this methods was found occasionally and supported without any request
            // Need to find documentation and find place where it can be tested on 2.0
            // This page https://www.bnbchain.org/en/staking has WalletConnect in status 'Coming Soon'
            throw WalletConnectV2Error.unsupportedWCMethod("BNB methods")
        case .switchChain:
            throw WalletConnectV2Error.unsupportedWCMethod("Switch chain for WC 2.0")
        }
    }
}
