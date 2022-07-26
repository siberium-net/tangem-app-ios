//
//  TangemSigner.swift
//  Tangem
//
//  Created by Alexander Osokin on 29.09.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//
import Foundation
import TangemSdk
import BlockchainSdk
import Combine

class TangemSigner: TransactionSigner {
    @Injected(\.tangemSdkProvider) private var sdkProvider: TangemSdkProviding

    private var initialMessage: Message { .init(header: nil, body: "initial_message_sign_body".localized) }
    private let cardId: String?

    init(with cardId: String?) {
        self.cardId = cardId
    }

    convenience init(with card: Card) {
        if let backupStatus = card.backupStatus, backupStatus.isActive {
            self.init(with: nil)
        } else {
            self.init(with: card.cardId)
        }
    }

    func sign(hashes: [Data], walletPublicKey: Wallet.PublicKey) -> AnyPublisher<[Data], Error> {
        let future = Future<[Data], Error> { [unowned self] promise in
            let signCommand = SignAndReadTask(hashes: hashes,
                                              walletPublicKey: walletPublicKey.seedKey,
                                              derivationPath: walletPublicKey.derivationPath)
            self.sdkProvider.sdk.startSession(with: signCommand, cardId: self.cardId, initialMessage: self.initialMessage) { signResult in
                switch signResult {
                case .success(let response):
                    promise(.success(response.signatures))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        return AnyPublisher(future)
    }

    func sign(hash: Data, walletPublicKey: Wallet.PublicKey) -> AnyPublisher<Data, Error> {
        sign(hashes: [hash], walletPublicKey: walletPublicKey)
            .map { $0[0] }
            .eraseToAnyPublisher()
    }
}
