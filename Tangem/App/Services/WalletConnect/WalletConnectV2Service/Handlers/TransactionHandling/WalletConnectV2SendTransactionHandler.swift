//
//  WCV2SendTransactionHandler.swift
//  Tangem
//
//  Created by Andrew Son on 19/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import WalletConnectSwiftV2

class WalletConnectV2SendTransactionHandler {
    private let wcTransaction: WalletConnectEthTransaction
    private let walletModel: WalletModel
    private let transactionBuilder: WalletConnectEthTransactionBuildable
    private let messageComposer: WalletConnectV2MessageComposable
    private let signer: TangemSigner
    private let uiDelegate: WalletConnectUIDelegate

    private var transactionToSend: Transaction?

    init(
        requestParams: AnyCodable,
        walletModel: WalletModel,
        transactionBuilder: WalletConnectEthTransactionBuildable,
        messageComposer: WalletConnectV2MessageComposable,
        signer: TangemSigner,
        uiDelegate: WalletConnectUIDelegate
    ) throws {
        do {
            let params = try requestParams.get([WalletConnectEthTransaction].self)

            guard let wcTransaction = params.first else {
                throw WalletConnectV2Error.missingTransaction
            }

            self.wcTransaction = wcTransaction
        } catch {
            AppLog.shared.debug("[WC 2.0] Failed to create Send transaction handler. \(error)")
            throw error
        }

        self.walletModel = walletModel
        self.messageComposer = messageComposer
        self.transactionBuilder = transactionBuilder
        self.signer = signer
        self.uiDelegate = uiDelegate
    }
}

extension WalletConnectV2SendTransactionHandler: WalletConnectMessageHandler {
    var event: WalletConnectEvent { .sendTx }

    func messageForUser(from dApp: WalletConnectSavedSession.DAppInfo) async throws -> String {
        let transaction = try await transactionBuilder.buildTx(from: wcTransaction, for: walletModel)
        transactionToSend = transaction

        let message = messageComposer.makeMessage(for: transaction, walletModel: walletModel, dApp: dApp)
        return message
    }

    func handle() async throws -> RPCResult {
        guard let transaction = transactionToSend else {
            throw WalletConnectV2Error.missingTransaction
        }

        try await walletModel.send(transaction, signer: signer).async()

        async let approveAction = { [weak self] in
            guard
                let sendedTx = self?.walletModel.wallet.transactions.last,
                let txHash = sendedTx.hash
            else {
                throw WalletConnectV2Error.transactionSentButNotFoundInManager
            }

            return RPCResult.response(AnyCodable(txHash))
        }

        let selectedAction = await uiDelegate.getResponseFromUser(with: WalletConnectAsyncUIRequest(
            event: .success,
            message: Localization.sendTransactionSuccess,
            approveAction: approveAction
        ))

        return try await selectedAction()
    }
}
