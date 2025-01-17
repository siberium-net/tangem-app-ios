//
//  AnalyticsStorageKey.swift
//  Tangem
//
//  Created by Alexander Osokin on 08.02.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum AnalyticsStorageKey: String {
    case balance
    case signedIn
    case scanSource

    var isPermanent: Bool {
        switch self {
        case .balance:
            return true
        case .signedIn, .scanSource:
            return false
        }
    }
}
