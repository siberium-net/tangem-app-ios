//
//  WalletConnectUIDelegate.swift
//  Tangem
//
//  Created by Andrew Son on 14/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import WalletConnectSwiftV2
import UIKit

struct WalletConnectUIRequest {
    let event: WalletConnectEvent
    let message: String
    var approveAction: () -> Void
    var rejectAction: (() -> Void)?
}

struct WalletConnectGenericUIRequest<T> {
    let event: WalletConnectEvent
    let message: String
    var approveAction: () async throws -> T
    var rejectAction: (() async throws -> T)?
}

protocol WalletConnectUIDelegate {
    func showScreen(with request: WalletConnectUIRequest)
    @MainActor
    func getResponseFromUser<Result>(with request: WalletConnectGenericUIRequest<Result>) async -> (() async throws -> Result)
}

struct WalletConnectAlertUIDelegate {
    private let appPresenter: AppPresenter = .shared
}

extension WalletConnectAlertUIDelegate: WalletConnectUIDelegate {
    func showScreen(with request: WalletConnectUIRequest) {
        let alert = WalletConnectUIBuilder.makeAlert(
            for: request.event,
            message: request.message,
            onAcceptAction: request.approveAction,
            onReject: request.rejectAction ?? {}
        )

        appPresenter.show(alert)
    }

    @MainActor
    func getResponseFromUser<Result>(with request: WalletConnectGenericUIRequest<Result>) async -> (() async throws -> Result) {
        await withCheckedContinuation { continuation in
            let alert = WalletConnectUIBuilder.makeAlert(
                for: request.event,
                message: request.message,
                onAcceptAction: {
                    continuation.resume(returning: request.approveAction)
                },
                onReject: {
                    if let rejectAction = request.rejectAction {
                        continuation.resume(returning: rejectAction)
                    }
                }
            )
            appPresenter.show(alert)
        }
    }
}
