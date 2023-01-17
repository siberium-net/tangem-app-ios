//
//  WalletConnectV2MessageHandler.swift
//  Tangem
//
//  Created by Andrew Son on 16/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2
import TangemSdk
import BlockchainSdk

protocol WalletConnectV2MessageHandler {
    func handle(
        _ request: Request,
        from dApp: WalletConnectSavedSession.DAppInfo,
        using signer: TangemSigner,
        with walletModel: WalletModel
    ) async throws -> RPCResult
}

protocol MessageHandler {
    func messageForUser(from dApp: WalletConnectSavedSession.DAppInfo) -> String
    func handle(with walletModel: WalletModel) async throws -> RPCResult
}

extension MessageHandler {
    var errorMessage: String {
        "Failed to get message from request"
    }
}

struct WalletConnectSigner {
    let walletModel: WalletModel
    let signer: TangemSigner

    func sign(data: Data) async throws -> String {
        let pubKey = walletModel.wallet.publicKey
        return try await signer.sign(hash: data, walletPublicKey: pubKey)
            .tryMap { response -> String in
                if let unmarshalledSig = try? Secp256k1Signature(with: response).unmarshal(
                    with: pubKey.blockchainKey,
                    hash: data
                ) {
                    let strSig = "0x" + unmarshalledSig.r.hexString + unmarshalledSig.s.hexString +
                        unmarshalledSig.v.hexString
                    return strSig
                } else {
                    throw WalletConnectServiceError.signFailed
                }
            }
            .eraseToAnyPublisher()
            .async()
    }
}

struct WalletConnectV2PersonalSignHandler {
    private let message: [String]
    private let signer: WalletConnectSigner
    private let messageComposer: WalletConnectV2MessageComposable

    private var dataToSign: Data? {
        message.joined().data(using: .utf8)
    }

    init(request: AnyCodable, using signer: WalletConnectSigner, with messageComposer: WalletConnectV2MessageComposable) throws {
        let castedParams: [String]
        do {
            castedParams = try request.get([String].self)
        } catch {
            let stringRepresentation = request.stringRepresentation
            AppLog.shared.debug("[WC 2.0] Failed to create sign handler. Raised error: \(error), request data: \(stringRepresentation)")
            throw WalletConnectV2Error.dataInWrongFormat(stringRepresentation)
        }

        message = castedParams
        self.signer = signer
        self.messageComposer = messageComposer
    }
}

extension WalletConnectV2PersonalSignHandler: MessageHandler {
    func messageForUser(from dApp: WalletConnectSavedSession.DAppInfo) -> String {
        guard let dataToSign = dataToSign else {
            return errorMessage
        }

        let message = Localization.walletConnectPersonalSignMessage(dApp.name, dataToSign)
        return message
    }

    func handle(with walletModel: WalletModel) async throws -> RPCResult {
        guard let data = message.joined().data(using: .utf8) else {
            throw "Can't convert data"
        }

        let hash = data.sha3(.keccak256)

        return .error(.internalError)
    }
}

struct CommonWalletConnectV2MessageHandler {
    private let uiDelegate: WalletConnectAlertUIDelegate
    private let messageComposer: WalletConnectV2MessageComposable

    private static let userRejectedResult = RPCResult.error(.init(code: 0, message: "User rejected sign"))

    init(
        uiDelegate: WalletConnectAlertUIDelegate,
        messageComposer: WalletConnectV2MessageComposable
    ) {
        self.uiDelegate = uiDelegate
        self.messageComposer = messageComposer
    }

    private func getHandler(for request: Request, using signer: TangemSigner, walletModel: WalletModel) throws -> MessageHandler {
        let method = request.method
        guard let wcMethod = WalletConnectAction(rawValue: method) else {
            throw WalletConnectV2Error.unsupportedWCMethod(method)
        }

        let wcSigner = WalletConnectSigner(walletModel: walletModel, signer: signer)
        switch wcMethod {
        case .personalSign:
            return try WalletConnectV2PersonalSignHandler(
                request: request.params,
                using: wcSigner,
                with: messageComposer
            )
        case .signTransaction:
            fallthrough
        case .sendTransaction:
            fallthrough
        case .bnbSign:
            fallthrough
        case .bnbTxConfirmation:
            fallthrough
        case .signTypedData, .signTypedDataV4:
            fallthrough
        case .switchChain:
            throw WalletConnectV2Error.unsupportedWCMethod("Switch chain for WC 2.0")
        }
    }
}

extension CommonWalletConnectV2MessageHandler: WalletConnectV2MessageHandler {
    func handle(_ request: Request, from dApp: WalletConnectSavedSession.DAppInfo, using signer: TangemSigner, with walletModel: WalletModel) async throws -> RPCResult {
        let handler = try getHandler(for: request, using: signer, walletModel: walletModel)

        let rejectAction = { Self.userRejectedResult }

        let selectedAction = await uiDelegate.getResponseFromUser(with: WalletConnectGenericUIRequest(
            event: .sign,
            message: handler.messageForUser(from: dApp),
            positiveReactionAction: {
                try await handler.handle(with: walletModel)
            },
            negativeReactionAction: rejectAction
        ))

        guard let selectedAction else {
            return Self.userRejectedResult
        }

        return try await selectedAction()
    }
}
