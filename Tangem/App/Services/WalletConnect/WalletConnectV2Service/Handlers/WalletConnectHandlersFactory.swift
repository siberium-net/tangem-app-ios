//
//  WalletConnectHandlersFactory.swift
//  Tangem
//
//  Created by Andrew Son on 18/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2

struct WalletConnectHandlersFactory {
    private let messageComposer: WalletConnectV2MessageComposable
    private let uiDelegate: WalletConnectUIDelegate
    private let ethTransactionBuilder: WalletConnectEthTransactionBuildable

    init(
        messageComposer: WalletConnectV2MessageComposable,
        uiDelegate: WalletConnectUIDelegate,
        ethTransactionBuilder: WalletConnectEthTransactionBuildable
    ) {
        self.messageComposer = messageComposer
        self.uiDelegate = uiDelegate
        self.ethTransactionBuilder = ethTransactionBuilder
    }

    func createHandler(for action: WalletConnectAction, with params: AnyCodable, using signer: TangemSigner, and walletModel: WalletModel) throws -> WalletConnectMessageHandler {
        let wcSigner = WalletConnectSigner(walletModel: walletModel, signer: signer)
        switch action {
        case .personalSign:
            return try WalletConnectV2PersonalSignHandler(
                request: params,
                using: wcSigner
            )
        case .signTransaction:
            return try WalletConnectV2SignTransactionHandler(
                requestParams: params,
                walletModel: walletModel,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer
            )
        case .sendTransaction:
            return try WalletConnectV2SendTransactionHandler(
                requestParams: params,
                walletModel: walletModel,
                transactionBuilder: ethTransactionBuilder,
                messageComposer: messageComposer,
                signer: signer,
                uiDelegate: uiDelegate
            )
        case .bnbSign:
            fallthrough
        case .bnbTxConfirmation:
            fallthrough
        case .signTypedData, .signTypedDataV4:
            return try WalletConnectV2SignTypedDataHandler(
                requestParams: params,
                signer: wcSigner
            )
        case .switchChain:
            throw WalletConnectV2Error.unsupportedWCMethod("Switch chain for WC 2.0")
        }
    }
}
