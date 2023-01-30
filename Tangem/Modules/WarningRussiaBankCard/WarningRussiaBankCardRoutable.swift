//
//  WarningRussiaBankCardRoutable.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol WarningRussiaBankCardRoutable: AnyObject {
    func didTapConfirm()
    func didTapDecline()
}
