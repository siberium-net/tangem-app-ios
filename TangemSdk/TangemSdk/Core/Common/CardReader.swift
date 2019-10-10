//
//  CardReader.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 26/09/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import CoreNFC

@available(iOS 13.0, *)
public protocol CardReader: class {
    func startSession()
    func stopSession()
    func send(commandApdu: CommandApdu, completion: @escaping (CardReaderCompletionResult<ResponseApdu>) -> Void)
}
