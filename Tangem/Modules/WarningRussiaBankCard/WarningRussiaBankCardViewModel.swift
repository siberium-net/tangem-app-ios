//
//  WarningRussiaBankCardViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

class WarningRussiaBankCardViewModel: ObservableObject, Identifiable {
    let id = UUID()

    // MARK: - Dependencies

    private unowned let coordinator: WarningRussiaBankCardRoutable

    init(
        coordinator: WarningRussiaBankCardRoutable
    ) {
        self.coordinator = coordinator
    }

    func onAppear() {
        Analytics.log(.p2PScreenOpened)
    }
}

// MARK: - Navigation

extension WarningRussiaBankCardViewModel {
    func didTapConfirm() {
        coordinator.didTapConfirm()
    }

    func didTapDecline() {
        coordinator.didTapDecline()
    }
}
