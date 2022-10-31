//
//  ExchangeViewError.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 28.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

enum ExchangeWarning {
    case empty
    case notEnoughFunds
    case notEnoungFundsForFee
    case highPriceImpact
    case exchangeHasExpired
}
