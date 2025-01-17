//
//  AppLog.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import TangemExchange

class AppLog {
    static let shared = AppLog()

    private init() {}

    var sdkLogConfig: Log.Config {
        .custom(
            logLevel: Log.Level.allCases,
            loggers: [FileLogger(), ConsoleLogger()]
        )
    }

    func configure() {
        Log.config = sdkLogConfig
    }

    func debug<T>(_ message: @autoclosure () -> T) {
        Log.debug(message())
    }

    func error(_ error: Error) {
        self.error(error: error, params: [:])
    }
}

extension AppLog: ExchangeLogger {}
