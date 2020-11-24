//
//  DetailsViewModel.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlockchainSdk

class DetailsViewModel: ViewModel {
    weak var assembly: Assembly!
    weak var cardsRepository: CardsRepository!
    weak var ratesService: CoinMarketCapService!
    {
        didSet {
            ratesService
                .$selectedCurrencyCodePublished
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &bag)
        }
    }
    
    @Published var navigation: NavigationCoordinator!
    @Published private(set) var cardModel: CardViewModel {
        didSet {
            cardModel.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] in
                    self?.objectWillChange.send()
                }
                .store(in: &bag)
        }
    }
	
	var isTwinCard: Bool {
		cardModel.isTwinCard
	}
    
    private var bag = Set<AnyCancellable>()
    
    init(cardModel: CardViewModel) {
        self.cardModel = cardModel
    }
    
    func purgeWallet(completion: @escaping (Result<Void, Error>) -> Void ) {
        cardModel.purgeWallet() {result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
}
