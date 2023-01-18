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
    func createHandler(for action: WalletConnectAction, with params: AnyCodable, using signer: TangemSigner, and walletModel: WalletModel) throws -> WalletConnectMessageHandler {
        let wcSigner = WalletConnectSigner(walletModel: walletModel, signer: signer)
        switch action {
        case .personalSign:
            return try WalletConnectV2PersonalSignHandler(
                request: params,
                using: wcSigner
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
