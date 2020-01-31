//
//  LitecoinAddressFactory.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 31.01.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

public class LitecoinAddressFactory: BitcoinAddressFactory {
    override func getNetwork(_ testnet: Bool) -> Data {
        return Data(hex:"30")
    }
}
